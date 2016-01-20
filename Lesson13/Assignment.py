# Lesson 13, NDWI and reprojection in python
# Team Rython
# Dainius Masiliunas & Tim Weerman
# Apache license 2.0

# Import modules
import urllib
import os
from osgeo import gdal
from osgeo.gdalconst import GA_ReadOnly, GDT_Float32
import numpy as np

# Change working directory
os.getcwd()
#os.chdir("Yourworkingdirectory/geoscripting/Lesson13")
os.chdir("/home/tim/geoscripting/Lesson13")


# Download the file
urllib.urlretrieve("https://www.dropbox.com/s/zb7nrla6fqi1mq4/LC81980242014260-SC20150123044700.tar.gz?dl=1"), "data/Netherlands.tar.gz"


# Untar the file
filelist = ["LC81980242014260LGN00_sr_band4.tif", "LC81980242014260LGN00_sr_band5.tif"]

for filename in filelist:
   os.system("tar -zxvf data/Netherlands.tar.gz -C data " +filename)


def calculateNDWI(filename4, filename5, output):
    # Set
    dataSource4 = gdal.Open("data/" +filename4, GA_ReadOnly)
    dataSource5 = gdal.Open("data/" +filename5, GA_ReadOnly)

    # Save bands 4 & 5
    band4 = dataSource4.GetRasterBand(1).ReadAsArray(0,0,dataSource4.RasterXSize, dataSource4.RasterYSize).astype(np.float32)
    band5 = dataSource5.GetRasterBand(1).ReadAsArray(0,0,dataSource5.RasterXSize, dataSource5.RasterYSize).astype(np.float32)

    # Derive NDWI
    # Set np.errstate to avoid warning of invalid values (i.e. NaN values) in the divide 
    with np.errstate(divide='ignore'):
        ndwi = ((band4-band5)/(band4+band5))

    # Save the image
    driver = gdal.GetDriverByName('GTiff')
    outDataSet=driver.Create(output, dataSource4.RasterXSize, dataSource4.RasterYSize, 1, GDT_Float32)
    outBand = outDataSet.GetRasterBand(1)
    outBand.WriteArray(ndwi,0,0)
    outBand.SetNoDataValue(-99)

    # Set the projection and extent information of the dataset
    outDataSet.SetProjection(dataSource4.GetProjection())
    outDataSet.SetGeoTransform(dataSource4.GetGeoTransform())

    # Current projection is...
    print "\nInformation about " +output
    print '\nProjection is: ', outDataSet.GetProjection()

    outBand.FlushCache()
    outDataSet.FlushCache()

def reprojectNDWI(projinput, projoutput, projection):
    # Reprojection
    os.system("gdalwarp -t_srs " +projection +" " +projinput +" " +projoutput)

    # Current projection is...
    reprojected = gdal.Open(projoutput, GA_ReadOnly)
    print "\nInformation about the new reprojected file " +projoutput
    print '\nProjection is: ', reprojected.GetProjection()

calculateNDWI(filelist[0], filelist[1], "data/ndwi.tif")
reprojectNDWI("data/ndwi.tif", "data/ndwi_ll.tif", "'EPSG:4326'")

# End of the script
print "This is the end of the script, your image has been created."
