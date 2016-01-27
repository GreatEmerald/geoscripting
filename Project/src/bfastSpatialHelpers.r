# Team Rython: Dainius Masiliunas and Tim Weerman
# Date: January 2016
# License: Apache License 2.0

library(bfastSpatial)

# Helper wrapper functions for bfastSpatial functions for loading files if they exist.

# Returns an annual summary RasterBrick that either already has been generated,
# or generates it from scratch.
GenerateAnnualSummary = function(filename, fx, mc.cores=4, ...)
{
    if (!file.exists(filename))
    {
        print("Calculating annual summary. This may take a LONG time! Get a cup of tea in the mean while. Or ten.")
        return(annualSummary(s, fun=fx, na.rm=TRUE, mc.cores=mc.cores, filename=filename, progress="text", ...))
    }
    else
        return(brick(filename))
}

# Returns a RasterStack that either has already been stacked, or generates it from scratch.
GenerateTimeStack = function(filename, ...)
{
    if (!file.exists(filename))
        stack = timeStackMODIS(filename=filename, datatype='INT1U', progress="text", ...)
    else
        stack = stack(filename)
}
