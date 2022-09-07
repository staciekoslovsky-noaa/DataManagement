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
install_pkg("reticulate")


# Load Ersi license 
#use_python("C:/Python27/ArcGIS10.8/python.exe")
#ARCPY <- import("arcpy")
arc.check_product()

# Connect to DB -------------------------------------------------
con <- RPostgreSQL::dbConnect(PostgreSQL(), 
                              dbname = Sys.getenv("pep_db"), 
                              host = Sys.getenv("pep_ip"), 
                              user = Sys.getenv("pep_admin"), 
                              password = Sys.getenv("admin_pw"))
                              #rstudioapi::askForPassword(paste("Enter your DB password for user account: ", Sys.getenv("pep_admin"), sep = "")))


# Get data from DB ---------------------------------------------

### base --------------------
# geo_alaska_dcw
geo_alaska_dcw <- sf::st_read(con, query = "SELECT * FROM base.geo_alaska_dcw") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "base\\geo_alaska_dcw"), data = geo_alaska_dcw, overwrite = TRUE, validate = TRUE)
rm(geo_alaska_dcw)

# geo_alaska_dnr_adjusted
geo_alaska_dnr_adjusted <- sf::st_read(con, query = "SELECT * FROM base.geo_alaska_dnr_adjusted") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "base\\geo_alaska_dnr_adjusted"), data = geo_alaska_dnr_adjusted, overwrite = TRUE, validate = TRUE)
rm(geo_alaska_dnr_adjusted)

# geo_analysis_grid
geo_analysis_grid <- sf::st_read(con, query = "SELECT * FROM base.geo_analysis_grid") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "base\\geo_analysis_grid"), data = geo_analysis_grid, overwrite = TRUE, validate = TRUE)
rm(geo_analysis_grid)

# geo_analysis_grid_ak
geo_analysis_grid_ak <- sf::st_read(con, query = "SELECT * FROM base.geo_analysis_grid_ak") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "base\\geo_analysis_grid_ak"), data = geo_analysis_grid_ak, overwrite = TRUE, validate = TRUE)
rm(geo_analysis_grid_ak)

# geo_analysis_grid_ak_centroid
geo_analysis_grid_ak_centroid <- sf::st_read(con, query = "SELECT * FROM base.geo_analysis_grid_ak_centroid") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "base\\geo_analysis_grid_ak_centroid"), data = geo_analysis_grid_ak_centroid, overwrite = TRUE, validate = TRUE)
rm(geo_analysis_grid_ak_centroid)

# geo_analysis_grid_centroid
geo_analysis_grid_centroid <- sf::st_read(con, query = "SELECT * FROM base.geo_analysis_grid_centroid") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "base\\geo_analysis_grid_centroid"), data = geo_analysis_grid_centroid, overwrite = TRUE, validate = TRUE)
rm(geo_analysis_grid_centroid)

# geo_analysis_grid_no_polarbear
geo_analysis_grid_no_polarbear <- sf::st_read(con, query = "SELECT * FROM base.geo_analysis_grid_no_polarbear") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "base\\geo_analysis_grid_no_polarbear"), data = geo_analysis_grid_no_polarbear, overwrite = TRUE, validate = TRUE)
rm(geo_analysis_grid_no_polarbear)



### body_condition --------------------
# geo_images
geo_images <- sf::st_read(con, query = "SELECT * FROM body_condition.geo_images") %>%
  mutate(exif_image_dt = as.POSIXct(exif_image_dt, format = "%F"),
         file_access_dt = as.POSIXct(file_access_dt, format = "%F"),
         adjusted_image_dt = as.POSIXct(adjusted_image_dt, format = "%F")) %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "body_condition\\geo_images"), data = geo_images, overwrite = TRUE, validate = TRUE)
rm(geo_images)

# geo_lrf_feed
geo_lrf_feed <- sf::st_read(con, query = "SELECT * FROM body_condition.geo_lrf_feed") %>%
  mutate(gps_dt = as.POSIXct(gps_dt, format = "%F")) %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "body_condition\\geo_lrf_feed"), data = geo_lrf_feed, overwrite = TRUE, validate = TRUE)
rm(geo_lrf_feed)



### capture --------------------
# geo_captures
RPostgreSQL::dbSendQuery(con, "UPDATE capture.tbl_event SET capture_geom = ST_SetSRID(ST_MakePoint(capture_long, capture_lat), 4326)")

