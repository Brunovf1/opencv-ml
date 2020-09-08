FROM tensorflow/tensorflow:latest-gpu-py3

ENV OPENCV_VERSION="4.4.0"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install -y \
        build-essential \
        cmake \
        git \
        wget \
        unzip \
        yasm \
        pkg-config \
        libswscale-dev \
        libtbb2 \
        libtbb-dev \
        libjpeg-dev \
        libpng-dev \
        libtiff-dev \
        libdc1394-22-dev \
        libavcodec-dev \
        libavformat-dev \
        libswscale-dev \
        libpq-dev \
        libgstreamer-plugins-base1.0-dev \
        libgstreamer1.0-dev \
        libavresample-dev \
    && rm -rf /var/lib/apt/lists/*

RUN pip install numpy

WORKDIR /

RUN wget -nv https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.zip \
&& mv ${OPENCV_VERSION}.zip opencv_contrib.zip \
&& unzip opencv_contrib.zip

RUN wget -nv https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip \
&& unzip ${OPENCV_VERSION}.zip \
&& mkdir /opencv-${OPENCV_VERSION}/cmake_binary \
&& cd /opencv-${OPENCV_VERSION}/cmake_binary \
&& cmake -DBUILD_TIFF=ON \
  -DBUILD_opencv_java=OFF \
  -D WITH_VTK=OFF \
  -D BUILD_opencv_viz=OFF \
  # -DWITH_CUDA=ON \
  # -DCUDNN_INCLUDE_DIR=/usr/include \
  # -DCUDNN_LIBRARY=/usr/lib/x86_64-linux-gnu/libcudnn.so.7.6.4 \
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
  -DOPENCV_EXTRA_MODULES_PATH=/opencv_contrib-${OPENCV_VERSION}/modules \
  -DCMAKE_INSTALL_PREFIX=$(python -c "import sys; print(sys.prefix)") \
  -DPYTHON_EXECUTABLE=$(which python) \
  -DPYTHON_INCLUDE_DIR=$(python -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
  -DPYTHON_PACKAGES_PATH=$(python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") \
  .. \
&& make install \
&& rm /${OPENCV_VERSION}.zip  /opencv_contrib.zip \
&& rm -r /opencv-${OPENCV_VERSION} \
&& rm -r /opencv_contrib-${OPENCV_VERSION}


RUN ln -s \
  /usr/lib/python3.6/dist-packages/cv2/python-3.6/cv2.cpython-36m-x86_64-linux-gnu.so \
  /usr/lib/python3.6/dist-packages/cv2.so