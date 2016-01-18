# Team Rython: Dainius Masiliunas and Tim Weerman
# Date: January 2016
# License: Apache License 2.0

library(bfastSpatial)

filelist = read.csv("data/data_url_script_2016-01-15_032836.txt")
filename = "data/MCD15A2H.A2002193.h19v03.006.2015149105839.hdf"

getMODISinfo(filename)
gdalinfo(filename)
# QC_val: 0x00 means keep everything, 0xFF means keep only if all are 0
# https://lpdaac.usgs.gov/dataset_discovery/modis/modis_products_table/mcd15a2
# http://www.binaryhexconverter.com/binary-to-hex-converter
datum = cleanMODIS(filename, 2, 3, bit = TRUE, QC_val=0x2C)
full = raster("HDF4_EOS:EOS_GRID:data/MCD15A2H.A2002193.h19v03.006.2015149105839.hdf:MOD_Grid_MOD15A2H:Lai_500m", as.is = TRUE)
QA = raster("HDF4_EOS:EOS_GRID:data/MCD15A2H.A2002193.h19v03.006.2015149105839.hdf:MOD_Grid_MOD15A2H:FparLai_QC", as.is = TRUE)
plot(cleanMODIS(filename, 2, 3, bit = TRUE, QC_val=0x04), colNA="black") # Pixel not produced
plot(cleanMODIS(filename, 2, 3, bit = TRUE, QC_val=0x08), colNA="black") # Clouds
plot(cleanMODIS(filename, 2, 3, bit = TRUE, QC_val=0x20), colNA="black") # Dead detectors
plot(cleanMODIS(filename, 2, 3, bit = TRUE, QC_val=0x40), colNA="black") # Only Terra
