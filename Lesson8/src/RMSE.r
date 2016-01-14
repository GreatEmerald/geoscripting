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

# Calculate RMSE per zone
StratifiedRMSE = function(truth, prediction, zones, zonenames = "", ...)
{
    # Unfortunately, zonal() just passes a vector of numbers, not a matrix.
    # So we have to calclate RMSE manually from a difference raster.
    differenceRaster = GetDifferenceRaster(truth, prediction, ...)
    
    # Get a mean from the zones in the difference raster
    zonestats = zonal(differenceRaster, zones, fun="mean")
    
    # Add nice labels, if we have them
    if (length(zonenames) > 1)
        rownames(zonestats) = zonenames
        
    return(zonestats)
}
