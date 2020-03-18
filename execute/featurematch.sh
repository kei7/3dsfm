#!/bin/bash

##Setup
. ./setup.txt
##file preparation
if [ -d ${MVGBUILDMAIN}/${MVGEXEC}/input ];then
  echo "directory exists"
else
  mkdir ${MVGBUILDMAIN}/${MVGEXEC}/input
fi

cat ./model2.py.in | sed -e "s#@OPENMVG_SOFTWARE_SFM_BUILD_DIR@#/home/repos/openMVG_build/Linux-x86_64-RELEASE#g" -e "s#@OPENMVG_SOFTWARE_SFM_SRC_DIR@#/home/repos/openMVG/src/software/SfM#g" -e "s#@IMGSRC@#${IMGDIRNAME}#g" > ./${MAKEMODEL_NAME}2.py
mv ./${MAKEMODEL_NAME}2.py ${MVGBUILDMAIN}/${MVGEXEC}/

cp ./sfm_data.json ${MVGBUILDMAIN}/${MVGEXEC}/input/${IMGDIRNAME}/out/matches/
python ${MVGBUILDMAIN}/${MVGEXEC}/${MAKEMODEL_NAME}2.py

# data export
${MVGBUILDMAIN}/${MVGRELEASE}/openMVG_main_openMVG2openMVS -i ${MVGBUILDMAIN}/${MVGEXEC}/input/${IMGDIRNAME}/out/reconstruction_sequential/sfm_data.bin -o ${MVGBUILDMAIN}/${MVGEXEC}/input/${IMGDIRNAME}/out/reconstruction_sequential/scene.mvs

