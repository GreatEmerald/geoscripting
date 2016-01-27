# Team Rython: Dainius Masiliunas and Tim Weerman
# Date: January 2016
# License: Apache License 2.0


library(raster)
library(leaflet)

testcase = "<img src='file:///home/tim/geoscripting/Project/Presentation/pre-processing.png' height='400' width='400'></img>"
leaflet() %>% addProviderTiles("Esri.WorldImagery", group = "Satellite") %>% 
  addPolygons(data = LTU2, fill = FALSE, stroke = TRUE, color = "#03F", group = "Borders") %>% 
  addPolygons(data = LTU2, fill = TRUE, stroke = FALSE, color = "#f93", 
              popup = paste0(as.character(testcase)), group = "Polygons") %>% 
  # add a legend
  #addLegend("bottomright", colors = c("#03F", "#f93"), labels = c("Borders", "Polygons")) %>%   
  # add layers control
  addLayersControl(position = 'topright',
    baseGroups = c("Topographical", "Road map", "Satellite"),
    #overlayGroups = c("Borders", "Polygons"),
    options = layersControlOptions(collapsed = FALSE)
  )
