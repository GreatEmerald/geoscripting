# Team Rython: Dainius Masiliunas and Tim Weerman
# January 12, 2016
# Apache License 2.0

library(rgdal)

# Get the greenness index for a single area
GetGreennessIndex = function(NDVI, area, months)
{
    print(area)
    # Mask everything aside from the wanted area
    NDVImask = mask(NDVI, area)
    return(mean(NDVImask[[months]]@data@values, na.rm=TRUE))
}

# Get the max greenness index for a country
GetGreenestArea = function(NDVI, areas, months)
{
    # This should work. But it doesn't.
    # sapply(NLadm, GetGreennessIndex, months = 1, NDVI = ModisData)
    # Workaround!
    GreenRatings = sapply(seq_len(nrow(areas)), function(i) GetGreennessIndex(NDVI, areas[i,], months))
    print(paste("The highest NDVI value is:", max(GreenRatings)))
    Winner = which(GreenRatings == max(GreenRatings))
    return(list(Ratings = GreenRatings, Winner = areas[Winner,]))
}