geo_captures <- sf::st_read(con, query = "SELECT * FROM capture.geo_captures WHERE capture_geom IS NOT NULL") %>%
  mutate(capture_dt = as.POSIXct(capture_dt, format = "%F")) %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "capture\\geo_captures"), data = geo_captures, overwrite = TRUE, validate = TRUE)
rm(geo_captures)



### stock --------------------
# geo_dist_pv -- THROWING ERROR WHEN IMPORTING>>>>>>NEED TO REVISIT THIS ONE!!!!!!!!!!!
# geo_dist_pv <- sf::st_read(con, query = "SELECT * FROM stock.geo_dist_pv") %>%
#   sf::as_Spatial()
# arc.write(file.path(fgdb_path, "stock\\geo_dist_pv"), data = geo_dist_pv, overwrite = TRUE, validate = TRUE)
# rm(geo_dist_pv)

# geo_dist_bd
geo_dist_bd <- sf::st_read(con, query = "SELECT * FROM stock.geo_dist_bd") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "stock\\geo_dist_bd"), data = geo_dist_bd, overwrite = TRUE, validate = TRUE)
rm(geo_dist_bd)

# geo_dist_rd
geo_dist_rd <- sf::st_read(con, query = "SELECT * FROM stock.geo_dist_rd") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "stock\\geo_dist_rd"), data = geo_dist_rd, overwrite = TRUE, validate = TRUE)
rm(geo_dist_rd)

# geo_dist_rn
geo_dist_rn <- sf::st_read(con, query = "SELECT * FROM stock.geo_dist_rn") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "stock\\geo_dist_rn"), data = geo_dist_rn, overwrite = TRUE, validate = TRUE)
rm(geo_dist_rn)

# geo_dist_sd
geo_dist_sd <- sf::st_read(con, query = "SELECT * FROM stock.geo_dist_sd") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "stock\\geo_dist_sd"), data = geo_dist_sd, overwrite = TRUE, validate = TRUE)
rm(geo_dist_sd)



### surv_boss --------------------
# geo_detections_by_frame_bb
geo_detections_by_frame_bb <- sf::st_read(con, query = "SELECT * FROM surv_boss.geo_detections_by_frame_bb") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_boss\\geo_detections_by_frame_bb"), data = geo_detections_by_frame_bb, overwrite = TRUE, validate = TRUE)
rm(geo_detections_by_frame_bb)

# geo_fastice_2012_nic
geo_fastice_2012_nic <- sf::st_read(con, query = "SELECT * FROM surv_boss.geo_fastice_2012_nic") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_boss\\geo_fastice_2012_nic"), data = geo_fastice_2012_nic, overwrite = TRUE, validate = TRUE)
rm(geo_fastice_2012_nic)

# geo_fastice_2012_nws
geo_fastice_2012_nws <- sf::st_read(con, query = "SELECT * FROM surv_boss.geo_fastice_2012_nws") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_boss\\geo_fastice_2012_nws"), data = geo_fastice_2012_nws, overwrite = TRUE, validate = TRUE)
rm(geo_fastice_2012_nws)

# geo_fastice_2013_nic
geo_fastice_2013_nic <- sf::st_read(con, query = "SELECT * FROM surv_boss.geo_fastice_2013_nic") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_boss\\geo_fastice_2013_nic"), data = geo_fastice_2013_nic, overwrite = TRUE, validate = TRUE)
rm(geo_fastice_2013_nic)

# geo_fastice_2013_nws
geo_fastice_2013_nws <- sf::st_read(con, query = "SELECT * FROM surv_boss.geo_fastice_2013_nws") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_boss\\geo_fastice_2013_nws"), data = geo_fastice_2013_nws, overwrite = TRUE, validate = TRUE)
rm(geo_fastice_2013_nws)

# geo_fmc_log
geo_fmc_log <- sf::st_read(con, query = "SELECT * FROM surv_boss.geo_fmc_log") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_boss\\geo_fmc_log"), data = geo_fmc_log, overwrite = TRUE, validate = TRUE)
rm(geo_fmc_log)

