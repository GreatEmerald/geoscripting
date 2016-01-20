# Lesson 13, NDWI and reprojection in python
# Team Rython
# Dainius Masiliunas & TIm Weerman
# Apache license 2.0

# Import modules
import urllib
import os
from osgeo import gdal, ogr, osr


# Change working directory
os.getcwd()
os.chdir("/home/tim/geoscripting/Lesson13")
#os.chdir("Yourworkingdirectory/geoscripting/Lesson13")


# Download the file
urllib.urlretrieve("https://www.dropbox.com/s/zb7nrla6fqi1mq4/LC81980242014260-SC20150123044700.tar.gz?dl=1"), "data/Netherlands.tar.gz"


# Untar the file
filelist = ["LC81980242014260LGN00_sr_band4.tif", "LC81980242014260LGN00_sr_band5.tif"]

for filename in filelist:
    os.system("tar -zxvf data/Netherlands.tar.gz -C data " +filename)

#
dataSource4 = gdal.Open(filelist[0], GA_ReadOnly)
dataSource5 = gdal.Open(filelist[1], GA_ReadOnly)


# Save bands 4 & 5
band4 = dataSource4.GetRasterBand(1).ReadAsArray(0,0,dataSource4.RasterXSize, dataSource4.RasterYSize).astype(np.float32)
band5 = dataSource5.GetRasterBand(1).ReadAsArray(0,0,dataSource5.RasterXSize, dataSource5.RasterYSize).astype(np.float32)


# Derive NDWI
NDWI = ((band4 - band5) / (band4 + band5))


# Current projection is...
print "\nInformation about " + NDWI 
print '\nProjection is: ', dataSource.GetProjection()


# Save the image
driver = gdal.GetDriverByName('GTiff')
outDataSet=driver.Create('/data/ndwi.tif', dataSource4.RasterXSize, dataSource4.RasterYSize, 1, GDT_Float32)
outBand = outDataSet.GetRasterBand(1)
outBand.WriteArray(ndwi,0,0)


# Reprojection
## lat/long definition
source = osr.SpatialReference()
source.ImportFromEPSG(4326)

# http://spatialreference.org/ref/sr-org/6781/
# http://spatialreference.org/ref/epsg/28992/
target = osr.SpatialReference()
target.ImportFromEPSG(28992)

transform = osr.CoordinateTransformation(source, target)
point = ogr.CreateGeometryFromWkt("POINT (5.6660 -51.9872)")
point.Transform(transform)
print point.ExportToWkt()source = osr.SpatialReference()
source.ImportFromEPSG(4326)

# End of the script
print "This is the end of the script"
