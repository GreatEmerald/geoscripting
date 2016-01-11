# Team Rython, Dainius Masiliunas and Tim Weerman
# Date: 11 January, 2016
# Apache License 2.0

library(rgeos) # g functions

# Plots the towns in a given distance from a given railway type
PlotTownsNextToRailways = function(RailwayLines, TownPoints, RailwayType, Distance = 1000)
{
    # Select requested railways
    OurRails = subset(RailwayLines, type == RailwayType)

    # Buffer of a kilometre
    RailSurroundings = gBuffer(OurRails, byid = TRUE, width = Distance)

    # Find intersecting places
    RailNeighbours = gIntersection(RailSurroundings, TownPoints, byid = TRUE)

    # Plot
    plot(RailSurroundings, axes=TRUE)
    plot(OurRails, add=TRUE, col="red")
    # In case there are none, do not plot
    if (class(RailNeighbours) == "NULL")
    {
        warning("No cities are in buffer range, consider increasing the distance!")
        return()
    }
    else
        plot(RailNeighbours, add=TRUE, pch=15)

    # A tricky way to extract and match IDs of the points we just intersected
    CityIDs = as.numeric(unlist(strsplit(dimnames(RailNeighbours@coords)[[1]], " "))[c(FALSE,TRUE)])
    
    # Extract population and name from our IDs
    CityInfo = TownPoints@data[CityIDs,]

    # Add the city names onto the plot
    text(RailNeighbours$x, RailNeighbours$y, labels = CityInfo[[2]])

    # Prints the city ID, city name, and population
    print(CityInfo[c("name", "population")])
}