# geo_hotspots -- THROWING ERROR WHEN IMPORTING>>>>>>NEED TO REVISIT THIS ONE!!!!!!!!!!!
# geo_hotspots <- sf::st_read(con, query = "SELECT * FROM surv_boss.geo_hotspots WHERE geom IS NOT NULL") %>%
#   sf::as_Spatial()
# arc.write(file.path(fgdb_path, "surv_boss\\geo_hotspots"), data = geo_hotspots, overwrite = TRUE, validate = TRUE)
# rm(geo_hotspots)

# geo_images
geo_images <- sf::st_read(con, query = "SELECT * FROM surv_boss.geo_images") %>%
  mutate(image_dt = as.POSIXct(image_dt, format = "%F")) %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_boss\\geo_images"), data = geo_images, overwrite = TRUE, validate = TRUE)
rm(geo_images)

# geo_tracks_by_effort -- THROWING ERROR WHEN IMPORTING>>>>>>NEED TO REVISIT THIS ONE!!!!!!!!!!!
# geo_tracks_by_effort <- sf::st_read(con, query = "SELECT * FROM surv_boss.geo_tracks_by_effort") %>%
#   sf::as_Spatial()
# arc.write(file.path(fgdb_path, "surv_boss\\geo_tracks_by_effort"), data = geo_tracks_by_effort, overwrite = TRUE, validate = TRUE)
# rm(geo_tracks_by_effort)

# geo_tracks_on_effort -- THROWING ERROR WHEN IMPORTING>>>>>>NEED TO REVISIT THIS ONE!!!!!!!!!!!
# geo_tracks_on_effort <- sf::st_read(con, query = "SELECT * FROM surv_boss.geo_tracks_on_effort") %>%
#   sf::as_Spatial()
# arc.write(file.path(fgdb_path, "surv_boss\\geo_tracks_on_effort"), data = geo_tracks_on_effort, overwrite = TRUE, validate = TRUE)
# rm(geo_tracks_on_effort)

# geo_tracks_on_effort_2012
geo_tracks_on_effort_2012 <- sf::st_read(con, query = "SELECT * FROM surv_boss.geo_tracks_on_effort_2012") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_boss\\geo_tracks_on_effort_2012"), data = geo_tracks_on_effort_2012, overwrite = TRUE, validate = TRUE)
rm(geo_tracks_on_effort_2012)

# geo_tracks_on_effort_2013 -- THROWING ERROR WHEN IMPORTING>>>>>>NEED TO REVISIT THIS ONE!!!!!!!!!!!
# geo_tracks_on_effort_2013 <- sf::st_read(con, query = "SELECT * FROM surv_boss.geo_tracks_on_effort_2013") %>%
#   sf::as_Spatial()
# arc.write(file.path(fgdb_path, "surv_boss\\geo_tracks_on_effort_2013"), data = geo_tracks_on_effort_2013, overwrite = TRUE, validate = TRUE)
# rm(geo_tracks_on_effort_2013)



### surv_chess --------------------
# geo_fastice -- THROWING ERROR WHEN IMPORTING>>>>>>NEED TO REVISIT THIS ONE!!!!!!!!!!!
# geo_fastice <- sf::st_read(con, query = "SELECT * FROM surv_chess.geo_fastice") %>%
#   sf::as_Spatial()
# arc.write(file.path(fgdb_path, "surv_chess\\geo_fastice"), data = geo_fastice, overwrite = TRUE, validate = TRUE)
# rm(geo_fastice)

# geo_polar_bear
geo_polar_bear <- sf::st_read(con, query = "SELECT * FROM surv_chess.geo_polar_bear") %>%
  mutate(sighting_dt = as.POSIXct(sighting_dt, format = "%F")) %>%  
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_chess\\geo_polar_bear"), data = geo_polar_bear, overwrite = TRUE, validate = TRUE)
rm(geo_polar_bear)

# geo_process_with_effort
geo_process_with_effort <- sf::st_read(con, query = "SELECT * FROM surv_chess.geo_process_with_effort") %>%
  mutate(correct_dt = as.POSIXct(correct_dt, format = "%F")) %>%  
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_chess\\geo_process_with_effort"), data = geo_process_with_effort, overwrite = TRUE, validate = TRUE)
rm(geo_process_with_effort)

