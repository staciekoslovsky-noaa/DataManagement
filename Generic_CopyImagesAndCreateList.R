# Create starting image list for processing data to DB and copy images to external HD
# S. Hardy, 19FEB2020

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
install_pkg("RPostgres")

# Run code -------------------------------------------------------
con <- RPostgres::dbConnect(Postgres(), 
                              dbname = Sys.getenv("pep_db"), 
                              host = Sys.getenv("pep_ip"), 
                              user = Sys.getenv("pep_user"), 
                              port = Sys.getenv("pep_port"),
                              rstudioapi::askForPassword(paste("Enter your DB password for user account: ", Sys.getenv("pep_user"), sep = "")))
dat <- RPostgres::dbGetQuery(con, "select distinct image_name
                                      from surv_polar_bear.tbl_images
                                      inner join surv_polar_bear.geo_images_meta
                                      using (flight, camera_view, dt)
                                      where flight = \'fl07\'
                                      and camera_view = \'L\'
                                      and ins_roll < 10
                                      and ins_roll > -10
                                      and ins_altitude > 250
                                      and ins_altitude < 400
                                      and type = \'IR Image\'")

wd <- "//akc0ss-n086/NMML_Polar_Imagery/Techniques_Test/KAMERA_InFlightSystem_2019/polar_bear_2019/fl07/LEFT"
setwd(wd)

file.copy(dat$image_name, "E:/fl07/LEFT")

write.table(dat$image_name, "E:/fl07/LEFT/image_list_ir.txt", row.names = FALSE, col.names = FALSE, quote = FALSE)

