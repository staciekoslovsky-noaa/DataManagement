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
### Base layers
# geo_analysis_grid_ak
analysis_grid_ak <- sf::st_read(con, query = "SELECT * FROM base.geo_analysis_grid_ak") %>%
  sf::st_transform(4326) %>%
  sf::as_Spatial()

arc.write(file.path(fgdb_path, "base\\geo_analysis_grid_ak"), data = analysis_grid_ak)

### Coastal harbor seal layers
# geo_polys
polys <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.geo_polys") %>%
  sf::st_transform(4326) %>%
  sf::as_Spatial()

arc.write(file.path(fgdb_path, "surv_pv_cst\\geo_polys"), data = polys)

# geo_haulout
haulout <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.geo_haulout", geometry = "geom") %>%
  sf::st_transform(4326) %>%
  sf::as_Spatial()

arc.write(file.path(fgdb_path, "surv_pv_cst\\geo_haulout"), data = haulout)

# geo_abundance_4agol
abundance_4agol <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.geo_abundance_4agol") %>%
  sf::st_transform(4326) %>%
  sf::as_Spatial()

arc.write(file.path(fgdb_path, "surv_pv_cst\\geo_abundance_4agol"), data = abundance_4agol)

### Glacial harbor seal layers

