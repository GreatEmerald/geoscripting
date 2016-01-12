# Team Rython: Dainius Masiliunas and Tim Weerman
# January 12, 2016
# Apache License 2.0

library(raster)

# Plot two plots: the country overview with a highlighted winner,
# and the municipality zoomed in.
PlotGreenestCity = function(winner, NetherlandsMap, NDVI, months)
{
        # Parameters for plotting 2 images with more margin space
        opar <- par(mfrow=c(1,2), mar=c(5.1,4.1,4.1,5.1))

        # First image
        plot(mask(mean(NDVI[[months]]), NetherlandsMap))
        plot(NetherlandsMap, add=TRUE)
        title(main = "Map of the Netherlands")
        title(xlab = "Longtitude")
        title(ylab = "Latitude")
        plot(winner, add = TRUE, border = "red", lwd = 3)
        
        #Second image
        plot(mask(mean(NDVI[[months]]), winner), xlim=c(extent(winner)@xmin, extent(winner)@xmax), ylim = c(extent(winner)@ymin, extent(winner)@ymax))
        plot(winner, border = "red", lwd = 3, axes=TRUE, add=TRUE)
        title(main = "Greenest City")
        title(xlab = "Longtitude")
        title(ylab = "Latitude")
        text(winner, labels = winner$NAME_2)
        
        par(opar)
}
