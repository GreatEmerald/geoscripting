# Team Rython, Dainius Masiliunas and Tim Weerman
# Date: 11 January, 2016
# Apache License 2.0

library(rgdal)

# Imports a shapefile and reprojects it into the RD projection
OpenNetherlandsSHP = function(filename)
{
    input = readOGR(filename, layer = ogrListLayers(filename))
    return(spTransform(input, CRS("+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.9999079 +x_0=155000 +y_0=463000 +ellps=bessel +towgs84=565.417,50.3319,465.552,-0.398957,0.343988,-1.8774,4.0725 +units=m +no_defs")))
}
