#!/bin/bash

##edit this
MAKEMODEL_NAME="make_model"
IMGDIRPATH="/mnt/Omer/Project/04.ExTRaMapping/ModelData"
IMGDIRNAME="heart_model"
MVGBUILDMAIN="/home/repos/openMVG_build/Linux-x86_64-RELEASE"
MVSBUILDMAIN="/home/repos/openMVS_build/bin"
MVGEXEC="../software/SfM"


##file preparation
mkdir ${MVGBUILDMAIN}/${MVGEXEC}/input
#cp ./model.py.in ./make_model.py.in
cat ./model.py.in | sed -e "s#@OPENMVG_SOFTWARE_SFM_BUILD_DIR@#/home/repos/openMVG_build/Linux-x86_64-RELEASE#g" -e "s#@OPENMVG_SOFTWARE_SFM_SRC_DIR#/home/repos/openMVG/src/software/SfM#g" -e "s#@IMGSRC@#${IMGDIRNAME}#g" > ./${MAKEMODEL_NAME}.py
mv ./${MAKEMODEL_NAME}.py ${MVGBUILDMAIN}/${MVGEXEC}/
cp -r ${IMGDIRPATH} ${MVGBUILDMAIN}/${MVGEXEC}/input/
cp -r ${IMGDIRPATH} ${MVSBUILDMAIN}/undistorted_images/
#execute
python ${MVGBUILDMAIN}/${MVGEXEC}/${MAKEMODEL_NAME}.py
# data export 
${MVGBUILDMAIN}/openMVG_main_openMVG2openMVS -i ${MVGBUILDMAIN}/${MVGEXEC}/input/${IMGDIRNAME}/out/reconstruction_sequential/sfm_data.bin -o ${MVGBUILDMAIN}/${MVGEXEC}/input/${IMGDIRNAME}/out/reconstruction_sequential/scene.mvs
#openmvs change data
${MVSBUILDMAIN}/DensifyPointCloud ${MVGBUILDMAIN}/${MVGEXEC}/input/${IMGDIRNAME}/out/reconstruction_sequential/scene.mvs
#mesh reconstruction
${MVSBUILDMAIN}/ReconstructMesh ${MVGBUILDMAIN}/${MVGEXEC}/input/${IMGDIRNAME}/out/reconstruction_sequential/scene_dense.mvs 
#texturemesh
${MVSBUILDMAIN}/TextureMesh ${MVGBUILDMAIN}/${MVGEXEC}/input/${IMGDIRNAME}/out/reconstruction_sequential/scene_dense_mesh.mvs
mkdir ${IMGDIRPATH}/../AnalysisResult/${IMGDIRNAME}
cp ${MVGBUILDMAIN}/${MVGEXEC}/input/${IMGDIRNAME}/out/reconstruction_sequential/*.ply ${IMGDIRPATH}/../AnalysisResult/${IMGDIRNAME}/
