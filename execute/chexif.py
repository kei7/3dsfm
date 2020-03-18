import pyexiv2
import glob
import os,sys

#SRC_DIR = "/mnt/Omer/Project/04.ExTRaMapping/ModelData/Data/1990522-1/"
#OUT_DIR = "/mnt/Omer/Project/04.ExTRaMapping/ModelData/Data/1990522-1/"
TARGET_DIR = "/home/repos/openMVG_build/software/SfM/input/{0}/images".format(sys.argv[2])
#REFDIR = "/mnt/Omer/Project/13.3DReconstruct/Data/Test/3dmorph/20190821/dat"
REFDIR = "{0}".format(sys.argv[1])
if __name__=="__main__":
    ## smart phone

    filesSO = sorted(glob.glob(os.path.join(TARGET_DIR,"H*.jpg")))
    filesOPTA = sorted(glob.glob(os.path.join(TARGET_DIR,"OPTA*.jpg")))
    filesOPTB = sorted(glob.glob(os.path.join(TARGET_DIR,"OPTB*.jpg")))
    filesOPTC = sorted(glob.glob(os.path.join(TARGET_DIR,"OPTC*.jpg")))
    files1 = sorted(glob.glob(os.path.join(REFDIR,"refim*.jpg")))
    fi1 = files1[0]
    meta1 = pyexiv2.ImageMetadata(fi1)
    meta1.read()
    for i,fi in enumerate(filesSO):
        data = pyexiv2.ImageMetadata(fi)
        data.read()
        data["Exif.Image.Model"] = "SO-01K"
        data["Exif.Photo.FocalLength"] = meta1["Exif.Photo.FocalLength"].value
        data["Exif.Photo.PixelXDimension"] = 1920#meta1["Exif.Photo.PixelXDimension"]
        data["Exif.Photo.PixelYDimension"] = 1080#meta1["Exif.Photo.PixelYDimension"]
        data.write()
    #High speed camera metadata write
    for i,fi in enumerate(filesOPTA):
        data = pyexiv2.ImageMetadata(fi)
        data.read()
        data["Exif.Image.Model"] = "SA4-512A"
        data["Exif.Photo.FocalLength"] = meta1["Exif.Photo.FocalLength"].value
        data["Exif.Photo.PixelXDimension"] = 512
        data["Exif.Photo.PixelYDimension"] = 512
        data.write()
    for i,fi in enumerate(filesOPTB):
        data = pyexiv2.ImageMetadata(fi)
        data.read()
        data["Exif.Image.Model"] = "SA4-512B"
        data["Exif.Photo.FocalLength"] = meta1["Exif.Photo.FocalLength"].value
        data["Exif.Photo.PixelXDimension"] = 512
        data["Exif.Photo.PixelYDimension"] = 512
        data.write()
    for i,fi in enumerate(filesOPTC):
        data = pyexiv2.ImageMetadata(fi)
        data.read()
        data["Exif.Image.Model"] = "Mini-512C"
        data["Exif.Photo.FocalLength"] = meta1["Exif.Photo.FocalLength"].value
        data["Exif.Photo.PixelXDimension"] = 512
        data["Exif.Photo.PixelYDimension"] = 512
        data.write()
