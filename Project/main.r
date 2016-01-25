# Team Rython: Dainius Masiliunas and Tim Weerman
# Date: January 2016
# License: Apache License 2.0

library(bfastSpatial)

filelist = read.csv("data/data_url_script_2016-01-15_032836.txt")
filename = "data/MCD15A2H.A2015201.h19v03.006.2015304024904.hdf"
# Magic numbers!
filtermask = 0x8C # Filter out dead detectors, clouds, and non-produced pixels
fillnumber = 249:255

getMODISinfo(filename)
gdalinfo(filename)
# QC_val: 0x00 means keep everything, 0xFF means keep only if all are 0
# https://lpdaac.usgs.gov/dataset_discovery/modis/modis_products_table/mcd15a2
# http://www.binaryhexconverter.com/binary-to-hex-converter
datum = cleanMODIS(filename, 2, 3, bit = TRUE, QC_val=0x8C)
full = raster("HDF4_EOS:EOS_GRID:data/MCD15A2H.A2015201.h19v03.006.2015304024904.hdf:MOD_Grid_MOD15A2H:Lai_500m", as.is = TRUE)
QA = raster("HDF4_EOS:EOS_GRID:data/MCD15A2H.A2015201.h19v03.006.2015304024904.hdf:MOD_Grid_MOD15A2H:FparLai_QC", as.is = TRUE)
# Test by plotting
plot(cleanMODIS(filename, 2, 3, bit = TRUE, QC_val=0x8C, fill=249:255), colNA="black") # Filtered
# Process 
processMODISbatch("data", pattern=glob2rx("*.hdf"), 2, 3, bit=TRUE, QC_val=0x8C, fill=249:255, outdir="data/processed", mc.cores=4)

# Stack layers
stackName <- file.path("data/stack", 'stackTest.grd')
s <- timeStackMODIS(x="data/processed", pattern=glob2rx("*.tif"), filename=stackName, datatype='INT1U', overwrite=TRUE)

# Create annual summary statistics: mean, median, 3rd quartile, max
years = 2002:2015
annualMed <- annualSummary(s, fun=median, na.rm=TRUE, mc.cores=4, filename="data/processed/AnnualMedian.grd")
names(annualMed) = years
plot(annualMed)
annualAvg <- annualSummary(s, fun=mean, na.rm=TRUE, mc.cores=4, filename="data/processed/AnnualAverage.grd")
plot(annualAvg)
annualQrt75 <- annualSummary(s, fun=quantile, probs=c(0.75), na.rm=TRUE, mc.cores=4, filename="data/processed/AnnualQuartile75.grd")
plot(annualQrt75)
annualQnt90 <- annualSummary(s, fun=quantile, probs=c(0.90), na.rm=TRUE, mc.cores=4, filename="data/processed/AnnualQuantile90.grd")
names(annualQnt90) = years
plot(annualQnt90)
annualMax <- annualSummary(s, fun=max, na.rm=TRUE, mc.cores=4, filename="data/processed/AnnualMax.grd")
plot(annualMax)
