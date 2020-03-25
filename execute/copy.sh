#!/bin/bash

. ./setup.txt
mkdir ${MVGBUILDMAIN}/${MVGEXEC}/input
#mkdir ${MVGBUILDMAIN}/${MVGEXEC}/input/${IMGDIRNAME}
cp -r ${INPUT} ${MVGBUILDMAIN}/${MVGEXEC}/input/
