#!/bin/bash
cp ../openMVG/src/software/SFM/make_heart.py.in ../openMVG/src/software/SFM/make_model.py.in
cat ../openMVG/src/software/SFM/make_model.py.in | tr -c "@OPENMVG_SOFTWARE_SFM_SRC_DIR" "/home/repos/openMVG_build/Linux-x86_64-RELEASE" > ../openMVG/src/software/SFM/make_model.py.in
python make_model.py.in
