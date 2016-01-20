# import modules
import os
from osgeo import gdal
from osgeo.gdalconst import GA_ReadOnly, GDT_Float32
import numpy as np

# open file and print info about the file
# the refers to the parent directory of my working directory
filename = 'data/aster.img'
dataSource = gdal.Open(filename, GA_ReadOnly)

print "\nInformation about " + filename 
print "Driver: ", dataSource.GetDriver().ShortName,"/", \
      dataSource.GetDriver().LongName
print "Size is ",dataSource.RasterXSize,"x",dataSource.RasterYSize, \
      'x',dataSource.RasterCount

print '\nProjection is: ', dataSource.GetProjection()

print "\nInformation about the location of the image and the pixel size:"
geotransform = dataSource.GetGeoTransform()
if geotransform is not None:
    print 'Origin = (',geotransform[0], ',',geotransform[3],')'
    print 'Pixel Size = (',geotransform[1], ',',geotransform[5],')'
    
# Read data into an array
band2Arr = dataSource.GetRasterBand(2).ReadAsArray(0,0,dataSource.RasterXSize, dataSource.RasterYSize)
band3Arr = dataSource.GetRasterBand(3).ReadAsArray(0,0,dataSource.RasterXSize, dataSource.RasterYSize)
print type(band2Arr)
                                                   

# set the data type
band2Arr=band2Arr.astype(np.float32)
band3Arr=band3Arr.astype(np.float32)

# Derive the NDVI
mask = np.greater(band3Arr+band2Arr,0)

# set np.errstate to avoid warning of invalid values (i.e. NaN values) in the divide 
with np.errstate(invalid='ignore'):
    ndvi = np.choose(mask,(-99,(band3Arr-band2Arr)/(band3Arr+band2Arr)))
print "NDVI min and max values", ndvi.min(), ndvi.max()
# Check the real minimum value
print ndvi[ndvi>-99].min()

# Write the result to disk
driver = gdal.GetDriverByName('GTiff')
outDataSet=driver.Create('data/ndvi.tif', dataSource.RasterXSize, dataSource.RasterYSize, 1, GDT_Float32)
outBand = outDataSet.GetRasterBand(1)
outBand.WriteArray(ndvi,0,0)
outBand.SetNoDataValue(-99)

# set the projection and extent information of the dataset
outDataSet.SetProjection(dataSource.GetProjection())
outDataSet.SetGeoTransform(dataSource.GetGeoTransform())


# Finally let's save it... or like in the OGR example flush it
outBand.FlushCache()
outDataSet.FlushCache()

os.system("gdalinfo data/ndvi.tif")

# via the Shell
os.system('gdalwarp -t_srs "EPSG:4326" data/ndvi.tif data/ndvi_ll.tif')

# Let's check what the result is
os.system('gdalinfo data/ndvi_ll.tif')


from osgeo import gdal
import matplotlib.pyplot as plt

# Open image
dsll = gdal.Open("data/ndvi_ll.tif")

# Read raster data
ndvi = dsll.ReadAsArray(0, 0, dsll.RasterXSize, dsll.RasterYSize)

# Now plot the raster data using gist_earth palette
plt.imshow(ndvi, interpolation='nearest', vmin=0, cmap=plt.cm.gist_earth)
plt.show()

dsll = None
