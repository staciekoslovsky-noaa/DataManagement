# Data Management: Maintain Esri file geoDB for viewing PEP spatial data

# Variables ------------------------------------------------------
fgdb_path <- "O:\\Data\\_PEP_SpatialData4Esri.gdb"

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

install_pkg("tidyverse")
install_pkg("RPostgreSQL")
install_pkg("sf")
install_pkg("sp")
# install.packages("arcgisbinding", repos="https://r.esri.com", type="win.binary")
install_pkg("arcgisbinding")

# Load Ersi license 
arc.check_product()

# Connect to DB -------------------------------------------------
con <- RPostgreSQL::dbConnect(PostgreSQL(), 
                              dbname = Sys.getenv("pep_db"), 
                              host = Sys.getenv("pep_ip"), 
                              user = Sys.getenv("pep_admin"), 
                              rstudioapi::askForPassword(paste("Enter your DB password for user account: ", Sys.getenv("pep_admin"), sep = "")))


# Get data from DB ---------------------------------------------
### Base layers --------------------
# geo_analysis_grid_ak
analysis_grid_ak <- sf::st_read(con, query = "SELECT * FROM base.geo_analysis_grid_ak") %>%
  sf::as_Spatial()

arc.write(file.path(fgdb_path, "base\\geo_analysis_grid_ak"), data = analysis_grid_ak, overwrite = TRUE)

# geo_analysis_grid_ak_centroid
analysis_grid_ak_centroid <- sf::st_read(con, query = "SELECT * FROM base.geo_analysis_grid_ak_centroid") %>%
  sf::as_Spatial()

arc.write(file.path(fgdb_path, "base\\analysis_grid_ak_centroid"), data = analysis_grid_ak_centroid, overwrite = TRUE)

### Coastal harbor seal layers --------------------
# geo_polys
polys <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.geo_polys") %>%
  sf::as_Spatial()

arc.write(file.path(fgdb_path, "surv_pv_cst\\geo_polys"), data = polys, overwrite = TRUE)

# geo_haulout
haulout <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.geo_haulout", geometry = "geom") %>%
  sf::as_Spatial()

arc.write(file.path(fgdb_path, "surv_pv_cst\\geo_haulout"), data = haulout, overwrite = TRUE)

# geo_abundance_4agol
abundance_4agol <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.geo_abundance_4agol") %>%
  sf::as_Spatial()

arc.write(file.path(fgdb_path, "surv_pv_cst\\geo_abundance_4agol"), data = abundance_4agol, overwrite = TRUE)

### Glacial harbor seal layers --------------------


### Stock layers --------------------
# geo_dist_pv -- THROWING ERROR WHEN IMPORTING>>>>>>NEED TO REVISIT THIS ONE!!!!!!!!!!!
# geo_dist_pv <- sf::st_read(con, query = "SELECT * FROM stock.geo_dist_pv") %>%
#   sf::as_Spatial()
# 
# arc.write(file.path(fgdb_path, "stock\\geo_dist_pv"), data = geo_dist_pv, overwrite = TRUE)

# geo_dist_bd
geo_dist_bd <- sf::st_read(con, query = "SELECT * FROM stock.geo_dist_bd") %>%
  sf::as_Spatial()

arc.write(file.path(fgdb_path, "stock\\geo_dist_bd"), data = geo_dist_bd, overwrite = TRUE)

# geo_dist_rd
geo_dist_rd <- sf::st_read(con, query = "SELECT * FROM stock.geo_dist_rd") %>%
  sf::as_Spatial()

arc.write(file.path(fgdb_path, "stock\\geo_dist_rd"), data = geo_dist_rd, overwrite = TRUE)

# geo_dist_rn
geo_dist_rn <- sf::st_read(con, query = "SELECT * FROM stock.geo_dist_rn") %>%
  sf::as_Spatial()

arc.write(file.path(fgdb_path, "stock\\geo_dist_rn"), data = geo_dist_rn, overwrite = TRUE)

# geo_dist_sd
geo_dist_sd <- sf::st_read(con, query = "SELECT * FROM stock.geo_dist_sd") %>%
  sf::as_Spatial()

arc.write(file.path(fgdb_path, "stock\\geo_dist_sd"), data = geo_dist_sd, overwrite = TRUE)

# Disconnect from DB  --------------------------------------
RPostgreSQL::dbDisconnect(con)
rm(con)
