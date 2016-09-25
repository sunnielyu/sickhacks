rm(list=ls())

setwd("~/Downloads/MedHacks/v2/means_tx")

# Library

library(data.table)
library(stringr)
library(leaflet)

#########
# Data
#########

data <- data.frame(fread("ACS_14_5YR_S0802_with_ann.csv", stringsAsFactors = FALSE))
data <- data[-1,]

#############
# Dictionary
#############

dic <- fread("ACS_14_5YR_S0802_metadata.csv")

# Renaming dataset
#####################

# Minimizing Dataset
#####################

# Converting to numeric
#######################

tokeep <- grep("HC01_EST_VC", names(data))
dataid <- data[,1:3]
data1 <- data[,tokeep]
data2 <- cbind(dataid, data1)

num <- grepl("HC01_EST_VC", names(data2))
data2[num] <- lapply(data2[num], function(x) replace(x, x == "-" | x== "+" | x == "*****" | x == "N" |
                                                       x == "(X)" | x == "*" | x == "**", ""))

data2[,4:104] <- sapply(data2[,4:104], as.numeric) # DONE
data_final <- data2 # DATA DONE

# ZipCode Dataset
#####################
data(zipcode)
zip_md <- zipcode %>% filter(state == "MD")

# Merge Zip with Demo
#####################
data_final$GEO.id2 <- as.numeric(data_final$GEO.id2)
zip_md$zip <- as.numeric(zip_md$zip)

zip_md_demo <- zip_md %>% left_join(data_final, by = c("zip" = "GEO.id2"))

# Leaflet
#############

library(bit64)
library(rgdal)
library(jsonlite)

# Maryland JSON
geodata <- readLines("maryland-zips-single.geojson") %>% paste(collapse = "\n")

leaflet(zip_md) %>% setView(lng = -76.6141, lat = 39.3012, zoom = 13) %>%
  addMarkers(~longitude, ~latitude, popup = ~zip) %>%
  addProviderTiles("CartoDB.Positron") %>%
  addGeoJSON(geodata, weight = 0.5, color = "#444444", fill = FALSE)
  










#############################################
# NON WORKING CODES - DO NOT RUN BELOW #
#############################################

# LABELING UNFINISHED # TACKLE LATER
#############################################
# Labeling Variables
#######################
var <- data.frame(names(data1))
var$names.data1. <- as.character(var$names.data1.)
varlabel <- var %>% left_join(dic, by = c("names.data1." = "GEO.id"))

labellist <- paste(varlabel$names.data1.,"='",varlabel$Id, "'", collapse = ", ")

label(data1) = lapply(names(labellist), function(x) label(data1[,x]) = labellist[x])
label(data1)

# Extract ZipCode
#######################

# zipcode <- "[2][0-9][0-9][0-9][0-9]"
# data1$zipcode <- str_extract(data1$GEO.display.label, zipcode)

# Failed ZipCode Boundaries
#############################

# Maryland SHP
md <- readOGR("/Users/kevinquach/Downloads/MedHacks/v2/means_tx/zctz",
              layer = "zctz_statewide_shoreline", verbose = FALSE, stringsAsFactors = FALSE)

# USA SHP
usa <- readOGR("/Users/kevinquach/Downloads/MedHacks/v2/means_tx/cbs", 
               layer = "cb_2015_us_state_500k", verbose = FALSE)

# Maryland Polygons
zip_gons <- fread("2010_MD_Statewide_Zip_Codes.csv", stringsAsFactors = FALSE)
