/***********************************************************************************************************************
* DISCLAIMER
* This software is supplied by Renesas Electronics Corporation and is only intended for use with Renesas products. No
* other uses are authorized. This software is owned by Renesas Electronics Corporation and is protected under all
* applicable laws, including copyright laws.
* THIS SOFTWARE IS PROVIDED "AS IS" AND RENESAS MAKES NO WARRANTIES REGARDING
* THIS SOFTWARE, WHETHER EXPRESS, IMPLIED OR STATUTORY, INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. ALL SUCH WARRANTIES ARE EXPRESSLY DISCLAIMED. TO THE MAXIMUM
* EXTENT PERMITTED NOT PROHIBITED BY LAW, NEITHER RENESAS ELECTRONICS CORPORATION NOR ANY OF ITS AFFILIATED COMPANIES
* SHALL BE LIABLE FOR ANY DIRECT, INDIRECT, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES FOR ANY REASON RELATED TO THIS
* SOFTWARE, EVEN IF RENESAS OR ITS AFFILIATES HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
* Renesas reserves the right, without notice, to make changes to this software and to discontinue the availability of
* this software. By using this software, you agree to the additional terms and conditions found by accessing the
* following link:
* http://www.renesas.com/disclaimer
*
* Copyright (C) 2023 Renesas Electronics Corporation. All rights reserved.
***********************************************************************************************************************/
/***********************************************************************************************************************
* File Name    : camera.cpp
* Version      : 7.40
* Description  : RZ/V DRP-AI Sample Application for PyTorch ResNet USB Camera version
***********************************************************************************************************************/

/*****************************************
* Includes
******************************************/
#include "camera.h"
#include <errno.h>
#include <cmath>
#include <iostream>

#include "../util/measure_time.h"

Camera::Camera()
{
    out_width = 0;
    out_height = 0;
    camera_color = 0;
}

Camera::~Camera()
{
}

/**
 * @brief ceil3
 * @details ceil num specifiy digit
 * @param num number
 * @param base ceil digit
 * @return int32_t result
 */
static int32_t ceil3(int32_t num, int32_t base)
{
    double x = (double)(num) / (double)(base);
    double y = ceil(x) * (double)(base);
    return (int32_t)(y);
}

/**
 * @brief calc_umdabuf_addr
 * @details calclate UMDA Buffer address
 * @return uint64_t UMDA Buffer address
 */
static uint64_t calc_umdabuf_addr()
{
    uint64_t ret_address = 0;

    /* Obtain udmabuf memory area starting address */
    int8_t fd = 0;
    char addr[1024];
    int32_t read_ret = 0;
    errno = 0;
    fd = open("/sys/class/u-dma-buf/udmabuf0/phys_addr", O_RDONLY);
    if (0 > fd)
    {
        fprintf(stderr, "[ERROR] Failed to open udmabuf0/phys_addr : errno=%d\n", errno);
        return -1;
    }
    read_ret = read(fd, addr, 1024);
    if (0 > read_ret)
    {
        fprintf(stderr, "[ERROR] Failed to read udmabuf0/phys_addr : errno=%d\n", errno);
        close(fd);
        return -1;
    }
    sscanf(addr, "%lx", &ret_address);
    close(fd);
    /* Filter the bit higher than 32 bit */
    ret_address &= 0xFFFFFFFF;

    return ret_address;
}

void Camera::read_native_resolutions()
{
    in_width = out_width;
    in_height = out_height;

    std::ifstream file("/tmp/app-usbcam-http-config");
    if (!file)
        return;

    std::string line;
    while (std::getline(file, line)) {
        // Skip empty lines and lines starting with '#'
        if (line.empty() || line[0] == '#') {
            continue;
        }

        // Find the position of the '=' delimiter
        size_t delimiterPos = line.find('=');
        if (delimiterPos != std::string::npos) {
            // Extract the key and value
            std::string key = line.substr(0, delimiterPos);
            std::string value = line.substr(delimiterPos + 1);
            if (key == "NATIVE_CAMERA_IMAGE_WIDTH")
                in_width = std::stoi(value);
            else if (key == "NATIVE_CAMERA_IMAGE_HEIGHT")
                in_height = std::stoi(value);
        }
    }

    // Close the file
    file.close();

    if (in_width == out_width && out_height == in_height) {
        adjust_img = false;
        return;
    }

    double ws = (double) in_width / (double) out_width;
    double hs = (double) in_height / (double) out_height;
    if (ws < hs) {
        scale_width = out_width;
        scale_height = in_height / ws;
        int crop_x = 0;
        int crop_y = ((scale_height - out_height) & ~1) / 2;
        crop_region = cv::Rect(crop_x, crop_y, 640, 480);
    } else {
        scale_width = in_width / hs;
        scale_height = out_height;
        int crop_x = ((scale_width - out_width) & ~1) / 2;
        int crop_y = 0;
        crop_region = cv::Rect(crop_x, crop_y, 640, 480);
    }

    adjust_img = true;
}

