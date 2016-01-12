# Team Rython: Dainius Masiliunas and Tim Weerman
# January 12, 2016
# Apache License 2.0

library(rgdal)

# Get the greenness index (NDVI number) for a single area
GetGreennessIndex = function(NDVI, area, months)
{
    # Mask everything aside from the wanted area
    NDVImask = mask(NDVI, area)
    return(mean(NDVImask[[months]]@data@values, na.rm=TRUE))
}

# Get the max greenness index for a country
GetGreenestArea = function(NDVI, areas, months)
{
    # Get the highest NDVI value for each municipality separately.
    # This should work. But it doesn't:
    # sapply(NLadm, GetGreennessIndex, months = 1, NDVI = ModisData)
    # Workaround! This creates a wrapper lambda that passes each municipality to our GGI function.
    GreenRatings = sapply(seq_len(nrow(areas)), function(i) GetGreennessIndex(NDVI, areas[i,], months))
    print(paste("The highest NDVI value is:", max(GreenRatings)))
    Winner = which(GreenRatings == max(GreenRatings))
    # Return both the rankings (they can be cached, as it takes long to calculate)
    # and the winner SpatialPolygonDataFrame
    return(list(Ratings = GreenRatings, Winner = areas[Winner,]))
}

# High-level function that calls others to find all the greenness rankings,
# plots the data and even tells you where exectly on the list Wageningen is.
FindGreenestCity = function(NDVI, adm, months)
{
    # Find the winning municipality
    Winner = GetGreenestArea(NDVI, adm, months)
    # Plot it
    PlotGreenestCity(Winner$Winner, adm, ModisData, months)
    # Find where Wageningen is
    Rank = data.frame(NDVI = Winner$Ratings, ID = seq_len(length(Winner$Ratings)))
    RankOrder = order(Rank$NDVI, decreasing=TRUE)
    WageningenRank = which(Rank[RankOrder,]$ID == which(adm@data$NAME_2 == "Wageningen"))
    if(length(WageningenRank) > 0)
        print(paste("In the list, Wageningen ranks as the", WageningenRank, "greenest city!"))
}
