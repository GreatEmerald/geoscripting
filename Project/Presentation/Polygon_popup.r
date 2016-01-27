# Team Rython: Dainius Masiliunas and Tim Weerman
# Date: January 2016
# License: Apache License 2.0

# Load the libraries
library(raster)
library(leaflet)
library(rgeos)

# Finding the central point of Lithuania
centroid = gCentroid(LTU0, byid=FALSE, id = NULL)

# Variables that hold the information for the polygon popup
ImageTagStart = paste0("<img src='file://", getwd(), "/output/SVG/") 
ImageTagEnd =".svg' height='450' width='450'></img>"

# Leaflet function which creates a map with clickable municipailities. Each municipality has its own graph.
leaflet() %>% addProviderTiles("Esri.WorldImagery", group = "Satellite") %>% 
  addPolygons(data = LTU2, fill = FALSE, stroke = TRUE, color = "#03F", group = "Borders") %>% 
  addPolygons(data = LTU2, fill = TRUE, stroke = FALSE, color = "#f93", 
              popup = paste0(ImageTagStart, SanitiseNames(LTU2@data$VARNAME_2), ImageTagEnd), group = "Polygons") %>%
  addMarkers(centroid@coords[1], centroid@coords[2], popup = paste0("<img src=file://", getwd(), "/output/SVG/Republic of Lithuania.svg"), "height='450' width='450'></img>") 

