# Team Rython, Dainius Masiliunas and Tim Weerman
# Date: 11 January, 2016
# Apache License 2.0

# Needed packages
library(rgdal) # OGR functions
library(rgeos) # g functions

# Download the data
download.file("http://www.mapcruzin.com/download-shapefile/netherlands-places-shape.zip", method="wget", destfile="data/places.zip")
download.file("http://www.mapcruzin.com/download-shapefile/netherlands-railways-shape.zip", method="wget", destfile="data/railways.zip")
# Extract the data
unzip("data/places.zip", exdir="data")
unzip("data/railways.zip", exdir="data")
RailwaysFile = "data/railways.shp"
PlacesFile = "data/railways.shp"

# Import files
RailwaysSHP = readOGR(RailwaysFile, layer = ogrListLayers(RailwaysFile))
PlacesSHP = readOGR(PlacesFile, layer = ogrListLayers(PlacesFile))

# Transform into the Dutch national projection (else we can't buffer)
RDProj = CRS("+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.9999079 +x_0=155000 +y_0=463000 +ellps=bessel +towgs84=565.417,50.3319,465.552,-0.398957,0.343988,-1.8774,4.0725 +units=m +no_defs")
RailwaysSHP = spTransform(RailwaysSHP, RDProj)
PlacesSHP = spTransform(PlacesSHP, RDProj)

# Select industrial railways
IndustrialRails = subset(RailwaysSHP, type == "industrial")

# Buffer of a kilometre
RailSurroundings = gBuffer(IndustrialRails, byid = TRUE, width = 1000)