/**
 * @brief start_camera
 * @details  Function to initialize USB camera capture
 * @return int8_t  0 if succeeded
*                 not 0 otherwise
 */
int8_t Camera::start_camera()
{
    int8_t ret = 0;
    int32_t i = 0;
    int32_t n = 0;

    read_native_resolutions();

    printf("Camera (input) width = %d\n", in_width);
    printf("Camera (input) height = %d\n", in_height);

    printf("Camera (output) width = %d\n", out_width);
    printf("Camera (output) height = %d\n", out_height);
    printf("Camera channel = %d\n", camera_color);

    ret = open_camera_device();
    if (0 != ret) return ret;

    ret = init_camera_fmt();
    if (0 != ret) return ret;

    ret = init_buffer();
    if (0 != ret) return ret;

    udmabuf_address = calc_umdabuf_addr();

    udmabuf_file = open("/dev/udmabuf0", O_RDWR);
    if (0 > udmabuf_file)
    {
        printf("[ERROR] /dev/udmabuf0 open Failed...\n");
        return -1;
    }
    // page size alignment.
    int32_t offset = ceil3(imageLength, sysconf(_SC_PAGE_SIZE));
    _offset = offset;
    for (n = 0; n < CAP_BUF_NUM; n++)
    {
        // fit to page size.
        buffer[n] = (uint8_t*)mmap(NULL, imageLength, PROT_READ | PROT_WRITE, MAP_SHARED, udmabuf_file, n * offset);

        if (MAP_FAILED == buffer[n])
        {
            printf("print error string by strerror: %s\n", strerror(errno));
            return -1;
        }

        /* Write once to allocate physical memory to u-dma-buf virtual space.
        * Note: Do not use memset() for this.
        *       Because it does not work as expected. */
        {
            uint8_t* word_ptr = buffer[n];
            for (i = 0; i < _offset; i++)
            {
                word_ptr[i] = 0;
            }
        }

        memset(&buf_capture, 0, sizeof(buf_capture));
        buf_capture.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
        buf_capture.memory = V4L2_MEMORY_USERPTR;
        buf_capture.index = n;
        /* buffer[i] must be casted to unsigned long type in order to assign it to V4L2 buffer */
        buf_capture.m.userptr = reinterpret_cast<unsigned long>(buffer[n]);
        buf_capture.length = imageLength;
        ret = xioctl(m_fd, VIDIOC_QBUF, &buf_capture);
        if (-1 == ret)
        {
            return -1;
        }
    }

    ret = start_capture();
    if (0 != ret) return ret;

    return 0;
}


/**
 * @brief close_capture
 * @details Close camera and free buffer
 * @return int8_t  0 if succeeded
*                 not 0 otherwise
 */
int8_t Camera::close_camera()
{
    int8_t ret = 0;
    int32_t i = 0;

    ret = stop_capture();
    if (0 != ret) return ret;

    for (i = 0; i < CAP_BUF_NUM; i++)
    {
        munmap(buffer[i], _offset);
    }
    close(udmabuf_file);
    close(m_fd);
    return 0;
}

/**
 * @brief xioctl
 * @details  ioctl calling
 * @param fd V4L2 file descriptor
 * @param request V4L2 control ID defined in videodev2.h
 * @param arg set value
 * @return int8_t output parameter
 */
int8_t Camera::xioctl(int8_t fd, int32_t request, void* arg)
{
    int8_t r;
    do r = ioctl(fd, request, arg);
    while (-1 == r && EINTR == errno);
    return r;
}

