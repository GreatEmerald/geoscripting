# Team Rython: Dainius Masiliunas and Tim Weerman
# January 12, 2016
# Apache License 2.0

source("src/GetGreennessIndex.r")

# Get data

download.file("https://github.com/GeoScripting-WUR/VectorRaster/raw/gh-pages/data/MODIS.zip", destfile="data/modis.zip", method="wget")
unzip("data/modis.zip", exdir="data")

# Find the greenest city
# Visualise results
GetGreennessIndex(city, month, method)
