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

# Reproject vector to raster CRS
NLadm = spTransform(NLadm, CRS(proj4string(ModisData)))

# Find the greenest city
# Visualise results

# How green is Wageningen?
GetGreennessIndex(ModisData, NLadm[NLadm@data$NAME_2 == "Wageningen",], 1:12)
GetGreennessIndex(ModisData, NLadm[NLadm@data$NAME_2 == "Wageningen",], 1)
GetGreennessIndex(ModisData, NLadm[NLadm@data$NAME_2 == "Wageningen",], 8)

# Get a list of indices
# This should work. But it doesn't.
sapply(NLadm, GetGreennessIndex, months = 1, NDVI = ModisData)
# Workaround!
# Note: a lot of data to process, this may take a while!
GreenRatings = sapply(seq_len(nrow(NLadm)), function(i) GetGreennessIndex(ModisData, NLadm[i,], 1))
Winner = which(GreenRatings == max(GreenRatings))
plot(NLadm[Winner,])
