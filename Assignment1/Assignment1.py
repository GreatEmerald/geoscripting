# Assignment 1
### Kaart projecteren
### Kaart in de layer zetten
### Punten op de kaart projecteren
### for loop

import os,os.path
import mapnik
os.chdir('/home/tim/geoscripting/Assignment1')
print os.getcwd()

os.chdir('data')

# Loading osgeo
try:
  from osgeo import ogr, osr
  print 'Import of ogr and osr from osgeo worked.  Hurray!\n'
except:
  print 'Import of ogr and osr from osgeo failed\n\n'
  
# Is the ESRI Shapefile driver available?
driverName = "ESRI Shapefile"
drv = ogr.GetDriverByName( driverName )
if drv is None:
    print "%s driver not available.\n" % driverName
else:
    print  "%s driver IS available.\n" % driverName
    
# choose your own name
# make sure this layer does not exist in your 'data' folder
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

coordinate_list = [[51.989645, 5.655246, "exportfile1.kml"], \
                    [53.212979, 6.552223, "exportfile2.kml"]]


for coordinates in coordinate_list:
    point = ogr.Geometry(ogr.wkbPoint)
    point.SetPoint(0, coordinates[0], coordinates[1]) 
    feature = ogr.Feature(layerDefinition)
    feature.SetGeometry(point)
    layer.CreateFeature(feature)
    f = open(coordinates[2], "w+")
    f.write(point.ExportToKML())
    f.close()

print "The new extent"
print layer.GetExtent()


os.chdir('/home/tim/geoscripting/Assignment1/')

#file with symbol for point
file_symbol=os.path.join("figs","mm_20_white.png")

#First we create a map
map = mapnik.Map(800, 400) #This is the image final image size

#Lets put some sort of background color in the map
map.background = mapnik.Color("steelblue") # steelblue == #4682B4 

#Create the rule and style obj
r = mapnik.Rule()
s = mapnik.Style()

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

#adding polygon
layerPoly = mapnik.Layer("polyLayer")
layerPoly.datasource = mapnik.Shapefile(file=os.path.join("data","ne_110m_land.shp"))
layerPoly.styles.append("mapStyle")

#Add layers to map
map.layers.append(layerPoly)
map.layers.append(layerPoint)

#Set boundaries 
boundsLL = (4 , 51, 7, 54.5) #(minx, miny, maxx,maxy)
map.zoom_to_box(mapnik.Box2d(*boundsLL)) # zoom to bbox

mapnik.render_to_file(map, os.path.join("figs","map3.png"), "png")
print "All done - check content"







ds.Destroy()
## below the output is shown of the above Python script that is run in the terminal

os.system('/home/tim/geoscripting/Assignment1/yesyesremove.sh')