/**
 * @brief start_capture
 * @details Set STREAMON
 * @return int8_t 0 if succeeded
*                 not 0 otherwise
 */
int8_t Camera::start_capture()
{
    int8_t ret = 0;
    struct v4l2_buffer buf;
    memset(&buf, 0, sizeof(buf));

    buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;

    ret = xioctl(m_fd, VIDIOC_STREAMON, &buf.type);
    if (-1 == ret)
    {
        return -1;
    }
    return 0;
}


/**
 * @brief capture_qbuf
 * @details Function to enqueue the buffer.
*                 (Call this function after capture_image() to restart filling image data into buffer)
 * @return int8_t  0 if succeeded
*                 not 0 otherwise
 */
int8_t Camera::capture_qbuf()
{
    int8_t ret = 0;

    ret = xioctl(m_fd, VIDIOC_QBUF, &buf_capture);
    if (-1 == ret)
    {
        return -1;
    }
    return 0;
}

/**
 * @brief capture_image
 * @details  Function to capture image and return the physical memory address where the captured image stored.
*                 Must call capture_qbuf after calling this function.
 * @return uint32_t the physical memory address where the captured image stored.
 */
uint32_t Camera::capture_image()
{
    int8_t ret = 0;
    fd_set fds;
    /*Delete all file descriptor from fds*/
    FD_ZERO(&fds);
    /*Add m_fd to file descriptor set fds*/
    FD_SET(m_fd, &fds);


    /* Check when a new frame is available */
    while (1)
    {
        ret = select(m_fd + 1, &fds, NULL, NULL, NULL);
        if (0 > ret)
        {
            if (EINTR == errno)
            {
                cout << "capture select error!" << endl;
                continue;
            }
            return 0;
        }
        break;
    }

    /* Get buffer where camera stored data */

    ret = xioctl(m_fd, VIDIOC_DQBUF, &buf_capture);
    if (-1 == ret)
    {
        cout << "capture select error!" << endl;
        return 0;
    }
    return udmabuf_address + buf_capture.index * _offset;
}

/**
 * @brief stop_capture
 * @details Set STREAMOFF
 * @return int8_t 0 if succeeded
*                 not 0 otherwise
 */
int8_t Camera::stop_capture()
{
    //printf("stop_capture");
    int8_t ret = 0;
    struct v4l2_buffer buf;
    memset(&buf, 0, sizeof(buf));

    buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    buf.memory = V4L2_MEMORY_USERPTR;

    ret = xioctl(m_fd, VIDIOC_STREAMOFF, &buf.type);
    if (-1 == ret)
    {
        return -1;
    }
    return 0;
}

/**
 * @brief open_camera_device
 * @details Function to open camera *called by start_camera
 * @return int8_t 0 if succeeded
*                 not 0 otherwise
 */
int8_t Camera::open_camera_device()
{
    char dev_name[4096] = { 0 };
    int32_t i = 0;
    int8_t ret = 0;
    struct v4l2_capability fmt;

    for (i = 0; i < 15; i++)
    {
        snprintf(dev_name, sizeof(dev_name), "/dev/video%d", i);
        m_fd = open(dev_name, O_RDWR);
        if (m_fd == -1)
        {
            continue;
        }

        /* Check device is valid (Query Device information) */
        memset(&fmt, 0, sizeof(fmt));
        ret = xioctl(m_fd, VIDIOC_QUERYCAP, &fmt);
        if (-1 == ret)
        {
            return -1;
        }

        printf("[INFO] Camera '%s' Driver '%s'\n", dev_name, fmt.driver);
        break;

        /* Search USB camera */
        ret = strcmp((const char*)fmt.driver, "uvcvideo");
        if (0 == ret)
        {
            printf("[INFO] USB Camera: %s\n", dev_name);
            break;
        }
        close(m_fd);
    }

    if (i >= 15)
    {
        return -1;
    }
    return 0;
}

/**
 * @brief init_camera_fmt
 * @details Function to request format *called by start_camera
 * @return int8_t  0 if succeeded
*                 not 0 otherwise
 */