# geo_track_by_effort -- THROWING ERROR WHEN IMPORTING>>>>>>NEED TO REVISIT THIS ONE!!!!!!!!!!!
# geo_track_by_effort <- sf::st_read(con, query = "SELECT * FROM surv_chess.geo_track_by_effort") %>%
#   sf::as_Spatial()
# arc.write(file.path(fgdb_path, "surv_chess\\geo_track_by_effort"), data = geo_track_by_effort, overwrite = TRUE, validate = TRUE)
# rm(geo_track_by_effort)

# geo_track_by_flight -- THROWING ERROR WHEN IMPORTING>>>>>>NEED TO REVISIT THIS ONE!!!!!!!!!!!
# geo_track_by_flight <- sf::st_read(con, query = "SELECT * FROM surv_chess.geo_track_by_flight") %>%
#   sf::as_Spatial()
# arc.write(file.path(fgdb_path, "surv_chess\\geo_track_by_flight"), data = geo_track_by_flight, overwrite = TRUE, validate = TRUE)
# (geo_track_by_flight)

# tbl_detect
tbl_detect <- sf::st_read(con, query = "SELECT * FROM surv_chess.tbl_detect") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_chess\\tbl_detect"), data = tbl_detect, overwrite = TRUE, validate = TRUE)
rm(tbl_detect)

# tbl_effort_raw
tbl_effort_raw <- sf::st_read(con, query = "SELECT * FROM surv_chess.tbl_effort_raw") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_chess\\tbl_effort_raw"), data = tbl_effort_raw, overwrite = TRUE, validate = TRUE)
rm(tbl_effort_raw)

# tbl_process
tbl_process <- sf::st_read(con, query = "SELECT * FROM surv_chess.tbl_process") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_chess\\tbl_process"), data = tbl_process, overwrite = TRUE, validate = TRUE)
rm(tbl_process)

# tbl_unfilt_detect_seal
tbl_unfilt_detect_seal <- sf::st_read(con, query = "SELECT * FROM surv_chess.tbl_unfilt_detect_seal") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_chess\\tbl_unfilt_detect_seal"), data = tbl_unfilt_detect_seal, overwrite = TRUE, validate = TRUE)
rm(tbl_unfilt_detect_seal)

# tbl_valid
tbl_valid <- sf::st_read(con, query = "SELECT * FROM surv_chess.tbl_valid") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_chess\\tbl_valid"), data = tbl_valid, overwrite = TRUE, validate = TRUE)
rm(tbl_valid)




### surv_jobss --------------------
# geo_detections_by_frame -- THROWING ERROR WHEN IMPORTING>>>>>>NEED TO REVISIT THIS ONE!!!!!!!!!!!
geo_detections_by_frame <- sf::st_read(con, query = "SELECT * FROM surv_jobss.geo_detections_by_frame") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_jobss\\geo_detections_by_frame_j"), data = geo_detections_by_frame, overwrite = TRUE, validate = TRUE)
rm(geo_detections_by_frame)

# geo_detections_by_seal
geo_detections_by_seal <- sf::st_read(con, query = "SELECT * FROM surv_jobss.geo_detections_by_seal") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_jobss\\geo_detections_by_seal_j"), data = geo_detections_by_seal, overwrite = TRUE, validate = TRUE)
rm(geo_detections_by_seal)

# geo_images_meta
geo_images_meta <- sf::st_read(con, query = "SELECT * FROM surv_jobss.geo_images_meta") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_jobss\\geo_images_meta_j"), data = geo_images_meta, overwrite = TRUE, validate = TRUE)
rm(geo_images_meta)




### surv_polar_bear --------------------
# geo_detections_by_frame
geo_detections_by_frame <- sf::st_read(con, query = "SELECT * FROM surv_polar_bear.geo_detections_by_frame") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_polar_bear\\geo_detections_by_frame_pb"), data = geo_detections_by_frame, overwrite = TRUE, validate = TRUE)
rm(geo_detections_by_frame)

# geo_detections_by_seal
geo_detections_by_seal <- sf::st_read(con, query = "SELECT * FROM surv_polar_bear.geo_detections_by_seal") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_polar_bear\\geo_detections_by_seal_pb"), data = geo_detections_by_seal, overwrite = TRUE, validate = TRUE)
rm(geo_detections_by_seal)

# geo_images_footprint
geo_images_footprint <- sf::st_read(con, query = "SELECT * FROM surv_polar_bear.geo_images_footprint") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_polar_bear\\geo_images_footprint_pb"), data = geo_images_footprint, overwrite = TRUE, validate = TRUE)
rm(geo_images_footprint)

