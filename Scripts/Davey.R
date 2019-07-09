# This script is used for standardizing Davey inventory data
# By: Lindsay Darling

# started on: July 9, 2019
# todo: Script being edited from SESYNC project. Needs lots of work to be applicable, but it's a start

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
         DBH_IN = `DBH,C,4`
         ) %>% 
  
  mutate(DataSource = 'LakeForest',
         InventoryTyp = 'Municipal',
         DataType = 'Point'
       ) 

# Remove non-applicable trees
  LakeForest %>% select(GenusSpecies =! STUMP,
                        )  

# first read in the species list
species_list <- read_csv(file.path('Forests_raw',
                                   'species_reconciliation/species_reconciliation_short.csv'))

# select columns, rename, and add a genus species column
species_list %<>% select(`FIA\nCode`, `PLANTS\nCode`, `Common Name`, Genus, Species) %>% 
  rename(FIA_code = `FIA\nCode`,
         PLANTS_code =`PLANTS\nCode`, 
         common_name =`Common Name`, 
         genus = Genus,
         species = Species) %>% 
  mutate(`genus species` = paste0(genus, ' ', species)) %>%
  rename (genus_species = `genus species`)

# add genus species to FIA_Tree by joining to the species list
iTree_Baltimore_Tree %<>% left_join(species_list,
                                    by = c('SPECIES CODE'= 'PLANTS_code'))
#Final Cleanup

iTree_Baltimore_Tree %<>%
  select(data_source,
         plot_ID,
         sub_plot_ID,
         tree_ID,
         obs_year,
         genus,
         species,
         genus_species,
         dbh_cm,
         height_m)

# double checks
View(iTree_Baltimore_Tree)

# save out the .csv
write.csv(iTree_Baltimore_Tree, file = file.path('forests_standardized','Baltimore_iTree_Tree.csv'),
          row.names = FALSE)

# end here
#"2019-06-25 12:16:41 EDT"
