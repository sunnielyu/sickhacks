rm(list=ls())

setwd("~/Downloads/MedHacks/v2/means_tx")

# Library

library(data.table)
library(stringr)
library(pscl)
library(boot)
library(dplyr)

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
md <- read.csv("Maryland_Hospitals__Hospitals.csv", stringsAsFactors = FALSE)
proper <- function(x){
    gsub("(?<=\\b)([a-z])", "\\U\\1", tolower(x), perl=TRUE)
  }

md$Facility_Name <- proper(md$Facility_Name)
md$Facility_Address <- proper(md$Facility_Address)
md$Facility_City <- proper(md$Facility_City)

write.csv(md, "md.csv")

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

# Merge with SickWeather API
#############################

swapi <- read.csv("sickWeatherAPI.csv")
zip_md_dens_api <- zip_md_dens %>% left_join(swapi, by = "zip")
zip_md_dens_api$respRiskScore <- zip_md_dens_api$overall/100

# zip_md_dens_api$overall[is.na(zip_md_dens_api$overall)] <- 0

zip_risk <- zip_md_dens_api

######################################
# Risk Prediction
######################################

zipNonZero <- zip_risk %>% filter(respRiskScore >= 0) %>%
  select(zip, dens, notworking, HC01_EST_VC08, HC01_EST_VC10, HC01_EST_VC13, HC01_EST_VC18, 
         HC01_EST_VC51, HC01_EST_VC126, HC01_EST_VC69, respRiskScore)
zipZero <- zip_risk %>% filter(is.na(respRiskScore)) %>% 
    select(zip, dens, notworking, HC01_EST_VC08, HC01_EST_VC10, HC01_EST_VC13, HC01_EST_VC18, 
           HC01_EST_VC51, HC01_EST_VC126, HC01_EST_VC69, respRiskScore)

# Linear Regression
summary(ml <- lm(respRiskScore ~ dens + HC01_EST_VC13 + HC01_EST_VC18 + HC01_EST_VC69 +
                  HC01_EST_VC08 + HC01_EST_VC126, 
                  data = zipNonZero))

# Logistic Regression
zipNonZero$outcome <- ifelse(zipNonZero$respRiskScore < 0.65, 0 ,1)

summary(logi <- glm(outcome ~ dens + HC01_EST_VC13 + HC01_EST_VC69 + HC01_EST_VC10 +
                   HC01_EST_VC08 + HC01_EST_VC126, family = binomial,
                 data = zipNonZero))

# Predicting NA sickWeatherAPI score
test <- predict(logi, zipZero, type = "response")
test_df <- cbind(test,zipZero)

test_df <- test_df %>% select(test, zip)

# Predicting non-NA sickWeatherAPI score
test1 <- predict(logi, zipNonZero, type = "response")
test1_df <- cbind(test1,zipNonZero)
test1_df$test <- test1_df$test1

test1_df <- test1_df %>% select(test, zip)

# Row bind
index <- rbind(test_df, test1_df)
index$index <- round(index$test*100,0)
index[is.na(index)] <- 0
zip_final <- zip_risk %>% left_join(index, by = "zip")

# FINAL
write.csv(zip_final, "zip_final.csv")





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
