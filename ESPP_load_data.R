library(tidyverse)
library(ebbr)
library(plyr)
library(readxl)

#Load visit-level file:
full <- read.csv('preprocessed_df.csv')
#Load person-level data
person <- read.csv("person202105_cleaned.csv")

# Geographical Datasets
# Load WA State zip codes and zcta crosswalk
zip_to_zcta <- read_xlsx("ZiptoZcta_Crosswalk_2021.xlsx")
zip_to_zcta <- zip_to_zcta %>% slice(-which(is.na(zip_to_zcta$ZIP_CODE)))
# Load zip and county crosswalk
zcta_to_county <- read.csv("zcta_to_county.csv")
zcta_to_county = zcta_to_county %>% select(zcta5, county)

