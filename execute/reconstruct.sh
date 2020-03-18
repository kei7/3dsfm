#!/bin/bash

##setup
. ./setup.txt
##file preparation
if [ -d ${MVGBUILDMAIN}/${MVGEXEC}/input ];then
  echo "directory exists"
else
  mkdir ${MVGBUILDMAIN}/${MVGEXEC}/input
fi

#openmvs change data
${MVSBUILDMAIN}/DensifyPointCloud ${MVGBUILDMAIN}/${MVGEXEC}/input/${IMGDIRNAME}/out/reconstruction_sequential/scene.mvs
#mesh reconstruction
${MVSBUILDMAIN}/ReconstructMesh ${MVGBUILDMAIN}/${MVGEXEC}/input/${IMGDIRNAME}/out/reconstruction_sequential/scene_dense.mvs
