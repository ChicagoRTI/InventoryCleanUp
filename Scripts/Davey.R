# This script is used for standardizing Davey inventory data
# By: Lindsay Darling

# started on: July 9, 2019
# todo: Script being edited from SESYNC project. Needs lots of work to be applicable, but it's a start

# load useful libraries
install.packages("tidyverse")
install.packages("magrittr")  

# read in the inventory data
iTree_Baltimore_Tree <- read_csv(file.path('Forests_raw',
                                           'BaltimorePlots',   
                                           'iTree_Baltimore',
                                           'Baltimore-iTree-Data-1999-2004-2009-2014_led.csv')) %>% #Fixme In the original dataset the first column was labled "51". It is clearly the plot_ID. Plot 51 didn't have any data in the plot file, so I changed that cell to "PlotID" 
  select(`PlotID`,
         `YEAR`,
         `SPECIES CODE`,
         `%LEAF MISSING`,
         `TREE HT`,
         `DBH1` # fixme: DBH1 isn't always filled. Frequently there are data in dbh2 column.
         
  ) %>% 
  rename(plot_ID = `PlotID`,
         missing = `%LEAF MISSING`,
         obs_year =`YEAR`) %>% 
  
  mutate(data_source = 'iTree_Baltimore',
         sub_plot_ID = NA,
         tree_ID = row_number(),
         dbh_cm = `DBH1`*2.54,
         height_m = `TREE HT`  * 0.3048)  # fixme removing dead trees, do you want to do that?

# fixme Getting a parsing error. It doesn't seem to matter though.


# join with species reconciliaton list
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
