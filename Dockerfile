# this docker file is not optimized
# there are likely many things in here that are unnecessary
FROM python:3.7.13-slim-buster@sha256:7f68918938e2777d4a86d6f7381fb351a4b441c4e3ef82927a13133d18a40329

RUN apt-get update \
  && apt-get install -y \
  build-essential \
  cmake \
  gfortran \
  git \
  graphicsmagick \
  wget \
  unzip \
  yasm \
  pkg-config \
  libavcodec-dev \
  liblapack-dev \
  libswscale-dev \
  libswscale-dev \
  libtbb2 \
  libtbb-dev \
  libgraphicsmagick1-dev \
  libgtk2.0-dev \
  libjpeg-dev \
  libpng-dev \
  libtiff-dev \
  libavformat-dev \
  libpq-dev \
  && rm -rf /var/lib/apt/lists/*

RUN pip install numpy

# opencv
WORKDIR /
ENV OPENCV_VERSION="4.1.1"
RUN wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip \
  && unzip ${OPENCV_VERSION}.zip \
  && mkdir /opencv-${OPENCV_VERSION}/cmake_binary \
  && cd /opencv-${OPENCV_VERSION}/cmake_binary \
  && cmake -DBUILD_TIFF=ON \
  -DBUILD_opencv_java=OFF \
  -DWITH_CUDA=OFF \
  -DWITH_OPENGL=ON \
  -DWITH_OPENCL=ON \
  -DWITH_IPP=ON \
  -DWITH_TBB=ON \
  -DWITH_EIGEN=ON \
  -DWITH_V4L=ON \
  -DBUILD_TESTS=OFF \
  -DBUILD_PERF_TESTS=OFF \
  -DCMAKE_BUILD_TYPE=RELEASE \
  -DCMAKE_INSTALL_PREFIX=$(python3.7 -c "import sys; print(sys.prefix)") \
  -DPYTHON_EXECUTABLE=$(which python3.7) \
  -DPYTHON_INCLUDE_DIR=$(python3.7 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
  -DPYTHON_PACKAGES_PATH=$(python3.7 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") \
  .. \
  && make install \
  && rm /${OPENCV_VERSION}.zip \
  && rm -r /opencv-${OPENCV_VERSION}

RUN ln -s \
  /usr/local/python/cv2/python-3.7/cv2.cpython-37m-x86_64-linux-gnu.so \
  /usr/local/lib/python3.7/site-packages/cv2.so

# dlib
RUN cd ~ && \
  mkdir -p dlib && \
  git clone -b 'v19.9' --single-branch https://github.com/davisking/dlib.git dlib/ && \
  cd  dlib/ && \
  python3 setup.py install --yes USE_AVX_INSTRUCTIONS

# uninstall
RUN apt-get autoremove

WORKDIR /faceswap

# add training data
COPY ./face_training.dat ./face_training.dat

# add script
COPY ./faceswap.py ./faceswap.py

ENTRYPOINT ["python3", "/faceswap/faceswap.py", "/temp/original.jpg"]
CMD ["/faces/5.jpg"]
