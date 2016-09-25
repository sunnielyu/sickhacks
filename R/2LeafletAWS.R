rm(list=ls())

# setwd("~/Downloads/MedHacks/v2/means_tx")

##########################
# Leaflet
##########################

library(RCurl)
library(htmltools)
library(jsonlite)
library(leaflet)
library(htmlwidgets)
library(dplyr)

# Reading in Files
df <- read.csv(textConnection(getURL("https://sickhacks.s3-us-west-2.amazonaws.com/zip_final.csv")), stringsAsFactors = FALSE) # Demo data with swAPI
md <- read.csv(textConnection(getURL("https://sickhacks.s3-us-west-2.amazonaws.com/md.csv")), stringsAsFactors = FALSE) # Hospital Data

# Maryland JSON
geodata <- readLines(textConnection(getURL("https://sickhacks.s3-us-west-2.amazonaws.com/maryland-zips-single.geojson"))) %>% paste(collapse = "\n")

# Leaflet Model

m <- leaflet(df) %>% setView(lng = -76.881929, lat = 38.91535, zoom = 8) %>%
  addProviderTiles("CartoDB.Positron") %>% 
  addGeoJSON(geodata, weight = 0.5, color = "#444444", fill = TRUE, fillOpacity = 0.5) %>%
  addCircles(data = df, ~longitude, ~latitude, 
             radius = ~index*10, stroke = TRUE,  fill = TRUE, fillOpacity = 0.5, color = "#FF3300") %>%
  addCircleMarkers(data = df, ~longitude, ~latitude, color = "black", stroke = FALSE,
                   fillOpacity = 0.1,
                   popup = paste(
                     "<b>Zip Code:</b>", df$zip, "</br>",
                     "<b>City:</b>", df$city, "</br>",
                     "<b>Pop Density (people/sqkm):</b>", df$dens, "</br>",
                     "<b>Median Age:</b>", df$HC01_EST_VC10, "</br>",
                     "<b> Age 60+ (%):</b>", df$HC01_EST_VC08, "</br>",
                     "<b>Male (%)</b>", df$HC01_EST_VC13, "</br>",
                     "<b>White (%)</b>", df$HC01_EST_VC18, "</br>",
                     "<b>Med. Earnings ($):</b>", df$HC01_EST_VC51, "</br>",
                     "<b>Poverty (%):</b>", df$HC01_EST_VC55, "</br>",
                     "<b>No Vehicle Availability (%):</b>", df$HC01_EST_VC126, "</br>",
                     "<b>Not insured (%):</b>", df$uninsured, "</br>",
                     "<b>FLU and COLD RISK INDEX (%):", df$index, "</b></br>"),
                   options = popupOptions(closeOnClick = TRUE, closeButton = TRUE)) %>%
  addCircles(data = md, lng = ~X, lat = ~Y, color = "yellow", stroke = TRUE) %>%
  addCircleMarkers(data = md, color = "yellow", lng = ~X, lat = ~Y, 
                   stroke = FALSE, fill = FALSE,
                   popup = paste(
                     "<b>", md$Facility_Name, "</b></br>",
                     md$Facility_Address, "</br>",
                     md$Facility_City, "MD </br>"))

# m

library(htmlwidgets)
saveWidget(m, file = "m.html")