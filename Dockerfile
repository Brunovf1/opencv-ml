FROM nvidia/cuda:10.1-cudnn7-devel-ubuntu18.04

ENV OPENCV_VERSION="4.4.0"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install -y \
        build-essential \
        cmake \
        git \
        libgtk2.0-dev \
        pkg-config \
        libavcodec-dev \
        libavformat-dev \
        libswscale-dev \
        python3-dev \
        python3-pip \
        libtbb2 \
        libtbb-dev \
        libjpeg-dev \
        libpng-dev \
        libtiff-dev \
        libdc1394-22-dev \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip --no-cache-dir install --upgrade \
    pip \
    numpy \
    setuptools

RUN ln -s $(which python3) /usr/local/bin/python

WORKDIR /root

RUN git clone https://github.com/opencv/opencv.git \
    && git clone https://github.com/opencv/opencv_contrib.git

RUN mkdir /root/opencv/cmake_binary \
&& cd /root/opencv/cmake_binary \
&& cmake -DBUILD_TIFF=ON \
  -DBUILD_opencv_java=OFF \
  -DWITH_VTK=OFF \
  -DBUILD_opencv_viz=OFF \
  -DINSTALL_PYTHON_EXAMPLES=ON \
  -DOPENCV_ENABLE_NONFREE=ON \
  -DWITH_CUDA=ON \
  -DWITH_CUDNN=ON \
  -DOPENCV_DNN_CUDA=ON \
  -DENABLE_FAST_MATH=1 \
  -DCUDA_FAST_MATH=1 \
  -DWITH_CUBLAS=1 \
  -DWITH_OPENGL=ON \
  -DWITH_OPENCL=ON \
  -DWITH_IPP=ON \
  -DWITH_TBB=ON \
  -DWITH_EIGEN=ON \
  -DWITH_V4L=ON \
  -DBUILD_TESTS=OFF \
  -DBUILD_PERF_TESTS=OFF \
  -DCMAKE_BUILD_TYPE=RELEASE \
  -DBUILD_NEW_PYTHON_SUPPORT=ON \
  -DBUILD_opencv_python3=ON \
  -DOPENCV_EXTRA_MODULES_PATH=/root/opencv_contrib/modules \
  -DCMAKE_INSTALL_PREFIX=$(python -c "import sys; print(sys.prefix)") \
  -DPYTHON_EXECUTABLE=$(which python) \
  -DPYTHON_INCLUDE_DIR=$(python -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
  -DPYTHON_PACKAGES_PATH=$(python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") \
  .. \
&& make install \
&& rm -r /root/opencv \
&& rm -r /root/opencv_contrib

RUN python -m pip --no-cache-dir install --upgrade \
    tensorflow