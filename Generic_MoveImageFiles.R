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

install_pkg("filesstrings")
install_pkg("RPostgreSQL")

con <- RPostgreSQL::dbConnect(PostgreSQL(), 
                              dbname = Sys.getenv("pep_db"), 
                              host = Sys.getenv("pep_ip"), 
                              user = Sys.getenv("pep_admin"), 
                              rstudioapi::askForPassword(paste("Enter your DB password for user account: ", Sys.getenv("pep_admin"), sep = "")))

files <- RPostgreSQL::dbGetQuery(con, "select distinct filt_image_dir, filt_image, filt_image_dir || \'/\' || filt_image as filt_path
                                from surv_chess.alg_images_testset_withsightings t
                                 inner join surv_chess.tbl_filt
                                 on thermal_dt = filt_dt
                                 where filt_image LIKE \'%THERM-8-BIT%\'
                                 and species_id LIKE \'%Seal%\'")

#color <- list.files("D://01/CENT", full.names = TRUE, recursive = TRUE, pattern = "*rgb.tif")
#ir <- list.files("D://01/CENT", full.names = TRUE, recursive = TRUE, pattern = "*ir.tif")

for (i in 1:nrow(files)){
  file.copy(files$filt_path[i], "D://TestSet_IR_8bit")
}

