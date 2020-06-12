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
                   graphviz-dev graphviz \
                   python-pyexiv2 \
                   python-numpy \
                   python-opencv
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
RUN git clone --recursive https://github.com/openMVG/openMVG.git /home/repos/openMVG
RUN git clone https://github.com/thunders82/openMVS.git /home/repos/openMVS
RUN cd /home/repos/openMVS && git checkout 6bdc5ecbf45b540d408ded4592191dd30c3f69cf

#RUN cd /home/repos/3dsfm/dev_mvg && /bin/bash link.sh
RUN git clone https://github.com/kei7/dev_mvg.git /home/repos/dev_mvg

RUN cp /home/repos/dev_mvg/main_ComputeMatches.cpp /home/repos/dev_mvg/main_IncrementalSfM.cpp /home/repos/openMVG/src/software/SfM/
#RUN cp /home/repos/dev_mvg/SceneTexture.cpp /home/repos/openMVS/libs/MVS

RUN mkdir /home/repos/openMVG_build
RUN cd /home/repos/openMVG_build && cmake -DCMAKE_BUILD_TYPE=RELEASE . ../openMVG/src/ && make -j2

#openMVS
#Prepare and empty machine for building:
#sudo apt-get update -qq && sudo apt-get install -qq
RUN cd /home/repos && main_path=`pwd`  
#Eigen (Required)
RUN hg clone https://bitbucket.org/eigen/eigen#3.2 /home/repos/eigen3.2
RUN mkdir /home/repos/eigen_build
RUN cd /home/repos/eigen_build && cmake . ../eigen3.2 && make -j2 && make install
#RUN cd ..

#VCGLib (Required)
RUN git clone https://github.com/cdcseacave/VCG.git /home/repos/vcglib

#Ceres (Required)
RUN git clone https://ceres-solver.googlesource.com/ceres-solver /home/repos/ceres-solver 
RUN mkdir /home/repos/ceres_build
RUN cd /home/repos/ceres-solver && git checkout ba62397d80b2d7d34c3cca5e75f1f154ad8e41bb
RUN cd /home/repos/ceres_build && cmake . ../ceres-solver -DMINIGLOG=ON -DBUILD_TESTING=OFF -DBUILD_EXAMPLES=OFF && make -j2 && make install
#RUN cd ..

#OpenMVS
#RUN git clone https://github.com/thunders82/openMVS.git /home/repos/openMVS
RUN cd /home/repos/openMVS && git checkout 6bdc5ecbf45b540d408ded4592191dd30c3f69cf
RUN cd /home/repos/dev_mvg && git fetch && git pull
RUN cp /home/repos/dev_mvg/SceneTexture.cpp /home/repos/openMVS/libs/MVS/
RUN mkdir /home/repos/openMVS_build
#RUN cd /home/repos/ && main_path='pwd'
#RUN cd /home/repos/openMVS_build && cmake . ../openMVS -DCMAKE_BUILD_TYPE=RELEASE -DVCG_ROOT="/home/repos/vcglib" -DBUILD_SHARED_LIBS=ON -DOpenMVS_USE_CUDA=OFF -DOpenMVS_USE_BREAKPAD=OFF && make -j2 && make install

#Install OpenMVS library (optional):

#RUN git clone https://github.com/kei7/execute_SfM /home/repos/exec_SfM
