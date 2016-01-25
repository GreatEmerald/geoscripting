# Name: Dainius Masiliunas
# Date: January 4, 2016
# License: Apache License 2.0 (http://www.apache.org/licenses/LICENSE-2.0)

# Import packages
library(raster)

# Define the function
GADMPlot = function(country, level)
{
  # Create a directory (if it already exists, nothing is done) for getData
  datdir <- 'data'
  dir.create(datdir, showWarnings = FALSE)
  # Get the data
  adm <- raster::getData("GADM", country = country, level = level, path = datdir)
  # Plot the data
  # For the legend:
  op = par(mar=c(5.1, 4.1, 4.1, 8.1), xpd=TRUE)
  # Also plot the axis labels and use colours for background and polygons
  plot(adm, axes = TRUE, xlab="Longitude", ylab="Latitude",
    main=paste("Administrative map of", country), col="green4", bg="grey", bty="L")
  # Add a legend (only one entry)
  legend("topright",inset=c(-0.31,0), legend = c("Country", "Background"), fill=c("green4", "grey"),
    title="Legend", bg="grey95")
  par(op)
  # Get label names. They are all in different variables for each level,
  # so using a switch to get the right one. Switch starts counting from 1.
  Names = switch(level+1,
    adm$NAME_LOCAL,
    adm$NAME_1,
    adm$NAME_2,
    adm$NAME_3) # Might not be necessary, looks like the dataset only has 2 levels
  # Label plotting: the function shown in the exercise is now deprecated;
  # but now there's an even easier way to get the coordinates!
  text(coordinates(adm), labels=as.character(Names))
}

# An example based on that function
GADMPlot("LTU", 0) # Plot country borders
#GADMPlot("LTU", 1) # Plot first level administrative divisions (a bit dated, apskritys no longer exist)
GADMPlot("LTU", 2) # Plot second level administrative divisions (savivaldybes; should be first level)
#GADMPlot("LTU", 3) # Plot second level administrative divisions (seniunijos; unfortunately does not exist)
# Try the same on the Netherlands
#GADMPlot("NLD", 0)
#GADMPlot("NLD", 1)
#GADMPlot("NLD", 2)
#GADMPlot("NLD", 3) # Again a 404