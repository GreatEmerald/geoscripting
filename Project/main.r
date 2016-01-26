# Team Rython: Dainius Masiliunas and Tim Weerman
# Date: January 2016
# License: Apache License 2.0

library(bfastSpatial)
library(parallel)
library(lattice)

source("src/GenerateAnnualSummary.r")
source("src/ImportStatistics.r")
source("src/SanitiseInput.r")

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
s = stack("data/stack/Stack.grd")

# Create annual summary statistics: mean, median, 3rd quartile, max
years = 2002:2015
AnnualMed = GenerateAnnualSummary("data/yearly/AnnualMedian.grd", median)
names(AnnualMed) = years
plot(AnnualMed)
AnnualAvg = GenerateAnnualSummary("data/yearly/AnnualAverage.grd", mean)
names(AnnualAvg) = years
plot(AnnualAvg)
quartile3 = function(...) quantile(..., probs=c(0.75))[[1]]
AnnualQrt75 = GenerateAnnualSummary("data/yearly/AnnualQuartile75.grd", quartile3)
names(AnnualQrt75) = years
plot(AnnualQrt75)
quantile90 = function(...) quantile(..., probs=c(0.90))[[1]]
AnnualQnt90 = GenerateAnnualSummary("data/yearly/AnnualQuantile90.grd", quantile90)
names(AnnualQnt90) = years
plot(AnnualQnt90)
AnnualMax = GenerateAnnualSummary("data/yearly/AnnualMax.grd", max)
names(AnnualMax) = years
plot(AnnualMax)

# Run in parallel, one statistic per core
tasklist = list(
    annualMed <- function() annualSummary(s, fun=median, na.rm=TRUE, filename="data/yearly/AnnualMedian.grd", progress="text"),
    annualAvg <- function() annualSummary(s, fun=mean, na.rm=TRUE, filename="data/yearly/AnnualAverage.grd", progress="text"),
    annualQrt75 <- function() annualSummary(s, fun=quartile3, na.rm=TRUE, filename="data/yearly/AnnualQuartile75.grd", progress="text"),
    annualMax <- function() annualSummary(s, fun=max, na.rm=TRUE, filename="data/yearly/AnnualMax.grd", progress="text")
)
system.time(stats <- mclapply(tasklist, function(f) f(), mc.cores = 4))

# Create a base raster to render
Summary = summaryBrick(s, fun=mean)

# Extract mean of the different statistics at different administrative units
LTU0 = getData("GADM", country="LTU", path="data", level=0)
LTU2 = getData("GADM", country="LTU", path="data", level=2)

LAILTU0 = extract(AnnualAvg, LTU0, fun=mean, df=TRUE, na.rm=TRUE)
save(LAILTU0, file="output/dataframes/LAILTU0.Rda")
plot(unlist(LAILTU)[-1]~years)
LAILTU2 = extract(AnnualAvg, LTU2, fun=mean, df=TRUE, na.rm=TRUE)
save(LAILTU2, file="output/dataframes/LAILTU2.Rda")
LAILTU2 = cbind(LAILTU2, LTU2@data$VARNAME_2)
plot(LAILTU2)

LAILTU = reshape(LAILTU2, direction="long", varying=list(names(LAILTU2)[2:15]), idvar="LTU2@data$VARNAME_2", v.names="LAI", timevar="Year", times=years)
names(LAILTU) = c("ID", "Municipality", "Year", "LAI")

# Read statistics from the government
statistics = ImportStatistics()

# Merge the two data frames into one
SanitiseNames(LAILTU[["Municipality"]])
