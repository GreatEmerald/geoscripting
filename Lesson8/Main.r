# Team Rython, Dainius Masiliunas and Tim Weerman
# Date: 11 January, 2016
# Apache License 2.0

# Needed packages
library(raster)

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

# Plot relationships
pairs(DataBrick)
# We can conclude that they are all negatively correlated with VCF, except for NIR.
# The bands are also highly correlated with each other.

DataValues = as.data.frame(getValues(DataBrick))
LM = lmValidation(VCF ~ Blue + Green + Red + NIR + SWIR + Emission, data=DataValues, printstep = TRUE)
# Emission can be dropped
LM = lmValidation(VCF ~ Blue + Green + Red + NIR + SWIR, data=DataValues, printstep = TRUE)
# Nothing further can be dropped, the most significant bands are NIR and green
## NB: a linear model isn't very appropriate, because normality and independence assumptions are violated!

# Plot the predicted tree cover raster and compare with the original VCF raster.
BrickSubset = dropLayer(DataBrick, "Emission")
# Plot a histogram of predicted values
Prediction = predictValidation(BrickSubset, model=LM, na.rm=TRUE, plothist=TRUE)
# Out of reasonable range, apply a range constraint and compare
Prediction = predictValidation(BrickSubset, model=LM, na.rm=TRUE, truthlayer="VCF", 
    range=c(0, +Inf), plotcomparison=TRUE)

# If we use only independent variables:
ReducedBrick = dropLayer(DataBrick, "Emission")
ReducedBrick = dropLayer(ReducedBrick, "Green")
ReducedBrick = dropLayer(ReducedBrick, "Red")
ReducedBrick = dropLayer(ReducedBrick, "SWIR")
pairs(ReducedBrick)
ReducedLM = lmValidate(VCF ~ Blue + NIR, data=DataValues, printstep=TRUE)
RedPrediction = predictValidation(ReducedBrick, model=ReducedLM, na.rm=TRUE,
    range=c(0, +Inf), truthlayer="VCF", plothist=TRUE, plotcomparison=TRUE)

# Compute the RMSE between your predicted and the actual tree cover values. 
RMSE(getValues(ReducedBrick[["VCF"]]), getValues(RedPrediction))

# Are the differences between the predicted and actual tree cover the same for all of the 3 classes we used for the random forest classfication? 
# Using the training polygons from the random forest classification, calculate the RMSE separately for each of the classes and compare. 
# Hint - see ?zonal().
# Unfortunately, zonal() just passes a vector of numbers, not a matrix. So we have to calclate RMSE manually from a difference raster.
trainingRaster = rasterize(trainingPoly, DataBrick[["VCF"]], field='Class')
differenceRaster = overlay(ReducedBrick[["VCF"]], RedPrediction, fun=function(truth, prediction){(truth-prediction)^2}, filename=paste(".grd"))
zonestats = zonal(differenceRaster, trainingRaster, fun="mean")
rownames(zonestats) = levels(trainingPoly@data$Class)
zonestats