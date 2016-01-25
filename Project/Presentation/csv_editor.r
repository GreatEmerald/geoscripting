# Team Rython: Dainius Masiliunas and Tim Weerman
# Date: January 2016
# License: Apache License 2.0

# Load library
library (lattice)
library(leaflet)
library(shiny)

# Set working directory
getwd()
setwd("/home/tim/geoscripting/Project/Presentation")

# Import statistics
statistics = read.csv("Exported_matrix_table.csv")

# Edit the headers
names(statistics)[1] = "Municipality"
names(statistics)[2] = "Year"
names(statistics)[3] = "Forest_Coverage_in_Percent"

# View the data frame
# View(statistics)

# Remove the information in the bottom
statistics = statistics[-c(1225:1243),]

# Repeat municipality names
for( i in 1:nrow(statistics)) 
{
  if (statistics[i,1] != "")
    memory = statistics[i,1]
  else
    statistics[i,1] = memory
}

# Remove all the years that have No values at all (1993, 1998, 2001, 2003, 2015)
statistics = statistics[!is.na(statistics$Forest_Coverage_in_Percent),]

# Plot all the data
xyplot(Forest_Coverage_in_Percent~ Year|Municipality, data=statistics)

# Levels
statistics$Municipality=factor(statistics$Municipality)
levels(statistics$Municipality)


for(i in levels(statistics$Municipality))
{
  svg(paste("ToManyImages/", i, ".svg"))
  plot(Forest_Coverage_in_Percent~ Year, data=statistics[statistics$Municipality==i,], main = i, type = "l", ylim=c(0,100))
  dev.off()
}


content <- as.character(tagList(tags$img(src="/home/tim/geoscripting/Project/Presentation/ToManyImages/ Akmenė d. mun. .svg")))

leaflet() %>% addTiles() %>%
  addPopups(-122.327298, 47.597131, content,
            options = popupOptions(closeButton = FALSE)
  )


