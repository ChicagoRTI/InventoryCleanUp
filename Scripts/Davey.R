# This script is used for standardizing Davey inventory data
# By: Lindsay Darling

# started on: July 9, 2019
# todo: Everything is good except the "StreetTree" coding to y/n

# load useful libraries
install.packages("tidyverse")
install.packages("magrittr")  
library(tidyverse)
library(magrittr)

# read in the inventory data
LakeForest <- read_csv(file.path('RawData',
                                 'LakeForestRaw.csv')) %>% 
  
  select(`LATITUDE,N,32,10`,
         `LONGITUDE,N,32,10`,
         `SPP,C,35`,
         `COND,C,9`,
         `INSPECT_DT,D`,
         `DBH,C,4`,
         `ID,N,11,0`,
         `LOCATION,C,17`,
         `STREET,C,23`,
         `SIDE,C,9`
         
  ) %>% 
  rename(Latitude = `LATITUDE,N,32,10`,
         Longitude = `LONGITUDE,N,32,10`,
         Year =`INSPECT_DT,D`,
         GenusSpecies = `SPP,C,35`,
         TreeID = `ID,N,11,0`,
         StreetTree = `LOCATION,C,17`,
         Site = `STREET,C,23`,
         Plot = `SIDE,C,9`,
         DBH_in = `DBH,C,4`,
         HealthWord = `COND,C,9`
         ) %>% 
  
  mutate(DataSource = 'LakeForest',
         InventoryTyp = 'Municipal',
         DataType = 'Point',
         LandUse = ''
       ) %>%
  mutate(HealthWord=recode(HealthWord,                      
                          'Critical' = 'Dead',
                          'Very Good' = 'Excellent')) %>%
  
  mutate(Year = lubridate::year(as.Date(`Year`, format = '%m/%d/%Y'))) %>%
  
  mutate(SteetTree=recode(StreetTree,
                          'Street' = 'Y',
                          'Park/Public Space' = 'N',
                          'Borderline' = 'N',
                          'Off ROW' = 'N',
                          'Unknown' = 'N',
                          'Woodlot' = 'N')) %>% #Coding street tree y/n FIXME this isn't working

  filter(GenusSpecies != "stump") %>%
  filter(GenusSpecies != "Tree Removal No Stump") %>%
  filter(GenusSpecies != "Tree Removed - Deerpath Golf Course") %>%
  filter(GenusSpecies != "Tree Removed Not Replaced") %>%
  filter(GenusSpecies != "vacant site small") %>% 
  filter(GenusSpecies != "New Tree") %>%
  filter(GenusSpecies != "New Tree Spring") %>%
  filter(GenusSpecies != "New Tree Fall") %>% #removing non trees 
  filter(Latitude != 0 ) # remove a couple of trees without coordinates




#Fix things that won't join

LakeForest$GenusSpecies <- gsub("'", "", LakeForest$GenusSpecies, fixed=TRUE)
LakeForest$GenusSpecies <- gsub(" x ", " ",LakeForest$GenusSpecies, fixed=TRUE)

LakeForest %<>%
  mutate(GenusSpecies=recode(GenusSpecies,
                           'Acer tataricum ginnala' ='Acer ginnala',
                           'Aesculus Autumn Splendor' ='Aesculus arnoldiana',
                           'Aesculus carnea'= 'Aesculus carnea',
                           'Cedrus atlantica' ='Cedrus spp.',
                           'Crataegus crusgalli' = 'Crataegus crus-galli',
                           'Gleditsia triacanthos inermis' = 'Gleditsia triacanthos',
                           'Laburnum watereri' = 'Laburnum alpinum',
                           'Maackia Amurensis' = 'Maackia amurensis',
                           'Magnolia soulangiana' = 'Magnolia soulangeana',
                           'Q. × macdanielli' = 'Quercus macdanielii',
                           'Quercus macrocarpa robur' = 'Quercus robur',
                           'Quercus x' = 'Quercus spp.',
                           'syringa chenensis' = 'Syringa pekinensis',
                           'Tabebuia umbellata' = 'Unknown spp.',
                           'Tsuga candensis' = 'Tsuga canadensis',
                           'Ulmus x' = 'Ulmus hybrid',
                           'unknown tree' = 'Unknown spp.',
                           'Ulmus thomasi' = 'Ulmus thomasii',
                           ))


# first read in the species list
species_list <- read_csv(file.path('RawData',
                                   'SpeciesList.csv'))


# Join species lists
LakeForest %<>% left_join(species_list,
                                    by = c('GenusSpecies'= 'GenusSpecies'))

#Read health lookup

HealthTable <- read.csv(file="C:/Users/Lindsay Darling/Documents/R/InventoryCleanUp/RawData/HealthTable.csv")

#Join health

LakeForest %<>% left_join(HealthTable,
                          by = c('HealthWord'= 'HealthWord'))

#Final Cleanup

LakeForest %<>%
  select(DataSource,
         InventoryTyp,
         DataType,
         Latitude,
         Longitude,
         LandUse,
         StreetTree,
         Year,
         Site,
         Plot,
         TreeID,
         Genus,
         Species,
         GenusSpecies,
         CommonName,
         DBH_in,
         HealthWord,
         HealthNum)

# double checks
View(LakeForest)
View(HealthTable)
View(species_list)


# save out the .csv
write.csv(LakeForest, file = file.path('ForestStandardized','LakeForest2019.csv'),
          row.names = FALSE)

# end here
#"2019-06-25 12:16:41 EDT"
