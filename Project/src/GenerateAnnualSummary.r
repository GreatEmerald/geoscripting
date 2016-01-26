# Team Rython: Dainius Masiliunas and Tim Weerman
# Date: January 2016
# License: Apache License 2.0

library(bfastSpatial)

GenerateAnnualSummary = function(filename, fx, mc.cores=4)
{
    if (!file.exists(filename))
    {
        print("Calculating annual summary. This may take a LONG time!")
        return(annualSummary(s, fun=fx, na.rm=TRUE, mc.cores=mc.cores, filename=filename, progress="text"))
    }
    else
        return(brick(filename))
}
