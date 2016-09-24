rm(list=ls())

setwd("~/Downloads/MedHacks/ACS_14_5YR_S0501")

# Library

library(data.table)
library(stringr)
library(leaflet)

#########
# Data
#########

data <- data.frame(fread("ACS_14_5YR_S0501_with_ann.csv", stringsAsFactors = FALSE))
data <- data[-1,]

#############
# Dictionary
#############

dic <- fread("ACS_14_5YR_S0501_metadata.csv")

# Renaming dataset
#####################

# Minimizing Dataset
#####################
data1 <- data %>% select(GEO.id2, GEO.display.label, HC01_EST_VC01, HC01_EST_VC03,
                         HC01_EST_VC04, HC01_EST_VC06, HC01_EST_VC07, HC01_EST_VC08,
                         HC01_EST_VC09, HC01_EST_VC10, HC01_EST_VC12, HC01_EST_VC14, HC01_EST_VC16,
                         HC01_EST_VC20, HC01_EST_VC21, HC01_EST_VC22, HC01_EST_VC23, HC01_EST_VC24, 
                         HC01_EST_VC25, HC01_EST_VC35, HC01_EST_VC36, HC01_EST_VC40, HC01_EST_VC41,
                         HC01_EST_VC42, HC01_EST_VC43, HC01_EST_VC57, HC01_EST_VC58, HC01_EST_VC68,
                         HC01_EST_VC69, HC01_EST_VC70, HC01_EST_VC116, HC01_EST_VC117, HC01_EST_VC133,
                         HC01_EST_VC138, HC01_EST_VC139, HC01_EST_VC140, HC01_EST_VC172, HC01_EST_VC173)

# Converting to numeric
#######################
num <- grepl("HC01_EST_VC", names(data1))
data1[num] <- lapply(data1[num], function(x) replace(x, x == "-" | x== "+" | x == "*****" | x == "N" |
                                                       x == "(X)" | x == "*" | x == "**", ""))

data1[,3:38] <- sapply(data1[,3:38], as.numeric) # DONE

# Leaflet
#########



# Extract ZipCode
#######################

# zipcode <- "[2][0-9][0-9][0-9][0-9]"
# data1$zipcode <- str_extract(data1$GEO.display.label, zipcode)
