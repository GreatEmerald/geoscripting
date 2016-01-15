# Team Rython: Dainius Masiliunas and Tim Weerman
# Date: January 2016
# License: Apache License 2.0

library(rgeos)
library(rgdal)

filelist = read.csv("data/data_url_script_2016-01-15_032836.txt")

datum = readGDAL('NETCDF:"data/test.hdf":Lai_500m')
