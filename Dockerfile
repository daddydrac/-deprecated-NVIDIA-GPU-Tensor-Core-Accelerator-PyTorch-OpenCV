FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04
ENV DEBIAN_FRONTEND noninteractive
# Core Linux Deps
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y --fix-missing --no-install-recommends apt-utils \
        build-essential \
        curl \
	binutils \
	gdb \
        git \
	freeglut3 \
	freeglut3-dev \
	libxi-dev \
	libxmu-dev \
	gfortran \
        pkg-config \
	python-numpy \
	python-dev \
	python-setuptools \
	libboost-python-dev \
	libboost-thread-dev \
        pbzip2 \
        rsync \
        software-properties-common \
        libboost-all-dev \
        libopenblas-dev \ 
        libtbb2 \
        libtbb-dev \
        libjpeg-dev \
        libpng-dev \
        libtiff-dev \
	libgraphicsmagick1-dev \
        libavresample-dev \
        libavformat-dev \
        libhdf5-dev \
        libpq-dev \
	libgraphicsmagick1-dev \
	libavcodec-dev \
	libgtk2.0-dev \
	liblapack-dev \
        liblapacke-dev \
	libswscale-dev \
	libcanberra-gtk-module \
        libboost-dev \
	libboost-all-dev \
        libeigen3-dev \
	wget \
        vim \
        qt5-default \
        unzip \
	zip \ 
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*  && \
    apt-get clean && rm -rf /tmp/* /var/tmp/*

ENV DEBIAN_FRONTEND noninteractive

# Install cmake version that supports anaconda python path
RUN wget -O cmake.tar.gz https://github.com/Kitware/CMake/releases/download/v3.15.4/cmake-3.15.4-Linux-x86_64.tar.gz
RUN tar -xvf cmake.tar.gz
WORKDIR /cmake-3.15.4-Linux-x86_64
RUN cp -r bin /usr/
RUN cp -r share /usr/
RUN cp -r doc /usr/share/
RUN cp -r man /usr/share/
WORKDIR /
RUN rm -rf cmake-3.15.4-Linux-x86_64
RUN rm -rf cmake.tar.gz


# Install TensorRT (TPU Access)
RUN apt-get update && \
        apt-get install -y nvinfer-runtime-trt-repo-ubuntu1804-5.0.2-ga-cuda10.0 && \
        apt-get update && \
        apt-get install -y libnvinfer5=5.0.2-1+cuda10.0

RUN file="$(ls -1 /usr/local/)" && echo $file


# Fix conda errors per Anaconda team until they can fix
RUN mkdir ~/.conda

# Install Anaconda
RUN wget --quiet https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
/bin/bash Miniconda3-latest-Linux-x86_64.sh -f -b -p /opt/conda && \
rm Miniconda3-latest-Linux-x86_64.sh
ENV PATH /opt/conda/bin:$PATH


# For CUDA profiling, TensorFlow requires CUPTI.
ENV LD_LIBRARY_PATH /usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH


ARG PYTHON=python3
ARG PIP=pip3


# See http://bugs.python.org/issue19846
ENV LANG C.UTF-8


RUN apt-get update && apt-get install -y \
    ${PYTHON} \
    ${PYTHON}-pip


RUN ${PIP} --no-cache-dir install --upgrade \
    pip \
    setuptools \
    hdf5storage \
    h5py \
    py3nvml \
    scikit-image \
    scikit-learn \
    matplotlib \
    pyinstrument

# Add auto-complete to Juypter
RUN pip install jupyter-tabnine
RUN pip install cupy-cuda101
RUN pip install mlflow 
RUN pip seldon-core 
RUN pip albumentations 
RUN pip networkx 
RUN pip jupyter-tabnine 
RUN pip shap 
RUN pip tensor-sensor 
RUN pip fastapi
RUN pip install torch-scatter==latest+cu101 -f https://pytorch-geometric.com/whl/torch-1.6.0.html
RUN pip install torch-sparse==latest+cu101 -f https://pytorch-geometric.com/whl/torch-1.6.0.html
RUN pip install torch-cluster==latest+cu101 -f https://pytorch-geometric.com/whl/torch-1.6.0.html
RUN pip install torch-spline-conv==latest+cu101 -f https://pytorch-geometric.com/whl/torch-1.6.0.html
RUN pip install torch-geometric

RUN conda update -n base -c defaults conda
RUN conda install -c anaconda jupyter 
RUN conda install pytorch torchvision cudatoolkit=10.0 -c pytorch
RUN conda update conda
RUN conda install numba
#RUN conda install -c anaconda cupy 
RUN conda install -c anaconda ipykernel 
RUN conda install -c anaconda seaborn 
RUN conda install -c anaconda ipython
#RUN conda install tensorflow-gpu
RUN conda install -c conda-forge tensorboard
RUN conda install captum -c pytorch
 

#RUN jupyter nbextension install --py jupyter_tabnine [--user|--sys-prefix|--system]
#RUN jupyter nbextension enable --py jupyter_tabnine [--user|--sys-prefix|--system]
#RUN jupyter serverextension enable --py jupyter_tabnine [--user|--sys-prefix|--system]

WORKDIR /
RUN wget -O opencv.zip https://github.com/opencv/opencv/archive/master.zip
RUN wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/master.zip
RUN unzip opencv.zip
RUN unzip opencv_contrib.zip
RUN mv opencv-master opencv
RUN mv opencv_contrib-master opencv_contrib
RUN mkdir /opencv/build
WORKDIR /opencv/build

RUN cmake -DBUILD_TIFF=ON \
		  -DBUILD_opencv_java=OFF \
		  -DWITH_CUDA=ON \
		  -DCUDA_ARCH_BIN=6.1 \
		  -DENABLE_FAST_MATH=1 \
		  -DCUDA_FAST_MATH=1 \
		  -DWITH_CUBLAS=1 \
		  -DENABLE_AVX=ON \
		  -DWITH_OPENGL=ON \
		  -DWITH_OPENCL=OFF \
		  -DWITH_IPP=ON \
		  -DWITH_TBB=ON \
		  -DWITH_EIGEN=ON \
		  -DWITH_V4L=ON \
		#   -DBUILD_TESTS=OFF \
		#   -DBUILD_PERF_TESTS=OFF \
		  -DCMAKE_BUILD_TYPE=RELEASE \
		  -DCMAKE_INSTALL_PREFIX=$(python -c "import sys; print(sys.prefix)") \
		  -D PYTHON3_EXECUTABLE=$(which python3) \
                  -D PYTHON_INCLUDE_DIR=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
                  -D PYTHON_INCLUDE_DIR2=$(python3 -c "from os.path import dirname; from distutils.sysconfig import get_config_h_filename; print(dirname(get_config_h_filename()))") \
                  -D PYTHON_LIBRARY=$(python3 -c "from distutils.sysconfig import get_config_var;from os.path import dirname,join ; print(join(dirname(get_config_var('LIBPC')),get_config_var('LDLIBRARY')))") \
                  -D PYTHON3_PACKAGES_PATH=$(python3 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") \
                  -DOPENCV_ENABLE_NONFREE=ON \
                  -DOPENCV_EXTRA_MODULES_PATH=/opencv_contrib/modules \
                  -DBUILD_EXAMPLES=ON \
                  -D CUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda-10.0 \
                  -DWITH_QT=ON ..
                 
RUN make -j4 \
        && make install \
	&& rm /opencv.zip \
        && rm /opencv_contrib.zip \
	&& rm -rf /opencv \
        && rm -rf /opencv_contrib


WORKDIR /

# dlib
RUN cd ~ && \
    mkdir -p dlib && \
    git clone -b 'v19.16' --single-branch https://github.com/davisking/dlib.git dlib/ && \
    cd  dlib/ && \
    python3 setup.py install --yes USE_AVX_INSTRUCTIONS --yes DLIB_USE_CUDA --clean


WORKDIR /app
EXPOSE 8888 6006

# Better container security versus running as root
RUN useradd -ms /bin/bash container_user


CMD ["bash", "-c", "source /etc/bash.bashrc && jupyter notebook --notebook-dir=/app --ip 0.0.0.0 --no-browser --allow-root --NotebookApp.custom_display_url='http://localhost:8888'"]
