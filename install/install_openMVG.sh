#!/bin/sh
cd ../openMVG_build
cmake -DCMAKE_BUILD_TYPE=RELEASE . ../openMVG/src/
make -j2
