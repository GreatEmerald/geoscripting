import os
os.chdir('/home/tim/geoscripting/lesson11')
print os.getcwd()

os.chdir('data')

## Loading osgeo
try:
  from osgeo import ogr, osr
  print 'Import of ogr and osr from osgeo worked.  Hurray!\n'
except:
  print 'Import of ogr and osr from osgeo failed\n\n'

## Is the ESRI Shapefile driver available?
driverName = "ESRI Shapefile"
drv = ogr.GetDriverByName( driverName )
if drv is None:
    print "%s driver not available.\n" % driverName
else:
    print  "%s driver IS available.\n" % driverName

## choose your own name
## make sure this layer does not exist in your 'data' folder
fn = "testing.shp"
layername = "anewlayer"

## Create shape file
ds = drv.CreateDataSource(fn)
print ds.GetRefCount()

# Set spatial reference
spatialReference = osr.SpatialReference()
spatialReference.ImportFromProj4('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs')

# you can also do the following
# spatialReference.ImportFromEPSG(4326)

## Create Layer
layer=ds.CreateLayer(layername, spatialReference, ogr.wkbPoint)
## Now check your data folder and you will see that the file has been created!
## From now on it is not possible anymore to CreateDataSource with the same name
## in your workdirectory untill your remove the name.shp name.shx and name.dbf file.
print(layer.GetExtent())

## What is the geometry type???
## What does wkb mean??

## ok lets leave the pyramid top and start building the bottom,
## let's do points
## Create a point
point1 = ogr.Geometry(ogr.wkbPoint)
point2 = ogr.Geometry(ogr.wkbPoint)

## SetPoint(self, int point, double x, double y, double z = 0)
point1.SetPoint(0,1.0,1.0) 
point2.SetPoint(0,2.0,2.0)

## Actually we can do lots of things with points: 
## Export to other formats/representations:
print "KML file export"
print point2.ExportToKML()

## Buffering
buffer = point2.Buffer(4,4)
print buffer.Intersects(point1)

## More exports:
buffer.ExportToGML()

## Back to the pyramid, we still have no Feature
## Feature is defined from properties of the layer:e.g:

layerDefinition = layer.GetLayerDefn()
feature1 = ogr.Feature(layerDefinition)
feature2 = ogr.Feature(layerDefinition)

## Lets add the points to the feature
feature1.SetGeometry(point1)
feature2.SetGeometry(point2)

## Lets store the feature in a layer
layer.CreateFeature(feature1)
layer.CreateFeature(feature2)
print "The new extent"
print layer.GetExtent()

## So what is missing ????
## Saving the file, but OGR doesn't have a Save() option
## The shapefile is updated with all object structure 
## when the script finished of when it is destroyed, 
# if necessay SyncToDisk() maybe used

ds.Destroy()
## below the output is shown of the above Python script that is run in the terminal


# /home/tim/geoscripting/lesson11  ---  yesyesremove.sh
os.system('../yesyesremove.sh')

qgis.utils.iface.addVectorLayer(fn, layername, "ogr") 
aLayer = qgis.utils.iface.activeLayer()
print aLayer.name()

driverName = "ESRI Shapefile"
driver = ogr.GetDriverByName("ESRI Shapefile")
ds = driver.Open("testing.shp", 1)
## check layers and get the first layer
layernr = ds.GetLayerCount()
print layernr
layer = ds.GetLayerByIndex(0)
print layer

## get number of features in shapefile layer
features_number = layer.GetFeatureCount()
print "number of features for this layer:", features_number

## get the feature definition:
featureDefn = layer.GetLayerDefn()

## create a point
point = ogr.Geometry(ogr.wkbPoint)
point.SetPoint(0,2.0,1.0)
print point
## similarly 
## point.AddPoint(2,1)

## create a new feature
feature = ogr.Feature(featureDefn)
feature.SetGeometry(point)
# Lets store the feature in file
layer.CreateFeature(feature)
layer.GetExtent()
ds.Destroy()