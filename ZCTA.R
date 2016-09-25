rm(list=ls())

setwd("~/Downloads/MedHacks/v2/means_tx")

# Library

library(dplyr)
library(data.table)
library(stringr)
library(leaflet)

####################################
# Census Data: Transportation
####################################

data <- data.frame(fread("ACS_14_5YR_S0802_with_ann.csv", stringsAsFactors = FALSE))
data <- data[-1,]

# Dictionary
#############

dic <- fread("ACS_14_5YR_S0802_metadata.csv")

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

####################################
# Census Data: Healthcare Coverage
####################################
insur <- read.csv("/Users/kevinquach/Downloads/MedHacks/v2/means_tx/ACS_14_5YR_S2701/ACS_14_5YR_S2701_with_ann.csv", stringsAsFactors = FALSE)
insur1 <- insur[-1,]
insur2 <- insur1 %>% select(GEO.id2, HC03_EST_VC01, HC01_EST_VC41, HC01_EST_VC42)

insur2$GEO.id2 <- as.numeric(insur2$GEO.id2)
insur2$HC03_EST_VC01 <- as.numeric(insur2$HC03_EST_VC01)
insur2$HC01_EST_VC41 <- as.numeric(insur2$HC01_EST_VC41)
insur2$HC01_EST_VC42 <- as.numeric(insur2$HC01_EST_VC42)

insur3 <- mutate(insur2, notworking = round((HC01_EST_VC42/HC01_EST_VC41) * 100,0)) %>%
    select(GEO.id2, notworking, HC03_EST_VC01)
insur3$uninsured <- insur3$HC03_EST_VC01

data_final$GEO.id2 <- as.numeric(data_final$GEO.id2)

data_insur <- insur3 %>% left_join(data_final, by = "GEO.id2")

####################################
# Hospitals in Maryland
####################################
md_hospitals <- read.csv("Maryland_Hospitals__Hospitals.csv", stringsAsFactors = FALSE)

####################################
# ZipCode Dataset
####################################
library(zipcode)
data(zipcode)
zip_md <- zipcode %>% filter(state == "MD")

# Merge Zip with Demo
#####################
data_insur$GEO.id2 <- as.numeric(data_insur$GEO.id2)
zip_md$zip <- as.numeric(zip_md$zip)

zip_md_demo <- zip_md %>% left_join(data_insur, by = c("zip" = "GEO.id2"))
zip_md_demograph <- zip_md_demo %>% filter(!is.na(notworking))

# Merge with Popn Density
#########################

popdens <- read.csv("popdens.csv", stringsAsFactors = FALSE)

popdens1 <- popdens %>% filter(ZCTA5 >= 20000 & ZCTA5 < 30000) %>%
  mutate(dens = round(POPULATION/LANDSQMT * 1e6,0))

zip_md_dens <- zip_md_demograph %>% left_join(popdens1, by = c("zip" = "ZCTA5"))

# Leaflet
#############

library(bit64)
library(htmltools)
library(rgdal)
library(jsonlite)

# Maryland JSON
geodata <- readLines("maryland-zips-single.geojson") %>% paste(collapse = "\n")

# Popup Markers

# Model 1 - No Hospital
df <- zip_md_dens

leaflet(df) %>% setView(lng = -76.6141, lat = 39.3012, zoom = 13) %>%
  addMarkers(data = df, ~longitude, ~latitude, 
          popup = paste(
            "<b>Zip Code:</b>", df$zip, "</br>",
            "<b>City:</b>", df$city, "</br>",
            "<b>Pop Density (people/sqkm):</b>", df$dens, "</br>",
            "<b>Median Age:</b>", df$HC01_EST_VC10, "</br>",
            "<b>Male (%)</b>", df$HC01_EST_VC13, "</br>",
            "<b>White (%)</b>", df$HC01_EST_VC18, "</br>",
            "<b>:</b>", df$, "</br>",
          ), 
          options = popupOptions(closeOnClick = TRUE, closeButton = TRUE)) %>%
  addProviderTiles("CartoDB.Positron") %>%
  addGeoJSON(geodata, weight = 0.5, color = "#444444", fill = TRUE)

leaflet(df) %>% setView(lng = -76.6141, lat = 39.3012, zoom = 13) %>%
  addMarkers(~longitude, ~latitude, popup = paste(~notworking, ~uninsured)) %>%
  addProviderTiles("CartoDB.Positron") %>%
  addGeoJSON(geodata, weight = 0.5, color = "#444444", fill = FALSE)

# Model 2 - With Hospital
leaflet(df) %>% setView(lng = -76.6141, lat = 39.3012, zoom = 13) %>%
  addMarkers(data = df, ~longitude, ~latitude, popup = ~zip) %>%
  addProviderTiles("CartoDB.Positron") %>%
  addCircles(data = md_hospitals, lng = ~X, lat = ~Y) %>%
  addCircleMarkers(data = md_hospitals, color = "red", lng = ~X, lat = ~Y, popup = ~Facility_Name) %>%
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
