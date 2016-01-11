# Team Rython, Dainius Masiliunas and Tim Weerman
# Date: 11 January, 2016
# Apache License 2.0

# Needed packages
library(rgdal) # OGR functions
library(rgeos) # g functions

source("src/OpenNetherlandsSHP.r")
source("src/PlotTownsNextToRailways.r")

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

# Choose one of:
levels(RailwaysSHP$type)

# Examples
PlotTownsNextToRailways(RailwaysSHP, PlacesSHP, "industrial")
PlotTownsNextToRailways(RailwaysSHP, PlacesSHP, "abandoned")
PlotTownsNextToRailways(RailwaysSHP, PlacesSHP, "disused")
PlotTownsNextToRailways(RailwaysSHP, PlacesSHP, "disused", Distance=200) # None, gives a warning
