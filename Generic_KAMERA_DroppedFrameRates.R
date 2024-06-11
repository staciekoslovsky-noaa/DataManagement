# USPAI: Calculate Drop Frame Rates
# S. Koslovsky

# Define variables
project_folder <- 
  'I:\\Techniques_Test'
project <- 
 'KingAirTests_2024'
 #'uspai_2023'
flight <- 
 'fl01'
camera_config <-
  #'85mm_21_0deg_IRDetector_P1' #fl01-fl02
  '100mm_25_5deg_DualRegionTrigger' #fl01

# Create functions -----------------------------------------------
# Function to install packages needed
install_pkg <- function(x)
{
  if (!require(x,character.only = TRUE))
  {
    install.packages(x,dep=TRUE)
    if(!require(x,character.only = TRUE)) stop("Package not found")
  }
}

# Install libraries ----------------------------------------------
install_pkg("tidyverse")

# Read data from shapefiles ----------------------------------------------
center_wd <- paste0(project_folder, '\\', project, '\\', flight, '\\', camera_config, '\\center_view')
left_wd <- paste0(project_folder, '\\', project, '\\', flight, '\\', camera_config, '\\left_view')
right_wd <- paste0(project_folder, '\\', project, '\\', flight, '\\', camera_config, '\\right_view')

center <- data.frame(file = list.files(center_wd), stringsAsFactors = FALSE) %>%
  mutate(file_type = ifelse(grepl('ir', file), 'ir_image', 
                            ifelse(grepl('rgb', file), 'rgb_image',
                                   ifelse(grepl('meta', file), 'meta.json', 'other'))),
         dt = str_extract(file, "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9][0-9][0-9].[0-9][0-9][0-9][0-9][0-9][0-9]")) 
center_byFileType <- center %>%
  group_by(file_type) %>% 
  summarise(total_count=n(), .groups = 'drop')
center_byDT <- center %>%
  select(dt) %>%
  unique()
#rm(center)

left <- data.frame(file = list.files(left_wd), stringsAsFactors = FALSE) %>%
  mutate(file_type = ifelse(grepl('ir', file), 'ir_image', 
                            ifelse(grepl('rgb', file), 'rgb_image',
                                   ifelse(grepl('meta', file), 'meta.json', 'other'))),
         dt = str_extract(file, "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9][0-9][0-9].[0-9][0-9][0-9][0-9][0-9][0-9]")) 
left_byFileType <- left %>%
  group_by(file_type) %>% 
  summarise(total_count=n(), .groups = 'drop')
left_byDT <- left %>%
  select(dt) %>%
  unique()
#rm(left)

right <- data.frame(file = list.files(right_wd), stringsAsFactors = FALSE) %>%
  mutate(file_type = ifelse(grepl('ir', file), 'ir_image', 
                            ifelse(grepl('rgb', file), 'rgb_image',
                                   ifelse(grepl('meta', file), 'meta.json', 'other'))),
         dt = str_extract(file, "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9][0-9][0-9].[0-9][0-9][0-9][0-9][0-9][0-9]")) 
right_byFileType <- right %>%
  group_by(file_type) %>% 
  summarise(total_count=n(), .groups = 'drop')
right_byDT <- right %>%
  select(dt) %>%
  unique()
#rm(right)




# Append datasets and identify missing data
# data <- center %>%
#   bind_rows(left) %>%
#   bind_rows(right) %>%
#   mutate(camera_view = gsub("_", "", str_extract(file, "_[A-Z]_"))) %>%
#   spread(file_type, file) 
# write.csv(data, "C:\\smk\\USPAI_fl06_timestampPairings.csv", row.names = FALSE)