# geo_images_meta
geo_images_meta <- sf::st_read(con, query = "SELECT * FROM surv_polar_bear.geo_images_meta") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_polar_bear\\geo_images_meta_pb"), data = geo_images_meta, overwrite = TRUE, validate = TRUE)
rm(geo_images_meta)




### surv_pv_cst --------------------
# geo_abundance_4agol
geo_abundance_4agol <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.geo_abundance_4agol") %>%
  mutate(last_surveyed = as.POSIXct(last_surveyed, format = "%F")) %>%
  sf::as_Spatial() 
arc.write(file.path(fgdb_path, "surv_pv_cst\\geo_abundance_4agol"), data = geo_abundance_4agol, overwrite = TRUE, validate = TRUE)
rm(geo_abundance_4agol)

# geo_flir_plane2target
geo_flir_plane2target <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.geo_flir_plane2target") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\geo_flir_plane2target"), data = geo_flir_plane2target, overwrite = TRUE, validate = TRUE)
rm(geo_flir_plane2target)

# geo_haulout
geo_haulout <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.geo_haulout", geometry = "geom") %>%
  mutate(date_created = as.POSIXct(date_created, format = "%F"),
         date_retired = as.POSIXct(date_retired, format = "%F")) %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\geo_haulout"), data = geo_haulout, overwrite = TRUE, validate = TRUE)
rm(geo_haulout)

# geo_haulout_20171215
geo_haulout_20171215 <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.geo_haulout_20171215", geometry = "geom") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\geo_haulout_20171215"), data = geo_haulout_20171215, overwrite = TRUE, validate = TRUE)
rm(geo_haulout_20171215)

# geo_haulout_20180105
geo_haulout_20180105 <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.geo_haulout_20180105", geometry = "geom") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\geo_haulout_20180105"), data = geo_haulout_20180105, overwrite = TRUE, validate = TRUE)
rm(geo_haulout_20180105)

# geo_haulout_20190227
geo_haulout_20190227 <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.geo_haulout_20190227", geometry = "geom") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\geo_haulout_20190227"), data = geo_haulout_20190227, overwrite = TRUE, validate = TRUE)
rm(geo_haulout_20190227)

# geo_haulout_20210105
geo_haulout_20210105 <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.geo_haulout_20210105", geometry = "geom") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\geo_haulout_20210105"), data = geo_haulout_20210105, overwrite = TRUE, validate = TRUE)
rm(geo_haulout_20210105)

# geo_haulout_20220414
geo_haulout_20220414 <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.geo_haulout_20220414", geometry = "geom") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\geo_haulout_20220414"), data = geo_haulout_20220414, overwrite = TRUE, validate = TRUE)
rm(geo_haulout_20220414)

# geo_polys
geo_polys <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.geo_polys") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\geo_polys"), data = geo_polys, overwrite = TRUE, validate = TRUE)
rm(geo_polys)

# geo_priorities_201706
geo_priorities_201706 <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.geo_priorities_201706") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\geo_priorities_201706"), data = geo_priorities_201706, overwrite = TRUE, validate = TRUE)
rm(geo_priorities_201706)

# geo_priorities_201708
geo_priorities_201708 <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.geo_priorities_201708") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\geo_priorities_201708"), data = geo_priorities_201708, overwrite = TRUE, validate = TRUE)
rm(geo_priorities_201708)

# geo_priorities_201808
geo_priorities_201808 <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.geo_priorities_201808") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\geo_priorities_201808"), data = geo_priorities_201808, overwrite = TRUE, validate = TRUE)
rm(geo_priorities_201808)

# geo_priorities_201809
geo_priorities_201809 <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.geo_priorities_201809") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\geo_priorities_201809"), data = geo_priorities_201809, overwrite = TRUE, validate = TRUE)
rm(geo_priorities_201809)

# geo_priorities_201906
geo_priorities_201906 <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.geo_priorities_201906") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\geo_priorities_201906"), data = geo_priorities_201906, overwrite = TRUE, validate = TRUE)
rm(geo_priorities_201906)

