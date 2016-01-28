# Team Rython: Dainius Masiliunas and Tim Weerman
# Date: January 2016
# License: Apache License 2.0

# Load the libraries
library(raster)
library(leaflet)
library(rgeos)

# Returns a Leaflet object consisting of interactive administrative divisions
# that show pregenerated SVG plots. polyl0 is the top level administrative polgons,
# polyl2 is the municipality level polygons (currently level 2 in GADM).
# overlayraster is a raster to display at the base of the plot.
# svgdir is the location of preset SVGs.
GetMunicipalityLeaflet = function(polyl0, polyl2, overlayraster, rastername="Mean LAI", svgdir="output/SVG")
{
    # Finding the central point of Lithuania
    centroid = gCentroid(polyl0, byid=FALSE, id = NULL)

    # Variables that hold the information for the polygon popup
    ImageTagStart = paste0("<img src='file://", getwd(), "/", svgdir, "/") 
    ImageTagEnd = ".svg' height='450' width='450'></img>"

    # Leaflet function which creates a map with clickable municipailities. Each municipality has its own graph.
    result = leaflet() %>% addProviderTiles("Esri.WorldImagery", group = "Satellite") %>% 
    addRasterImage(overlayraster, group=rastername) %>%
    addPolygons(data = polyl2, fill = FALSE, stroke = TRUE, color = "#03F", group = "Borders") %>% 
    addPolygons(data = polyl2, fill = TRUE, stroke = FALSE, color = "#f93", 
                popup = paste0(ImageTagStart, SanitiseNames(polyl2@data$VARNAME_2), ImageTagEnd), group = "Polygons") %>%
    # Central marker for the whole country
    addMarkers(centroid@coords[1], centroid@coords[2], popup = paste0("<img src='file://", getwd(), "/", svgdir, "/Republic of Lithuania.svg' height='450' width='450'></img>")) %>%
    addLayersControl(overlayGroups = c("Satellite", rastername))
    return(result)
}
