# Team Rython, Dainius Masiliunas and Tim Weerman
# Date: 11 January, 2016
# Apache License 2.0

# Needed packages
library(rgdal)

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

# Select industrial railways
IndustrialRails = subset(RailwaysSHP, type == "industrial")