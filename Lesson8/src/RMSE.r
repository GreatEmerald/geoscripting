# Team Rython, Dainius Masiliunas and Tim Weerman
# Date: 11 January, 2016
# Apache License 2.0

# Calculate the Root Mean Squared Error
RMSE = function(truth, prediction)
{
    return(sqrt(mean((truth-prediction)^2, na.rm=TRUE)))
}

# Calculate partial RMSE for different zones by generating squared difference rasters.
GetDifferenceRaster = function(former, latter, filename=paste("data/", names(latter), ".grd", sep=""), force=FALSE)
{
    # Figure out a reasonable output name
    if (filename == "data/layer.grd")
        warning("Please pass filename or assign meaningful names to input rasters! Else the loaded data may not match expectations.")
    
    # Create one or load one
    if (!file.exists(filename) || force)
    {
        return(overlay(former, latter, fun=function(truth, prediction){(truth-prediction)^2},
            filename=filename))
    }
    else
        return(raster(filename))
}

# Unfortunately, zonal() just passes a vector of numbers, not a matrix. So we have to calclate RMSE manually from a difference raster.
StratifiedRMSE = function(truth, prediction, zones, zonenames = "", ...)
{
    differenceRaster = GetDifferenceRaster(truth, prediction, ...)
    zonestats = zonal(differenceRaster, zones, fun="mean")
    if (length(zonenames) > 1)
        rownames(zonestats) = zonenames
    return(zonestats)
}
