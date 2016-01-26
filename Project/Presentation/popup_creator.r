# Team Rython: Dainius Masiliunas and Tim Weerman
# Date: January 2016
# License: Apache License 2.0


library(leaflet)  

# popupOptions(maxWidth = NULL) editing the width so it's not 300 by default should be done with this
m <- leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  addMarkers(lng=22.826354, lat=56.237323, popup= ("<img src='/home/tim/geoscripting/Project/Presentation/ToManyImages/ Akmenė d. mun. .svg' height='400' width='400'></img>"))
m  # Print the

###<link rel="stylesheet" type="text/css" href="/home/tim/geoscripting/Project/Presentation/width.css">