int8_t Camera::init_camera_fmt()
{
    int8_t ret = 0;
    struct v4l2_format fmt;
    memset(&fmt, 0, sizeof(fmt));
    fmt.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    fmt.fmt.pix.width = in_width;
    fmt.fmt.pix.height = in_height;
    fmt.fmt.pix.pixelformat = V4L2_PIX_FMT_YUYV;
    fmt.fmt.pix.field = V4L2_FIELD_NONE;


    ret = xioctl(m_fd, VIDIOC_S_FMT, &fmt);
    if (-1 == ret)
    {
        printf("[ERROR] VIDIOC_S_FMT Failed: %d\n", ret);
        return -1;
    }

    struct v4l2_streamparm* setfps;
    setfps = (struct v4l2_streamparm*)calloc(1, sizeof(struct v4l2_streamparm));
    memset(setfps, 0, sizeof(struct v4l2_streamparm));
    setfps->type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    setfps->parm.capture.timeperframe.numerator = 1;
    setfps->parm.capture.timeperframe.denominator = 30;
    if (ioctl(m_fd, VIDIOC_S_PARM, setfps) < 0)
    {
        // ignore VIDIOC_S_PARM failure; for CSI2 cameras, this does not work
        printf("[WARN] VIDIOC_S_PARM Failed: %d\n", errno);
    }

    return 0;
}

/**
 * @brief init_buffer
 * @details  Initialize camera buffer *called by start_camera
 * @return  0 if succeeded
*                 not 0 otherwise 
 */
int8_t Camera::init_buffer()
{
    int8_t ret = 0;
    int32_t i = 0;
    struct v4l2_requestbuffers req;
    memset(&req, 0, sizeof(req));
    req.count = CAP_BUF_NUM;
    req.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    req.memory = V4L2_MEMORY_USERPTR;

    /*Request a buffer that will be kept in the device*/
    ret = xioctl(m_fd, VIDIOC_REQBUFS, &req);
    if (-1 == ret)
    {
        printf("[ERROR] VIDIOC_REQBUFS Failed: %d\n", ret);
        return -1;
    }

    struct v4l2_buffer buf;
    for (i = 0; i < CAP_BUF_NUM; i++)
    {
        memset(&buf, 0, sizeof(buf));
        buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
        buf.memory = V4L2_MEMORY_USERPTR;
        buf.index = i;

        /* Extract buffer information */
        ret = xioctl(m_fd, VIDIOC_QUERYBUF, &buf);
        if (-1 == ret)
        {
            printf("[ERROR] VIDIOC_QUERYBUF Failed: %d\n", ret);
            return -1;
        }

    }
    imageLength = buf.length;

    return 0;
}

/**
 * @brief save_bin
 * @details  Get the capture image from buffer and save it into binary file
 * @param filename binary file name to be saved
 * @return int8_t  0 if succeeded
*                 not 0 otherwise
 */
int8_t Camera::save_bin(std::string filename)
{
    int8_t ret = 0;
    FILE* fp = fopen(filename.c_str(), "wb");
    if (!fp)
    {
        return -1;
    }

    /* Get data from buffer and write to binary file */
    ret = fwrite(buffer[buf_capture.index], sizeof(uint8_t), imageLength, fp);
    if (!ret)
    {
        fclose(fp);
        return -1;
    }

    fclose(fp);
    return 0;
}


/**
 * @brief get_buf_capture_index
 * @details Function to return the camera buffer index
 * @return int8_t  camera buffer index
 */
int8_t Camera::get_buf_capture_index()
{
    return buf_capture.index;
}

/**
 * @brief get_inference_buf_capture_index
 * @details Function to return the inference camera buffer index
 * @return int8_t inference camera buffer index
 */
int8_t Camera::get_inference_buf_capture_index()
{
    return inference_buf_capture.index;
}


/**
 * @brief sync_inference_buf_capture
 * @details Function to sync the camera buffer and the inference camera buffer
 */
void Camera::sync_inference_buf_capture()
{
    _using_inf = true;
    inference_buf_capture = buf_capture;
    return;
}

/**
 * @brief inference_capture_qbuf
 * @details  Function to enqueue the inference buffer.
 *                 (Call this function at the end of the inference thread to 
 *                  restart filling image data into buffer)
 * @return int8_t  0 if succeeded
*                 not 0 otherwise
 */
