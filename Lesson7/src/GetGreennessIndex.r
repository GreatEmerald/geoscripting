# Team Rython: Dainius Masiliunas and Tim Weerman
# January 12, 2016
# Apache License 2.0

library(rgdal)

GetGreennessIndex = function(NDVI, area, months)
{
    print(area)
    # Reproject vector to raster CRS
    area = spTransform(area, CRS(proj4string(NDVI)))
    # Mask everything aside from the wanted area
    NDVImask = mask(NDVI, area)
    return(mean(NDVImask[[months]]@data@values, na.rm=TRUE))
}
