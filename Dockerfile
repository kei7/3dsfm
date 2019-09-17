FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu16.04

MAINTAINER asano <kei950120@gmail.com>

RUN echo "now building"

RUN apt-get update --fix-missing && apt-get -y install \
                   build-essential \
                   git vim curl wget zsh make ffmpeg wget bzip2 \
                   build-essential python python3 vim clang \
                   ca-certificates \
                   zlib1g-dev \
                   libssl-dev \
                   libbz2-dev \
                   libreadline-dev \
                   libsqlite3-dev \
                   libglib2.0-0 \
                   libgflags-dev\
                   libgoogle-glog-dev \
                   libxext6 \
                   libsm6 \
                   libxrender1 \
                   llvm \
                   libncurses5-dev \
                   libncursesw5-dev \
                   libpng-dev \
                   libjpeg-dev \
                   libtiff-dev \
                   libxxf86vm1 \
                   libxxf86vm-dev \
                   cmake \
                   libxrandr-dev \
                   libgtk2.0-0 \
                   mercurial \
                   subversion \
                   python-qt4 \
                   libatlas-base-dev libsuitesparse-dev \
                   libboost-dev libboost-iostreams-dev libboost-program-options-dev libboost-system-dev libboost-serialization-dev \
                   mercurial libglu1-mesa-dev libxmu-dev \
                   libopencv-dev \
                   libcgal-dev libcgal-qt5-dev \
                   freeglut3-dev libglew-dev libglfw3-dev \
                   libqt4-dev \
                   meshlab \
                   graphviz-dev graphviz
USER root
ENV HOME /root
#ENV NOTEBOOK_HOME /notebooks
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
#ENV PATH /opt/conda/bin:$PATH
RUN cd ~
#RUN git clone https://github.com/kei7/dotfiles.git
#RUN cd dotfiles
#RUN dotfiles/install.sh

#RUN mkdir /home/repos
#RUN cd /home/repos

#build openMVG
#RUN git clone --recursive https://github.com/openMVG/openMVG.git /home/repos/openMVG
#RUN mkdir /home/repos/openMVG_build
#&& cd openMVG_build
#RUN cmake -DCMAKE_BUILD_TYPE=RELEASE . ../openMVG/src/
#RUN make -j2

#openMVS
#Prepare and empty machine for building:
#sudo apt-get update -qq && sudo apt-get install -qq
#RUN cd /home/repos
#RUN main_path=`pwd`

#Eigen (Required)
#RUN hg clone https://bitbucket.org/eigen/eigen#3.2 /home/repos/eigen3.2
#RUN mkdir /home/repos/eigen_build
#&& cd eigen_build
#RUN cmake . ../eigen
#RUN make && make install
#RUN cd ..

#VCGLib (Required)
#RUN git clone https://github.com/cdcseacave/VCG.git /home/repos/vcglib

#Ceres (Required)
#RUN git clone https://ceres-solver.googlesource.com/ceres-solver /home/repos/ceres-solver
#RUN mkdir /home/repos/ceres_build
#&& cd ceres_build
#RUN cmake . ../ceres-solver/ -DMINIGLOG=ON -DBUILD_TESTING=OFF -DBUILD_EXAMPLES=OFF
#RUN make -j2 && make install
#RUN cd ..

#OpenMVS
#RUN git clone https://github.com/cdcseacave/openMVS.git /home/repos/openMVS
#RUN mkdir /home/repos/openMVS_build
#&& cd openMVS_build
#RUN cmake . ../openMVS -DCMAKE_BUILD_TYPE=RELEASE -DVCG_ROOT="($main_path)/vcglib" -DBUILD_SHARED_LIBS=ON -DOpenMVS_USE_CUDA=OFF -DOpenMVS_USE_BREAKPAD=OFF

#Install OpenMVS library (optional):
#RUN make -j2 && make install
#RUN git clone https://github.com/kei7/execute_SfM /home/repos/exec_SfM
