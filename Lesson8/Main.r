# Team Rython, Dainius Masiliunas and Tim Weerman
# Date: 11 January, 2016
# Apache License 2.0

# Needed packages
library(raster)

rm(list=ls())

# Source
source("src/RMSE.r")
source("src/LinearModel.r")

# Download/load information
GetFromWURgit = function(filename)
{
    download.file(paste("https://github.com/GeoScripting-WUR/AdvancedRasterAnalysis/raw/gh-pages/data/", filename, sep=""),
        paste("data/", filename, sep=""), "wget")
    return(paste("data/", filename, sep=""))
}
load(GetFromWURgit("GewataB1.rda"))
load(GetFromWURgit("GewataB2.rda"))
load(GetFromWURgit("GewataB3.rda"))
load(GetFromWURgit("GewataB4.rda"))
load(GetFromWURgit("GewataB5.rda"))
load(GetFromWURgit("GewataB7.rda"))
load(GetFromWURgit("vcfGewata.rda"))
load(GetFromWURgit("trainingPoly.rda"))

DataBrick = brick(GewataB1, GewataB2, GewataB3, GewataB4, GewataB5, GewataB7, vcfGewata)
names(DataBrick) = c("Blue", "Green", "Red", "NIR", "SWIR", "Emission", "VCF")
# Sanitise data
DataBrick[["VCF"]][DataBrick[["VCF"]] > 100] = NA
DataValues = as.data.frame(getValues(DataBrick))

# Create a training raster for RMSE
trainingRaster = rasterize(trainingPoly, DataBrick[["VCF"]], field='Class', filename="data/trainingRaster.grd")


# Plot relationships
pairs(DataBrick)
## We can conclude that they are all negatively correlated with VCF, except for NIR.
## The bands are also highly correlated with each other.

LM = lmValidation(VCF ~ Blue + Green + Red + NIR + SWIR + Emission, data=DataValues, printstep = TRUE)
# Emission can be dropped
LM = lmValidation(VCF ~ Blue + Green + Red + NIR + SWIR, data=DataValues, printstep = TRUE)
# Nothing further can be dropped, the most significant bands are NIR and green
## NB: a linear model isn't very appropriate, because normality and independence assumptions are violated!

BrickSubset = dropLayer(DataBrick, "Emission")
# Plot a histogram of predicted values
Prediction = predictValidation(BrickSubset, model=LM, na.rm=TRUE, plothist=TRUE)
# Out of reasonable range, apply a range constraint and compare
Prediction = predictValidation(BrickSubset, model=LM, na.rm=TRUE, filename="data/PredictionRaster.grd",
    truthlayer="VCF", range=c(0, +Inf), plotcomparison=TRUE)
names(Prediction) = "Predicted.LM"
# Compute the RMSE
RMSE(getValues(ReducedBrick[["VCF"]]), getValues(Prediction))
# RMSE per zone
zonestats = StratifiedRMSE(DataBrick[["VCF"]], Prediction, trainingRaster, zonenames=levels(trainingPoly@data$Class))
zonestats
# As a bonus, plot the difference raster
plot(raster("data/Predicted.LM.grd"))


## If we use only independent (not highly correlated) variables for the model:
ReducedBrick = dropLayer(DataBrick, "Emission")
ReducedBrick = dropLayer(ReducedBrick, "Green")
ReducedBrick = dropLayer(ReducedBrick, "Red")
ReducedBrick = dropLayer(ReducedBrick, "SWIR")

pairs(ReducedBrick)
ReducedLM = lmValidate(VCF ~ Blue + NIR, data=DataValues, printstep=TRUE)
RedPrediction = predictValidation(ReducedBrick, model=ReducedLM, na.rm=TRUE,
    filename="data/ReducedPredictionRaster.grd", range=c(0, +Inf),
    truthlayer="VCF", plothist=TRUE, plotcomparison=TRUE)
names(RedPrediction) = "Predicted.LM.Blue.NIR"
RMSE(getValues(ReducedBrick[["VCF"]]), getValues(RedPrediction))
zonestatsR = StratifiedRMSE(DataBrick[["VCF"]], RedPrediction, trainingRaster,
    zonenames=levels(trainingPoly@data$Class))
zonestatsR
plot(raster("data/Predicted.LM.Blue.NIR.grd"))