int8_t Camera::inference_capture_qbuf()
{
    int8_t ret = 0;

    ret = xioctl(m_fd, VIDIOC_QBUF, &inference_buf_capture);
    if (-1 == ret)
    {
        return -1;
    }
    _using_inf = false;

    return 0;
}

void rgb_to_yuv422_uyvy(const cv::Mat& rgb, cv::Mat& yuv) {
    assert(rgb.size() == yuv.size() &&
           rgb.depth() == CV_8U &&
           rgb.channels() == 3 &&
           yuv.depth() == CV_8U &&
           yuv.channels() == 2);
    for (int ih = 0; ih < rgb.rows; ih++) {
        const uint8_t* rgbRowPtr = rgb.ptr<uint8_t>(ih);
        uint8_t* yuvRowPtr = yuv.ptr<uint8_t>(ih);

        for (int iw = 0; iw < rgb.cols; iw = iw + 2) {
            const int rgbColIdxBytes = iw * rgb.elemSize();
            const int yuvColIdxBytes = iw * yuv.elemSize();

            const uint8_t R1 = rgbRowPtr[rgbColIdxBytes + 0];
            const uint8_t G1 = rgbRowPtr[rgbColIdxBytes + 1];
            const uint8_t B1 = rgbRowPtr[rgbColIdxBytes + 2];
            const uint8_t R2 = rgbRowPtr[rgbColIdxBytes + 3];
            const uint8_t G2 = rgbRowPtr[rgbColIdxBytes + 4];
            const uint8_t B2 = rgbRowPtr[rgbColIdxBytes + 5];

            const int Y  =  (0.257f * R1) + (0.504f * G1) + (0.098f * B1) + 16.0f ;
            const int U  = -(0.148f * R1) - (0.291f * G1) + (0.439f * B1) + 128.0f;
            const int V  =  (0.439f * R1) - (0.368f * G1) - (0.071f * B1) + 128.0f;
            const int Y2 =  (0.257f * R2) + (0.504f * G2) + (0.098f * B2) + 16.0f ;

            yuvRowPtr[yuvColIdxBytes + 0] = cv::saturate_cast<uint8_t>(Y );
            yuvRowPtr[yuvColIdxBytes + 1] = cv::saturate_cast<uint8_t>(U );
            yuvRowPtr[yuvColIdxBytes + 2] = cv::saturate_cast<uint8_t>(Y2);
            yuvRowPtr[yuvColIdxBytes + 3] = cv::saturate_cast<uint8_t>(V );
        }
    }
}

/**
 * @brief get_img
 * @details Function to return the camera buffer
 * @return uint8_t* camera buffer
 */
uint8_t* Camera::get_img()
{
    static int last_index = -1;
    if (!adjust_img || last_index == buf_capture.index)
        return buffer[buf_capture.index];

    cv::Mat orig(in_height, in_width, CV_8UC2, buffer[buf_capture.index]);
    cv::Mat origRgb;
    cv::cvtColor(orig, origRgb, cv::COLOR_YUV2RGB_YUYV);

    cv::Mat scaled;
    cv::resize(origRgb, scaled, cv::Size(scale_width, scale_height));
    auto cropped = scaled(crop_region);

    cv::Mat final_out(out_height, out_width, CV_8UC2, buffer[buf_capture.index]);

    rgb_to_yuv422_uyvy(cropped, final_out);

    last_index = buf_capture.index;

    return buffer[buf_capture.index];
}


/**
 * @brief get_size
 * @details Function to return the camera buffer size (W x H x C)
 * @return int32_t camera buffer size (W x H x C )
 */
int32_t Camera::get_size()
{
    return imageLength;
}


/**
 * @brief set_w
 * @details Set out_width. This function is currently NOT USED.
 * @param w new camera capture image width
 */
void Camera::set_w(int32_t w)
{
    out_width = w;
    return;
}


/**
 * @brief set_h
 * @details Set out_height. This function is currently NOT USED.
 * @param h new camera capture image height
 */
void Camera::set_h(int32_t h)
{
    out_height = h;
    return;
}


/**
 * @brief set_c
 * @details Set camera_color. This function is currently NOT USED.
 * @param c new camera capture image color channel
 */
void Camera::set_c(int32_t c)
{
    camera_color = c;
    return;
}
