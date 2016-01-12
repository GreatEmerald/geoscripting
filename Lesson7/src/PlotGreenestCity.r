# Team Rython: Dainius Masiliunas and Tim Weerman
# January 12, 2016
# Apache License 2.0

library(raster)
PlotGreenestCity = function(winner, NetherlandsMap, NDVI)
{

	opar <- par(mfrow=c(1,2))
	
	plotRGB(NetherlandsMap, 5, 4, 3)
	title(main = "Map of the Netherlands")
	title(xlab = "Longtitude")
	title(ylab = "Latitude")
	
	plotRGB(winner, 5, 4, 3, main = 'Mask()')
	plot(winner, add = TRUE, border = "green", lwd = 3)
	title(main = "Greenest City")
	title(xlab = "Longtitude")
	title(ylab = "Latitude")
	
	text(winner, labels = winner$NAME_2)
	
	#legend("bottomright", "NDVI"), pch = 15, lwd = 8, col = "lightblue")
	legend()
	par(opar)
}
