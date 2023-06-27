# Create starting image list for processing data to DB and copy images to external HD

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
install_pkg("RPostgreSQL")

# Run code -------------------------------------------------------
con <- RPostgreSQL::dbConnect(PostgreSQL(), 
                              dbname = Sys.getenv("pep_db"), 
                              host = Sys.getenv("pep_ip"), 
                              user = Sys.getenv("pep_admin"),
                              password = Sys.getenv("admin_pw"))

data <- RPostgreSQL::dbGetQuery(con, "SELECT * FROM surv_test_kotz.annotations_pup_training_ir")
images <- RPostgreSQL::dbGetQuery(con, "SELECT * FROM surv_test_kotz.annotations_pup_training_ir_images")

write.table(data, "D:/seal_pups/Survey_Kotz/SurvKotz_seal_pups_training_ir_annotations.csv", row.names = FALSE, col.names = FALSE, quote = FALSE, sep = ',')
write.table(images$image_name, "D:/seal_pups/Survey_Kotz/SurvKotz_seal_pups_training_ir_images.txt", row.names = FALSE, col.names = FALSE, quote = FALSE)

file.copy(paste0(images$image_dir, "/", images$image_name), "D:/seal_pups/Survey_Kotz/images")

dbDisconnect(con)

