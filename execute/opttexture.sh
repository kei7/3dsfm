#!/bin/bash
. ./setup.txt

python opt_list_sw.py /home/repos ${IMGDIRNAME}

mkdir /home/repos/install/install/${IMGDIRNAME}/opt_out

cat opt_list_sw_new.txt | while read line
do
  cp ${MVGBUILDMAIN}/${MVGEXEC}/input/${IMGDIRNAME}/opt/OPTA$line.jpg ${MVGBUILDMAIN}/${MVGEXEC}/input/${IMGDIRNAME}/images/OPTA000002.jpg
  cp ${MVGBUILDMAIN}/${MVGEXEC}/input/${IMGDIRNAME}/opt/OPTA$line.jpg ./undistorted_images/OPTA000002.jpg
  cp ${MVGBUILDMAIN}/${MVGEXEC}/input/${IMGDIRNAME}/opt/OPTB$line.jpg ${MVGBUILDMAIN}/${MVGEXEC}/input/${IMGDIRNAME}/images/OPTB000000.jpg
  cp ${MVGBUILDMAIN}/${MVGEXEC}/input/${IMGDIRNAME}/opt/OPTB$line.jpg ./undistorted_images/OPTB000000.jpg
  #cp ${MVGBUILDMAIN}/${MVGEXEC}/input/${IMGDIRNAME}/opt/$line.jpg ${MVSBUILDMAIN}/undistorted_images/${IMGDIRNAME}/images/OPTA0000001.jpg
  ${MVSBUILDMAIN}/TextureMesh ${MVGBUILDMAIN}/${MVGEXEC}/input/${IMGDIRNAME}/out/reconstruction_sequential/scene_dense_mesh.mvs --mesh-file ${MVGBUILDMAIN}/${MVGEXEC}/input/${IMGDIRNAME}/out/reconstruction_sequential/scene_dense_mesh.ply --re-texture 1
  mv ${MVGBUILDMAIN}/${MVGEXEC}/input/${IMGDIRNAME}/out/reconstruction_sequential/scene_dense_mesh_texture.ply /home/repos/install/install/${IMGDIRNAME}/opt_out_sw/scene_dense_mesh_texture_$line.ply
  mv ${MVGBUILDMAIN}/${MVGEXEC}/input/${IMGDIRNAME}/out/reconstruction_sequential/scene_dense_mesh_texture.png /home/repos/install/install/${IMGDIRNAME}/opt_out_sw/scene_dense_mesh_texture_$line.png
done 