# geo_priorities_201908
geo_priorities_201908 <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.geo_priorities_201908") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\geo_priorities_201908"), data = geo_priorities_201908, overwrite = TRUE, validate = TRUE)
rm(geo_priorities_201908)

# geo_priorities_202108
geo_priorities_202108 <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.geo_priorities_202108") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\geo_priorities_202108"), data = geo_priorities_202108, overwrite = TRUE, validate = TRUE)
rm(geo_priorities_202108)

# geo_priorities_202108
geo_priorities_202108 <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.geo_priorities_202208") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\geo_priorities_202108"), data = geo_priorities_202208, overwrite = TRUE, validate = TRUE)
rm(geo_priorities_202208)

# geo_track_lines
geo_track_lines <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.geo_track_lines") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\geo_track_lines"), data = geo_track_lines, overwrite = TRUE, validate = TRUE)
rm(geo_track_lines)

# geo_track_pts
geo_track_pts <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.geo_track_pts") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\geo_track_pts"), data = geo_track_pts, overwrite = TRUE, validate = TRUE)
rm(geo_track_pts)

# summ_count_by_image
summ_count_by_image <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.summ_count_by_image") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\summ_count_by_image"), data = summ_count_by_image, overwrite = TRUE, validate = TRUE)
rm(summ_count_by_image)

# summ_count_by_image_iliamna
summ_count_by_image_iliamna <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.summ_count_by_image_iliamna") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\summ_count_by_image_iliamna"), data = summ_count_by_image_iliamna, overwrite = TRUE, validate = TRUE)
rm(summ_count_by_image_iliamna)

# tbl_effort
tbl_effort <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.tbl_effort WHERE geom IS NOT NULL") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\tbl_effort"), data = tbl_effort, overwrite = TRUE, validate = TRUE)
rm(tbl_effort)

# tbl_image_exif
tbl_image_exif <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.tbl_image_exif") %>%
  mutate(survey_date = as.POSIXct(survey_date, format = "%F"),
         survey_dt = as.POSIXct(survey_dt, format = "%F"),
         nearest_high_dt = as.POSIXct(nearest_high_dt, format = "%F"),
         nearest_low_dt = as.POSIXct(nearest_low_dt, format = "%F")) %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\tbl_image_exif"), data = tbl_image_exif, overwrite = TRUE, validate = TRUE)
rm(tbl_image_exif)

# tbl_image_flir
tbl_image_flir <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.tbl_image_flir") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\tbl_image_flir"), data = tbl_image_flir, overwrite = TRUE, validate = TRUE)
rm(tbl_image_flir)



### surv_pv_gla -------------------
# geo_glaciers
geo_glaciers <- sf::st_read(con, query = "SELECT * FROM surv_pv_gla.geo_glaciers") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_gla\\geo_glaciers"), data = geo_glaciers, overwrite = TRUE, validate = TRUE)
rm(geo_glaciers)

# geo_images_meta
geo_images_meta <- sf::st_read(con, query = "SELECT * FROM surv_pv_gla.geo_images_meta") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_gla\\geo_images_meta_g"), data = geo_images_meta, overwrite = TRUE, validate = TRUE)
rm(geo_images_meta)

# geo_routes -- THROWING ERROR WHEN IMPORTING>>>>>>NEED TO REVISIT THIS ONE!!!!!!!!!!!
# geo_routes <- sf::st_read(con, query = "SELECT * FROM surv_pv_gla.geo_routes") %>%
#   sf::as_Spatial()
# arc.write(file.path(fgdb_path, "surv_pv_gla\\geo_routes"), data = geo_routes, overwrite = TRUE, validate = TRUE)
# rm(geo_routes)

# geo_waypoints -- THROWING ERROR WHEN IMPORTING>>>>>>NEED TO REVISIT THIS ONE!!!!!!!!!!!
# geo_waypoints <- sf::st_read(con, query = "SELECT * FROM surv_pv_gla.geo_waypoints") %>%
#   sf::as_Spatial()
# arc.write(file.path(fgdb_path, "surv_pv_gla\\geo_waypoints"), data = geo_waypoints, overwrite = TRUE, validate = TRUE)
# rm(geo_waypoints)



### surv_test_kotz --------------------
# geo_detections_by_frame
geo_detections_by_frame <- sf::st_read(con, query = "SELECT * FROM surv_test_kotz.geo_detections_by_frame") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_test_kotz\\geo_detections_by_frame_k"), data = geo_detections_by_frame, overwrite = TRUE, validate = TRUE)
rm(geo_detections_by_frame)

