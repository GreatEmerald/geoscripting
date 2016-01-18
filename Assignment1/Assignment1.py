# Assignment 1
# 18 January 2016
# Team Rython - Dainius Masiliunas - Tim Weerman
# Apache license 2.0

# Import packages
import os,os.path
import mapnik

# Set working directory
####### Change this for your own system #######
# os.chdir('YOURWORKINGDIRECTORY')
os.chdir('/home/tim/geoscripting/Assignment1')
print os.getcwd()

os.chdir('data')

# Loading osgeo
try:
  from osgeo import ogr, osr
  print 'Import of ogr and osr from osgeo worked.  Hurray!\n'
except:
  print 'Import of ogr and osr from osgeo failed\n\n'
  
# Load driver
driverName = "ESRI Shapefile"
drv = ogr.GetDriverByName( driverName )
    
# Set layer name and file name
fn = "map.shp"
layername = "locations"

# Create shape file
ds = drv.CreateDataSource(fn)
print ds.GetRefCount()

# Set spatial reference
spatialReference = osr.SpatialReference()
spatialReference.ImportFromProj4('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs')

# Create Layer
layer=ds.CreateLayer(layername, spatialReference, ogr.wkbPoint)
layerDefinition = layer.GetLayerDefn()

# Make a coordinate list
coordinate_list = [[5.655246,51.989645,  "exportfile1.kml"], \
                    [6.552223,53.212979, "exportfile2.kml"]]

# For loop to go through the points within the coordinate list
for coordinates in coordinate_list:
    point = ogr.Geometry(ogr.wkbPoint)
    point.SetPoint(0, coordinates[0], coordinates[1]) 
    feature = ogr.Feature(layerDefinition)
    feature.SetGeometry(point)
    layer.CreateFeature(feature)
    # Here a .kml file is created per point from the coordinate list
    f = open(coordinates[2], "w+")
    f.write("<Placemark>" + point.ExportToKML() + "</Placemark>")
    f.close()

print "The new extent"
print layer.GetExtent()

# Saving the object by destroying it
ds.Destroy()

# Set working directory
os.chdir('..')

# File with symbol for point
file_symbol=os.path.join("figs","mm_20_white.png")

# Create a map
map = mapnik.Map(800, 400) #This is the image final image size

# Background for the map
map.background = mapnik.Color("steelblue")

# Create the rule and style obj
r = mapnik.Rule()
s = mapnik.Style()

# Set the land polygone
polyStyle= mapnik.PolygonSymbolizer(mapnik.Color("darkred"))
pointStyle = mapnik.PointSymbolizer(mapnik.PathExpression(file_symbol))
r.symbols.append(polyStyle)
r.symbols.append(pointStyle)

s.rules.append(r)
map.append_style("mapStyle", s)

# Adding point layer
layerPoint = mapnik.Layer("pointLayer")
layerPoint.datasource = mapnik.Shapefile(file=os.path.join("data","map.shp"))

layerPoint.styles.append("mapStyle")

# Adding polygon
layerPoly = mapnik.Layer("polyLayer")
layerPoly.datasource = mapnik.Shapefile(file=os.path.join("data","ne_110m_land.shp"))
layerPoly.styles.append("mapStyle")

# Add layers to map
map.layers.append(layerPoly)
map.layers.append(layerPoint)

# Set boundaries for the Netherlands
boundsLL = (5 , 51, 7, 54.5) #(minx, miny, maxx,maxy)
map.zoom_to_box(mapnik.Box2d(*boundsLL)) # zoom to bbox

mapnik.render_to_file(map, os.path.join("figs","map3.png"), "png")
print "All done - check content"

# Deleting the created shapefiles (map.shp etc.)
os.system('./clean.sh')