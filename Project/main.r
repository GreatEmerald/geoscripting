# Team Rython: Dainius Masiliunas and Tim Weerman
# Date: January 2016
# License: Apache License 2.0

library(bfastSpatial)
library(parallel)
library(lattice)

source("src/GenerateAnnualSummary.r")
source("src/ImportStatistics.r")
source("src/SanitiseInput.r")
source("src/ExtractWithinBorders.r")

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
# These are not in a loop, because it takes a LONG time to calculate each step!
years = 2002:2015
AnnualMed = GenerateAnnualSummary("data/yearly/AnnualMedian.grd", median, dates=getMODISinfo(names(s))$date)
names(AnnualMed) = years
plot(AnnualMed)
AnnualAvg = GenerateAnnualSummary("data/yearly/AnnualAverage.grd", mean, dates=getMODISinfo(names(s))$date)
names(AnnualAvg) = years
plot(AnnualAvg)
quartile3 = function(...) quantile(..., probs=c(0.75))[[1]]
AnnualQrt75 = GenerateAnnualSummary("data/yearly/AnnualQuartile75.grd", quartile3, dates=getMODISinfo(names(s))$date)
names(AnnualQrt75) = years
plot(AnnualQrt75)
quantile90 = function(...) quantile(..., probs=c(0.90))[[1]]
AnnualQnt90 = GenerateAnnualSummary("data/yearly/AnnualQuantile90.grd", quantile90, dates=getMODISinfo(names(s))$date)
names(AnnualQnt90) = years
plot(AnnualQnt90)
AnnualMax = GenerateAnnualSummary("data/yearly/AnnualMax.grd", max, dates=getMODISinfo(names(s))$date)
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

StatRasters = c(AnnualAvg, AnnualMed, AnnualQrt75, AnnualQnt90, AnnualMax)
StatColNames = c("LAI_Avg", "LAI_Med", "LAI_Q75", "LAI_Q90", "LAI_Max")
AdmData = c(LTU0, LTU2)
AdmPostfix = c("LT", "Mun")
AdmNames = list(c("Republic of Lithuania"), SanitiseNames(LTU2@data$VARNAME_2))
rm(LAIData)
for (n in 1:length(AdmData))
{
    for (i in 1:length(StatRasters))
    {
        Extracted = ExtractWithinBorders(StatRasters[[i]], AdmData[[n]], StatColNames[i], years, ids=AdmNames[[n]],
            filename=paste("output/dataframes/", StatColNames[i], "_", AdmPostfix[n], ".csv", sep=""))
        if (!exists("StatData"))
            StatData = Extracted
        else
            StatData = merge(StatData, Extracted)
    }
    if (!exists("LAIData"))
        LAIData = StatData
    else
        LAIData = rbind(LAIData, StatData)
    rm(StatData, Extracted)
}

# Read statistics from the government
statistics = ImportStatistics()

# Merge the two data frames into one
Dataset = merge(LAILTU, statistics, by=c("Municipality", "Year"))
