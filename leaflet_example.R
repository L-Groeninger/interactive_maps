# ------------------Descriptive geospatial analysis with the leaflet R package------ ####
#
# Script:           Descriptive geospatial analysis with the leaflet R package 
#                   (annotated example)
# 
# Author:           Lukas Gröninger
# Date:             21.08.2020
#
# packages:         tidyverse, geojsonio, leaflet, htmltools
# data:             income_data.Rdata, plz-2stellig.geojson
# 


# ------------------Introduction------------------------------------------------ ####

# In this script I will show how to produce an interactive (html)webmap with the 
# leaflet package.
#
# The goal is to create an interactive map of Germany divided into 95 (two-digit
# zip code) regions and to show the desired minimum wage of professional truck 
# drivers in each region. 
# There are lots of great blogposts and learning material about the leaflet 
# package and I can recommend the links under further resources/material. 
# 
# 
# When seeing a map you instantly start a spatial analysis in your head and ask
# yourself questions about patterns you detect or location dependent relationships 
# you might see.
# 
# Why geospatial analysis or better: the power of where
# https://learn.arcgis.com/en/arcgis-book/chapter5/ 
# 

# --------------------Further resources/material and documentation: ---------------- ####
#
# https://www.rdocumentation.org/packages/leaflet/versions/2.0.3 
# https://rstudio.github.io/leaflet/
# https://www.earthdatascience.org/courses/earth-analytics/get-data-using-apis/leaflet-r/
# https://learn.r-journalism.com/en/mapping/leaflet_maps/leaflet/
# https://rpubs.com/mattdray/basic-leaflet-maps
# Datacamp course on leaflet
# 

# ---------------------loading required packages------------------------------------ ####
# 
library(tidyverse)  
library(geojsonio) # reading in the "zip regions object" for Germany
library(leaflet)   
library(htmltools) 

# ---------------------load required data ------------------------------------------ ####
#
load("Data/income_data.Rdata")
# the income_data dataframe consists only of aggregated information about the desired 
# minimum wage of professional truck drivers in Germany and the corresponding region.
# There are 95 (two digit zip code) regions. 
glimpse(income_data)

# Another object we need is the spatial polygons dataframe consisting of the geographic 
# information about the boundaries of the 95 regions. The format is a geojson file so 
# we need the geojson_read function from the geojsonio package.
plz_map <- geojsonio::geojson_read("Data/plz-2stellig.geojson", what = "sp")


# ---------------------------------------------------------------------------- ####
# Now we add the information about the desired minimum wage of truck drivers 
# (mean.minIncome) to our spatial polygon object (plz_map) and their 
# corresponding region.
plz_map$mean_minIncome <- income_data$mean.minIncome

# --------------------Base Map1----------------------------------------------- ####
# Now we create the first basis map only with highlighted zip regions:
# We fix the zoom to a level where we can see the area of Germany (with leafletOptions()).
#
# Base Map1 
map1 <- leaflet(plz_map, options = leafletOptions(zoomSnap = 0.25, minZoom = 5,
                                                  dragging = TRUE)) %>% 
  addProviderTiles("OpenStreetMap.DE", group = "OpenStreetMap.DE") %>%
  addPolygons()

map1 # show the basic map

# -----------------We want to fill the map with information--------------------------- ####
# 
# First get an overview of the range of the income variable:
range(plz_map$mean_minIncome)

# Then we can create the bins for our map. I decided to use steps of 50 € 
bins1 <- c(2200, 2250, 2300, 2350, 2400, 2450, 2500, 2550, 2600, 2650)

# We need a color palette to display our information
# Here's some information about different color palettes:
# https://www.datanovia.com/en/blog/the-a-z-of-rcolorbrewer-palette/
#
# I decided to use the "YlOrRd" palette which is intuitive for most people:
# it ranges from light yellow (low values) to a darker red (high values)

pal1 <- colorBin("YlOrRd",  # name of the color palette
                 domain = plz_map$mean_minIncome, # where to apply it to
                 bins = bins1) # the bins we use

# As we want to create an interactive html-map we need labels to be displayed
# when hovering over the map (the htmltools package is required).
#
# %s relates to the zip region (plz) and %g to the mean_minIncome variable
labels1 <- sprintf("Zip-Region: <strong>%s</strong><br/>%g € ",
                   plz_map$plz, plz_map$mean_minIncome) %>% 
  lapply(htmltools::HTML)


# ------------------Interactive Map2------------------------------------------- ####
# We will now update the basic map1 with our specific geographic information 
# from the income_data dataframe

# Interactive Map2
map2 <- map1 %>% addPolygons(
  fillColor = ~pal1(mean_minIncome), # which information we want to display
  weight = 1,
  opacity = 1.5,
  color = "#D3D3D3", # light grey showing the boundaries of the zip regions
  dashArray = "1",
  fillOpacity = 1.5,
  highlight = highlightOptions( # options when hovering over the specific region
    weight = 3, # increasing the size of the boundaries when hovering over the region
    color = "#666", # darker grey showing the hightlighted boundaries when hovering over it
    dashArray = "",
    fillOpacity = 0.3, # to see what's "beneath the color" and inspect the region
    bringToFront = TRUE),
  label = labels1, # adding the labels we created
  labelOptions = labelOptions( # Options for the font style of the labels
    style = list("font-weight" = "normal", padding = "3px 8px"),
    textsize = "15px",
    direction = "auto")) %>%
  addLegend(pal = pal1, values = ~mean_minIncome, opacity = 1.5, 
            # Adding a legend to explain the colors and what is shown
            title = "Desired minimum wage <br> (in Euro)",
            position = "bottomright")

map2 # show the interactive map we created. We can save it as well as a html object









