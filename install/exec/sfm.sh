#!/bin/bash

##edit this
MAKEMODEL_NAME="make_model"
IMGDIRPATH="/mnt/Omer/Project/04.ExTRaMapping/ModelData/heart_model"
IMGDIRNAME="heart_model"
##file preparation
mkdir ../openMVG/src/software/SFM/input
#cp ./model.py.in ./make_model.py.in
cat ./model.py.in | tr -c "@OPENMVG_SOFTWARE_SFM_SRC_DIR@" "/home/repos/openMVG_build/Linux-x86_64-RELEASE" > ./${MAKEMODEL_NAME}.py.in
cat ./${MAKEMODEL_NAME}.py.in | tr -c "@IMGSRC@" "${IMGDIRNAME}" > ./${MAKEMODEL_NAME}.py.in
mv ./${MAKEMODEL_NAME}.py.in ../openMVG/src/software/SFM/
cp -r -i ${IMGDIRPATH} ../openMVG/src/software/SFM/input/
cp -r -i ${IMGDIRPATH} ../openMVS_build/bin/undistorted_images/
#execute
python ../openMVG/src/software/SFM/${MAKEMODEL_NAME}.py.in
# data export 
../openMVG_build/Linux-x86_64-RELEASE/openMVG_main_openMVG2openMVS -i ../openMVG/src/software/SfM/${IMGDIRNAME}/out/reconstruction_sequential/sfm_data.bin -o ../openMVG/src/software/SfM/input/${IMGDIRNAME}/out/reconstruction_sequential/scene.mvs
#openmvs change data
../openMVS_build/bin/DensifyPointCloud ../openMVG/src/software/SfM/input/${IMGDIRNAME}/out/reconstruction_sequential/scene.mvs
#mesh reconstruction
../openMVS_build/bin/ReconstructMesh ../openMVG/src/software/SfM/input/${IMGDIRNAME}/out/reconstruction_sequential/scene_dense.mvs 
#texturemesh
../openMVS_build/bin/TextureMesh ../openMVG/src/software/SFM/input/${IMGDIRNAME}/out/reconstruction_sequential/scene_dense_mesh.mvs
mkdir ${IMGDIRPATH}/../AnalysisResult/${IMGDIRNAME}
cp ../openMVG/src/software/SFM/input/${IMGDIRNAME}/out/reconstruction_sequential/*.ply ${IMGDIRPATH}/../AnalysisResult/${IMGDIRNAME}/