# geo_detections_by_seal
geo_detections_by_seal <- sf::st_read(con, query = "SELECT * FROM surv_test_kotz.geo_detections_by_seal") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_test_kotz\\geo_detections_by_seal_k"), data = geo_detections_by_seal, overwrite = TRUE, validate = TRUE)
rm(geo_detections_by_seal)

# geo_images_footprint
geo_images_footprint <- sf::st_read(con, query = "SELECT * FROM surv_test_kotz.geo_images_footprint") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_test_kotz\\geo_images_footprint_k"), data = geo_images_footprint, overwrite = TRUE, validate = TRUE)
rm(geo_images_footprint)

# geo_images_meta
geo_images_meta <- sf::st_read(con, query = "SELECT * FROM surv_test_kotz.geo_images_meta") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_test_kotz\\geo_images_meta_k"), data = geo_images_meta, overwrite = TRUE, validate = TRUE)
rm(geo_images_meta)



### telem --------------------
# adfg_locs
adfg_locs <- sf::st_read(con, query = "SELECT * FROM telem.adfg_locs") %>%
  mutate(loc_dt = as.POSIXct(loc_dt, format = "%F")) %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "telem\\adfg_locs"), data = adfg_locs, overwrite = TRUE, validate = TRUE)
rm(adfg_locs)

# geo_wc_locs
geo_wc_locs <- sf::st_read(con, query = "SELECT * FROM telem.geo_wc_locs") %>%
  mutate(locs_dt = as.POSIXct(locs_dt, format = "%F")) %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "telem\\geo_wc_locs"), data = geo_wc_locs, overwrite = TRUE, validate = TRUE)
rm(geo_wc_locs)

# geo_wc_locs_qa
geo_wc_locs_qa <- sf::st_read(con, query = "SELECT * FROM telem.geo_wc_locs_qa") %>%
  mutate(locs_dt = as.POSIXct(locs_dt, format = "%F")) %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "telem\\geo_wc_locs_qa"), data = geo_wc_locs_qa, overwrite = TRUE, validate = TRUE)
rm(geo_wc_locs_qa)

# hw_locs
hw_locs <- sf::st_read(con, query = "SELECT * FROM telem.hw_locs") %>%
  mutate(loc_dt = as.POSIXct(loc_dt, format = "%F")) %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "telem\\hw_locs"), data = hw_locs, overwrite = TRUE, validate = TRUE)
rm(hw_locs)

# nsb_deploy
nsb_deploy <- sf::st_read(con, query = "SELECT * FROM telem.nsb_deploy") %>%
  mutate(deploy_dt = as.POSIXct(deploy_dt, format = "%F"),
         end_dt = as.POSIXct(end_dt, format = "%F")) %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "telem\\nsb_deploy"), data = nsb_deploy, overwrite = TRUE, validate = TRUE)
rm(nsb_deploy)

# nsb_locs
nsb_locs <- sf::st_read(con, query = "SELECT * FROM telem.nsb_locs") %>%
  mutate(loc_dt = as.POSIXct(loc_dt, format = "%F")) %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "telem\\nsb_locs"), data = nsb_locs, overwrite = TRUE, validate = TRUE)
rm(nsb_locs)

# res_iceseal_haulout
res_iceseal_haulout <- sf::st_read(con, query = "SELECT * FROM telem.res_iceseal_haulout") %>%
  mutate(haulout_dt = as.POSIXct(haulout_dt, format = "%F")) %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "telem\\res_iceseal_haulout"), data = res_iceseal_haulout, overwrite = TRUE, validate = TRUE)
rm(res_iceseal_haulout)

# res_iceseal_haulout_cov
res_iceseal_haulout_cov <- sf::st_read(con, query = "SELECT * FROM telem.res_iceseal_haulout_cov") %>%
  mutate(haulout_dt = as.POSIXct(haulout_dt, format = "%F")) %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "telem\\res_iceseal_haulout_cov"), data = res_iceseal_haulout_cov, overwrite = TRUE, validate = TRUE)
rm(res_iceseal_haulout_cov)




# Disconnect from DB  --------------------------------------
RPostgreSQL::dbDisconnect(con)
rm(con)