# Team Rython: Dainius Masiliunas and Tim Weerman
# Date: January 2016
# License: Apache License 2.0

library(bfastSpatial)
library(parallel)

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
datum = cleanMODIS(filename, 2, 3, bit = TRUE, QC_val=filtermask, fill=fillnumber)
full = raster("HDF4_EOS:EOS_GRID:data/MCD15A2H.A2015201.h19v03.006.2015304024904.hdf:MOD_Grid_MOD15A2H:Lai_500m", as.is = TRUE)
QA = raster("HDF4_EOS:EOS_GRID:data/MCD15A2H.A2015201.h19v03.006.2015304024904.hdf:MOD_Grid_MOD15A2H:FparLai_QC", as.is = TRUE)
# Test by plotting
plot(cleanMODIS(filename, 2, 3, bit = TRUE, QC_val=0x8C, fill=249:255), colNA="black") # Filtered
# Process (we'll mask unneeded pixels out later, dealing with HDF4 is a real pain)
processMODISbatch("data", pattern=glob2rx("*.hdf"), 2, 3, bit=TRUE, QC_val=0x8C, fill=249:255, outdir="data/processed", mc.cores=4)

# Stack layers
s <- timeStackMODIS(x="data/processed", pattern=glob2rx("*.tif"), filename=file.path("data/stack", 'Stack.grd'), datatype='INT1U', overwrite=TRUE, progress="text")

# Create annual summary statistics: mean, median, 3rd quartile, max
years = 2002:2015
system.time(annualMed <- annualSummary(s, fun=median, na.rm=TRUE, mc.cores=4, filename="data/yearly/AnnualMedian.grd", progress="text"))
names(annualMed) = years
plot(annualMed)
system.time(annualAvg <- annualSummary(s, fun=mean, na.rm=TRUE, mc.cores=4, filename="data/yearly/AnnualAverage.grd", progress="text"))
plot(annualAvg)
quartile3 = function(...) quantile(..., probs=c(0.75))[[1]]
system.time(annualQrt75 <- annualSummary(s, fun=quartile3, na.rm=TRUE, mc.cores=4, filename="data/yearly/AnnualQuartile75.grd", progress="text"))
plot(annualQrt75)
quantile90 = function(...) quantile(..., probs=c(0.90))[[1]]
system.time(annualQnt90 <- annualSummary(s, fun=quantile90, na.rm=TRUE, mc.cores=4, filename="data/yearly/AnnualQuantile90.grd", progress="text"))
names(annualQnt90) = years
plot(annualQnt90)
system.time(annualMax <- annualSummary(s, fun=max, na.rm=TRUE, mc.cores=4, filename="data/yearly/AnnualMax.grd", progress="text"))
plot(annualMax)

# Run in parallel, one statistic per core
tasklist = list(
    annualMed <- annualSummary(s, fun=median, na.rm=TRUE, filename="data/yearly/AnnualMedian.grd", progress="text")
    annualAvg <- annualSummary(s, fun=mean, na.rm=TRUE, filename="data/yearly/AnnualAverage.grd", progress="text")
    annualQrt75 <- annualSummary(s, fun=quartile3, na.rm=TRUE, filename="data/yearly/AnnualQuartile75.grd", progress="text")
    annualMax <- annualSummary(s, fun=max, na.rm=TRUE, filename="data/yearly/AnnualMax.grd", progress="text")
)

stats <- mclapply(tasklist, function(f) f(), mc.cores = 4)
