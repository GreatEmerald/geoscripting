# Team Rython: Dainius Masiliunas and Tim Weerman
# January 12, 2016
# Apache License 2.0

library(rgdal)

GetGreennessIndex = function(NDVI, area, months)
{
    print(area)
    # Mask everything aside from the wanted area
    NDVImask = mask(NDVI, area)
    return(mean(NDVImask[[months]]@data@values, na.rm=TRUE))
}

GetGreenestArea = function()
{
    GreenRatings = sapply(seq_len(nrow(NLadm)), function(i) GetGreennessIndex(ModisData, NLadm[i,], 1))
    Winner = which(GreenRatings == max(GreenRatings))
    return(NLadm[Winner,])
}
