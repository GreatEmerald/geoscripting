# Team Rython, Dainius Masiliunas and Tim Weerman
# Date: 11 January, 2016
# Apache License 2.0

# Needed packages
library(rgdal) # OGR functions
library(rgeos) # g functions

source("src/OpenNetherlandsSHP.r")

# Download the data
download.file("http://www.mapcruzin.com/download-shapefile/netherlands-places-shape.zip", method="wget", destfile="data/places.zip")
download.file("http://www.mapcruzin.com/download-shapefile/netherlands-railways-shape.zip", method="wget", destfile="data/railways.zip")
# Extract the data
unzip("data/places.zip", exdir="data")
unzip("data/railways.zip", exdir="data")
RailwaysFile = "data/railways.shp"
PlacesFile = "data/places.shp"

# Import files
RailwaysSHP = OpenNetherlandsSHP(RailwaysFile)
PlacesSHP = OpenNetherlandsSHP(PlacesFile)

# Select industrial railways
IndustrialRails = subset(RailwaysSHP, type == "industrial")

# Buffer of a kilometre
RailSurroundings = gBuffer(IndustrialRails, byid = TRUE, width = 1000)

# Find intersecting places
RailNeighbours = gIntersection(RailSurroundings, PlacesSHP, byid = TRUE)

# Plot
plot(RailSurroundings, axes=TRUE)
plot(IndustrialRails, add=TRUE, col="red")
plot(RailNeighbours, add=TRUE, pch=15)
