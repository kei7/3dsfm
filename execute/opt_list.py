import pyexiv2
import glob
import os,sys,re

TARGET_DIR = "/home/repos/openMVG_build/software/SfM/input/{0}/opt2".format(sys.argv[2])
REFDIR = "{0}/install/install/".format(sys.argv[1])
if __name__=="__main__":

    ## smart phone

    files = sorted(glob.glob(os.path.join(TARGET_DIR,"OPTA*.jpg")))
    str_ = '\n'.join(files)
    with open("./opt_list.txt", 'wt') as f:
        f.write(str_)
    files_ = []
    for i,file in enumerate(files):
        files_.append(file[-10:-4])
    str_ = "\n".join(files_)
    with open("./opt_list_sw_new.txt","wt") as f:
        f.write(str_)
