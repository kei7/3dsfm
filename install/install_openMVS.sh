#!/bin/bash
#eigen
cd ..
#$main_path=`/home/repos`
cd eigen_build
cmake . ../eigen3.2
make -j2
make install
cd ..
#ceres
cd ceres_build
cmake . ../ceres-solver/ -DMINIGLOG=ON -DBUILD_TESTING=OFF -DBUILD_EXAMPLES=OFF
make -j2
make install
cd ..
#openMVS
cd openMVS_build
cmake . ../openMVS -DCMAKE_BUILD_TYPE=RELEASE -DVCG_ROOT="/home/repos/vcglib" -DBUILD_SHARED_LIBS=ON -DOpenMVS_USE_CUDA=OFF -DOpenMVS_USE_BREAKPAD=OFF
make -j2
make install
