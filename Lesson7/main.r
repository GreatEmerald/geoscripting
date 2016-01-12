# Team Rython: Dainius Masiliunas and Tim Weerman
# January 12, 2016
# Apache License 2.0

library(raster)
source("src/GetGreennessIndex.r")
source("src/PlotGreenestCity.r")

# Clear the environment
rm(list = ls())
## NB: Make sure your working directory is in Lesson7
getwd()

# Get NDVI data
download.file("https://github.com/GeoScripting-WUR/VectorRaster/raw/gh-pages/data/MODIS.zip", destfile="data/modis.zip", method="wget")
unzip("data/modis.zip", exdir="data")
ModisData = brick(list.files("data", pattern=glob2rx('*.grd'), full.names=TRUE))

# Sanitise data
ModisData[ModisData < 0] = NA

# Get administrative data
NLadm <- getData('GADM', country='NLD', level=2, path="data")

# Reproject vector to raster CRS
NLadm = spTransform(NLadm, CRS(proj4string(ModisData)))

# Find the greenest city!
# Note: a lot of data to process, this may take a while!
FindGreenestCity(ModisData, NLadm, 1) # January
FindGreenestCity(ModisData, NLadm, 8) # August
FindGreenestCity(ModisData, NLadm, 1:12) # The whole year
