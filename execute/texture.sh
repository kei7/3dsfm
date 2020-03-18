##setup
. ./setup.txt
##file preparation
if [ -d ${MVGBUILDMAIN}/${MVGEXEC}/input ];then
  echo "directory exists"
else
  mkdir ${MVGBUILDMAIN}/${MVGEXEC}/input
fi
#texturemesh
${MVSBUILDMAIN}/TextureMesh ${MVGBUILDMAIN}/${MVGEXEC}/input/${IMGDIRNAME}/out/reconstruction_sequential/scene_dense_mesh.mvs --mesh-file ${MVGBUILDMAIN}/${MVGEXEC}/input/${IMGDIRNAME}/out/reconstruction_sequential/scene_dense_mesh.ply

