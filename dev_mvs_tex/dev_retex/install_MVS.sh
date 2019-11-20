#!/bin/bash
cd ..
#eigen
cd ..
#$main_path=`/home/repos`
#cd eigen_build
#cmake . ../eigen3.2
#make -j2
#make install
#cd ..
#ceres
#cd ceres_build
#cmake . ../ceres-solver/ -DMINIGLOG=ON -DBUILD_TESTING=OFF -DBUILD_EXAMPLES=OFF
#make -j2
#make install
#cd ..
#openMVS
cd /home/repos/openMVS_retexture_up_build
cmake . ../openMVS_retexture_up -DCMAKE_BUILD_TYPE=RELEASE -DVCG_ROOT="/home/repos/vcglib" -DBUILD_SHARED_LIBS=OFF -DOpenMVS_USE_CUDA=OFF -DOpenMVS_USE_BREAKPAD=OFF
make -j2
make install
