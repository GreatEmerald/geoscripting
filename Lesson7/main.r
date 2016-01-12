# Team Rython: Dainius Masiliunas and Tim Weerman
# January 12, 2016
# Apache License 2.0

library(raster)
source("src/GetGreennessIndex.r")

# Get NDVI data
download.file("https://github.com/GeoScripting-WUR/VectorRaster/raw/gh-pages/data/MODIS.zip", destfile="data/modis.zip", method="wget")
unzip("data/modis.zip", exdir="data")
ModisData = brick(list.files("data", pattern=glob2rx('*.grd'), full.names=TRUE))

# Sanitise data
ModisData[ModisData < 0] = NA

# Get administrative data
NLadm <- getData('GADM', country='NLD', level=2, path="data")

# Find the greenest city
# Visualise results

# How green is Wageningen?
GetGreennessIndex(ModisData, NLadm[NLadm@data$NAME_2 == "Wageningen",], 1:12)
GetGreennessIndex(ModisData, NLadm[NLadm@data$NAME_2 == "Wageningen",], 1)
GetGreennessIndex(ModisData, NLadm[NLadm@data$NAME_2 == "Wageningen",], 8)

# Get a list of indices
apply(NLadm, 1, GetGreennessIndex, months = 1, NDVI = ModisData)
GetGreennessIndex(ModisData, NLadm[1:12,], 8)

for(idx in size())