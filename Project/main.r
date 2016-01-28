# Team Rython: Dainius Masiliunas and Tim Weerman
# Date: January 2016
# License: Apache License 2.0

# Geoscripting project: a comparison between official statistics about forest coverage
# and calculated LAI trends since 2002 in Lithuania

library(bfastSpatial)
library(parallel)
library(lattice)
library(htmlwidgets)

source("src/bfastSpatialHelpers.r") # Generate* functions
source("src/ImportStatistics.r")
source("src/SanitiseNames.r")
source("src/ExtractWithinBorders.r")
source("src/GetMunicipalityLeaflet.r")

## MAKE SURE TO SET THE RIGHT WORKING DIRECTORY ##
getwd()

## Data processing ##

# Using LAI data product from the MODIS satellite.
# Get the data (URL script was generated by the MODIS website)
## NOTE: This results in downloading and processing 175 files.
## To speed it up a bit, use "data/reduced.txt" instead.
filelist = read.table("data/data_url_script_2016-01-15_032836.txt", as.is=TRUE)
for(url in unlist(filelist))
    download.file(url, destfile=paste0("data/", basename(url)), method="wget")

# Magic numbers!
# QC_val/filtermask: 0x00 means keep everything, 0xFF means keep only if all are 0
# https://lpdaac.usgs.gov/dataset_discovery/modis/modis_products_table/mcd15a2
# http://www.binaryhexconverter.com/binary-to-hex-converter
filtermask = 0x8C # Filter for dead detectors, clouds, and non-produced pixels
fillnumber = 249:255 # From the manual

# Process all the data: remove unreliable pixels
processMODISbatch("data", pattern=glob2rx("*.hdf"), 2, 3, bit=TRUE, QC_val=0x8C, fill=fillnumber, outdir="data/processed", mc.cores=4)

# Stack resulting layers
Stack = GenerateTimeStack(filename=file.path("data", "processed", "Stack.grd"), x="data/processed", pattern=glob2rx("*.tif"))

# Create annual summary statistics: mean, median, 3rd quartile, max
# These are not in a loop, because it takes a LONG time to calculate each step!
# Long as in HOURS! Even with the reduced dataset, somehow! Pass mc.cores if you have more than 4 cores.
years = 2002:2015
AnnualMed = GenerateAnnualSummary(Stack, "data/yearly/AnnualMedian.grd", median, dates=getMODISinfo(names(Stack))$date)
names(AnnualMed) = years
AnnualAvg = GenerateAnnualSummary(Stack, "data/yearly/AnnualAverage.grd", mean, dates=getMODISinfo(names(Stack))$date)
names(AnnualAvg) = years
quartile3 = function(...) quantile(..., probs=c(0.75))[[1]]
AnnualQrt75 = GenerateAnnualSummary(Stack, "data/yearly/AnnualQuartile75.grd", quartile3, dates=getMODISinfo(names(Stack))$date)
names(AnnualQrt75) = years
quantile90 = function(...) quantile(..., probs=c(0.90))[[1]]
AnnualQnt90 = GenerateAnnualSummary(Stack, "data/yearly/AnnualQuantile90.grd", quantile90, dates=getMODISinfo(names(Stack))$date)
names(AnnualQnt90) = years
AnnualMax = GenerateAnnualSummary(Stack, "data/yearly/AnnualMax.grd", max, dates=getMODISinfo(names(Stack))$date)
names(AnnualMax) = years

# Alternatively, this can be run in parallel, one statistic per core; uncomment this block for that:
#tasklist = list(
#    annualMed <- function() annualSummary(s, fun=median, na.rm=TRUE, filename="data/yearly/AnnualMedian.grd", progress="text"),
#    annualAvg <- function() annualSummary(s, fun=mean, na.rm=TRUE, filename="data/yearly/AnnualAverage.grd", progress="text"),
#    annualQrt75 <- function() annualSummary(s, fun=quartile3, na.rm=TRUE, filename="data/yearly/AnnualQuartile75.grd", progress="text"),
#    annualMax <- function() annualSummary(s, fun=max, na.rm=TRUE, filename="data/yearly/AnnualMax.grd", progress="text")
#)
#system.time(stats <- mclapply(tasklist, function(f) f(), mc.cores = 4))


## Merging of different data sources ##

# Load administrative borders (note: poor quality and outdated!)
LTU0 = getData("GADM", country="LTU", path="data", level=0)
LTU2 = getData("GADM", country="LTU", path="data", level=2)

# Extract data from all our annual summary statistic layers at both levels
StatRasters = c(AnnualAvg, AnnualMed, AnnualQrt75, AnnualQnt90, AnnualMax) # If you just want to load the data from CSVs, replace with StatRasters = 1:5
StatColNames = c("LAI_Avg", "LAI_Med", "LAI_Q75", "LAI_Q90", "LAI_Max")
AdmData = c(LTU0, LTU2)
AdmPostfix = c("LT", "Mun")
AdmNames = list(c("Republic of Lithuania"), SanitiseNames(LTU2@data$VARNAME_2))
rm(LAIData)
for (n in 1:length(AdmData))
{
    for (i in 1:length(StatRasters))
    {
        # Extract the data from our statistic raster
        Extracted = ExtractWithinBorders(StatRasters[[i]], AdmData[[n]], StatColNames[i], years, ids=AdmNames[[n]],
            filename=paste("output/dataframes/", StatColNames[i], "_", AdmPostfix[n], ".csv", sep=""))
        # Merge into one long data frame
        if (!exists("StatData"))
            StatData = Extracted
        else
            StatData = merge(StatData, Extracted)
    }
    # Merge data frames from the two different levels
    if (!exists("LAIData"))
        LAIData = StatData
    else
        LAIData = rbind(LAIData, StatData)
    rm(StatData, Extracted)
}

