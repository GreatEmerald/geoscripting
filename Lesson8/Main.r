# Team Rython, Dainius Masiliunas and Tim Weerman
# Date: 11 January, 2016
# Apache License 2.0

# Needed packages


# Source


# Download/load information
download.file("https://github.com/GeoScripting-WUR/AdvancedRasterAnalysis/raw/gh-pages/data/GewataB1.rda", "data/GewataB1.rda", "wget")
download.file("https://github.com/GeoScripting-WUR/AdvancedRasterAnalysis/raw/gh-pages/data/GewataB2.rda", "data/GewataB2.rda", "wget")
download.file("https://github.com/GeoScripting-WUR/AdvancedRasterAnalysis/raw/gh-pages/data/GewataB3.rda", "data/GewataB3.rda", "wget")
download.file("https://github.com/GeoScripting-WUR/AdvancedRasterAnalysis/raw/gh-pages/data/GewataB4.rda", "data/GewataB4.rda", "wget")
download.file("https://github.com/GeoScripting-WUR/AdvancedRasterAnalysis/raw/gh-pages/data/GewataB5.rda", "data/GewataB5.rda", "wget")
download.file("https://github.com/GeoScripting-WUR/AdvancedRasterAnalysis/raw/gh-pages/data/GewataB7.rda", "data/GewataB7.rda", "wget")
download.file("https://github.com/GeoScripting-WUR/AdvancedRasterAnalysis/raw/gh-pages/data/vcfGewata.rda", "data/vfcGewata.rda", "wget")
load("data/GewataB1.rda")
load("data/GewataB2.rda")
load("data/GewataB3.rda")
load("data/GewataB4.rda")
load("data/GewataB5.rda")
load("data/GewataB7.rda")
load("data/vcfGewata.rda")

# Produce one or more plots that demonstrate the relationship between the Landsat bands and the VCF tree cover. 
# What can we conclude from this/these plot(s)?


# create an lm() model and show a summary (e.g. using summary()) of the model object you created. 
# Which predictors (bands) are probably most important in predicting tree cover?


# Plot the predicted tree cover raster and compare with the original VCF raster.


# Compute the RMSE between your predicted and the actual tree cover values. 
# RMSE <- sqrt(mean((y-y_pred)^2))

# Are the differences between the predicted and actual tree cover the same for all of the 3 classes we used for the random forest classfication? 
# Using the training polygons from the random forest classification, calculate the RMSE separately for each of the classes and compare. 
# Hint - see ?zonal().
