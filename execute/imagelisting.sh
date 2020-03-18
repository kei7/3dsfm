#!/bin/bash
##setup
. ./setup.txt
##file preparation
if [ -d ${MVGBUILDMAIN}/${MVGEXEC}/input ];then
  echo "directory exists"
else
  mkdir ${MVGBUILDMAIN}/${MVGEXEC}/input
fi
cat ./model.py.in | sed -e "s#@OPENMVG_SOFTWARE_SFM_BUILD_DIR@#/home/repos/openMVG_build/Linux-x86_64-RELEASE#g" -e "s#@OPENMVG_SOFTWARE_SFM_SRC_DIR@#/home/repos/openMVG/src/software/SfM#g" -e "s#@IMGSRC@#${IMGDIRNAME}#g" > ./${MAKEMODEL_NAME}.py
mv ./${MAKEMODEL_NAME}.py ${MVGBUILDMAIN}/${MVGEXEC}/
cat ./model2.py.in | sed -e "s#@OPENMVG_SOFTWARE_SFM_BUILD_DIR@#/home/repos/openMVG_build/Linux-x86_64-RELEASE#g" -e "s#@OPENMVG_SOFTWARE_SFM_SRC_DIR@#/home/repos/openMVG/src/software/SfM#g" -e "s#@IMGSRC@#${IMGDIRNAME}#g" > ./${MAKEMODEL_NAME}2.py
mv ./${MAKEMODEL_NAME}2.py ${MVGBUILDMAIN}/${MVGEXEC}/

#camera image sensor width copy
cp ./sensor_width_camera_database.txt /home/repos/openMVG/src/openMVG/exif/sensor_width_database/

#change exif
python ./chexif.py . ${IMGDIRNAME}

mkdir ${MVSBUILDMAIN}/undistorted_images/${IMGDIRNAME} 
cp -r ${MVGBUILDMAIN}/${MVGEXEC}/input/${IMGDIRNAME}/images ${MVSBUILDMAIN}/undistorted_images/${IMGDIRNAME}

python ${MVGBUILDMAIN}/${MVGEXEC}/${MAKEMODEL_NAME}.py
cp ${MVGBUILDMAIN}/${MVGEXEC}/input/${IMGDIRNAME}/out/matches/sfm_data.json .