# Read statistics from the government
statistics = ImportStatistics()

# Merge the two data frames into one
Dataset = merge(LAIData, statistics, by=c("Municipality", "Year"))
write.table(Dataset, file="output/dataframes/Dataset.csv")

## Generate plots ##

# Creates SVG plots of the average, median, maximum, 75qt, 90qt LAI and the Forest Coverage over the years
# from the dataset and places them in outdir
MakePlotSVGs = function(Dataset, outdir)
{
    # Get the common extremes for plot limits
    miniY1= min(Dataset$Forest_Coverage)
    maxiY1= max(Dataset$Forest_Coverage)  
    maxiY2= max(Dataset$LAI_Avg, Dataset$LAI_Med, Dataset$LAI_Q75, Dataset$LAI_Q90, Dataset$LAI_Max)
    miniY2= min(Dataset$LAI_Avg, Dataset$LAI_Med, Dataset$LAI_Q75, Dataset$LAI_Q90, Dataset$LAI_Max)
    
    # Create the graphical output of the statistics and the forest cover/LAI (two Y axes)
    for(i in levels(factor(Dataset$Municipality)))
    {
        svg(paste0(outdir, "/", i, ".svg"))
        par(mar=c(5,4,4,5)+.1)
        plot(Forest_Coverage~ Year, data=Dataset[Dataset$Municipality==i,], type="l",col="black", main=i, ylab= "Forest Coverage %", ylim=c(miniY1, maxiY1), lwd=3)
        par(new=TRUE)
        plot(LAI_Avg~ Year, data=Dataset[Dataset$Municipality==i,], type="l", col="blue", xaxt="n", yaxt="n", xlab="", ylab="", ylim=c(miniY2, maxiY2))
        lines(LAI_Med~ Year, data=Dataset[Dataset$Municipality==i,], col="green")
        lines(LAI_Q75~ Year, data=Dataset[Dataset$Municipality==i,], col="gold")
        lines(LAI_Q90~ Year, data=Dataset[Dataset$Municipality==i,], col="darkorange")
        lines(LAI_Max~ Year, data=Dataset[Dataset$Municipality==i,], col="firebrick1")
        axis(4)
        mtext("LAI",side=4,line=3)
        legend("topleft",col=c("black","blue", "green", "gold", "darkorange", "firebrick1"),lty=1, lwd=c(3,1,1,1,1,1),
            legend=c("Forest Coverage","Mean LAI", "Median LAI", "75th percentile of LAI", "90th percentile of LAI", "Maximum LAI"))
        dev.off()
    }
}

svgdir = file.path("output", "SVG")
MakePlotSVGs(Dataset, svgdir)

## Generate a Leaflet HTML ##

# Create a base raster to render
Summary = summaryBrick(Stack, fun=mean)
# Make it small enough to embed into HTML
SmallSummary = crop(Summary, spTransform(LTU0, Summary@crs))

htmldir = file.path(getwd(), "output", "html")
Leaflet = GetMunicipalityLeaflet(LTU0, LTU2, SmallSummary, svgdir=svgdir)
saveWidget(Leaflet, file=file.path(htmldir, "Municipalities.html"), selfcontained=FALSE)

## Look at some statistics
DatLT = subset(Dataset, Municipality=="Republic of Lithuania")
DatMun = subset(Dataset, Municipality!="Republic of Lithuania")
# LAI mean change per year: +0.04 
summary(lm(LAI_Avg~Year, data=DatLT)) # Whole country
summary(lm(LAI_Avg~Year, data=DatMun)) # Individual municipalities
# That's 0.68% per year
lm(LAI_Avg~Year, data=DatLT)$coefficients[2]/max(Dataset[["LAI_Max"]])*100

# LAI maximum change per year: +0.06
summary(lm(LAI_Max~Year, data=DatLT)) # Whole country
summary(lm(LAI_Max~Year, data=DatMun)) # Individual municipalities
# That's 0.93% per year
lm(LAI_Max~Year, data=Dataset[Dataset$Municipality=="Republic of Lithuania",])$coefficients[2]/max(Dataset[["LAI_Max"]])*100

# Forest cover change per year: +0.12%
summary(lm(Forest_Coverage~Year, data=DatLT)) # Whole country
summary(lm(Forest_Coverage~Year, data=DatMun)) # Individual municipalities

## Done. ##
## Note: Leaflet is a bit silly with popup widths; manually fix that by injecting CSS (optional) ##
wd = getwd()
setwd(htmldir)
system("./addcss.sh")
system("firefox Municipalities.html")
setwd(wd)
