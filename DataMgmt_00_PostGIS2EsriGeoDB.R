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
use_python("C:/Python27/ArcGIS10.8/python.exe")
ARCPY <- import("arcpy")
arc.check_product()

# Connect to DB -------------------------------------------------
con <- RPostgreSQL::dbConnect(PostgreSQL(), 
                              dbname = Sys.getenv("pep_db"), 
                              host = Sys.getenv("pep_ip"), 
                              user = Sys.getenv("pep_admin"), 
                              rstudioapi::askForPassword(paste("Enter your DB password for user account: ", Sys.getenv("pep_admin"), sep = "")))


# Get data from DB ---------------------------------------------



### base --------------------
# geo_alaska_dcw
geo_alaska_dcw <- sf::st_read(con, query = "SELECT * FROM base.geo_alaska_dcw") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "base\\geo_alaska_dcw"), data = geo_alaska_dcw, overwrite = TRUE)

# geo_alaska_dnr_adjusted
geo_alaska_dnr_adjusted <- sf::st_read(con, query = "SELECT * FROM base.geo_alaska_dnr_adjusted") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "base\\geo_alaska_dnr_adjusted"), data = geo_alaska_dnr_adjusted, overwrite = TRUE)

# geo_analysis_grid
geo_analysis_grid <- sf::st_read(con, query = "SELECT * FROM base.geo_analysis_grid") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "base\\geo_analysis_grid"), data = geo_analysis_grid, overwrite = TRUE)

# geo_analysis_grid_ak
geo_analysis_grid_ak <- sf::st_read(con, query = "SELECT * FROM base.geo_analysis_grid_ak") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "base\\geo_analysis_grid_ak"), data = geo_analysis_grid_ak, overwrite = TRUE)

# geo_analysis_grid_ak_centroid
geo_analysis_grid_ak_centroid <- sf::st_read(con, query = "SELECT * FROM base.geo_analysis_grid_ak_centroid") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "base\\analysis_grid_ak_centroid"), data = geo_analysis_grid_ak_centroid, overwrite = TRUE)

# geo_analysis_grid_centroid
geo_analysis_grid_centroid <- sf::st_read(con, query = "SELECT * FROM base.geo_analysis_grid_centroid") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "base\\geo_analysis_grid_centroid"), data = geo_analysis_grid_centroid, overwrite = TRUE)

# geo_analysis_grid_no_polarbear
geo_analysis_grid_no_polarbear <- sf::st_read(con, query = "SELECT * FROM base.geo_analysis_grid_no_polarbear") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "base\\geo_analysis_grid_no_polarbear"), data = geo_analysis_grid_no_polarbear, overwrite = TRUE)



### body_condition --------------------
# geo_images
geo_images <- sf::st_read(con, query = "SELECT * FROM body_condition.geo_images") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "body_condition\\geo_images"), data = geo_images, overwrite = TRUE)

# geo_lrf_feed
geo_lrf_feed <- sf::st_read(con, query = "SELECT * FROM body_condition.geo_lrf_feed") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "body_condition\\geo_lrf_feed"), data = geo_lrf_feed, overwrite = TRUE)



### capture --------------------
# geo_captures
geo_captures <- sf::st_read(con, query = "SELECT * FROM capture.geo_captures") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "capture\\geo_captures"), data = geo_captures, overwrite = TRUE)



### stock --------------------
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



### surv_boss --------------------
# geo_detections_by_frame_bb
geo_detections_by_frame_bb <- sf::st_read(con, query = "SELECT * FROM surv_boss.geo_detections_by_frame_bb") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_boss\\geo_detections_by_frame_bb"), data = geo_detections_by_frame_bb, overwrite = TRUE)

# geo_fastice_2012_nic
geo_fastice_2012_nic <- sf::st_read(con, query = "SELECT * FROM surv_boss.geo_fastice_2012_nic") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_boss\\geo_fastice_2012_nic"), data = geo_fastice_2012_nic, overwrite = TRUE)

# geo_fastice_2012_nws
geo_geo_fastice_2012_nws <- sf::st_read(con, query = "SELECT * FROM surv_boss.geo_fastice_2012_nws") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_boss\\geo_fastice_2012_nws"), data = geo_fastice_2012_nws, overwrite = TRUE)

# geo_fastice_2013_nic
geo_fastice_2013_nic <- sf::st_read(con, query = "SELECT * FROM surv_boss.geo_fastice_2013_nic") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_boss\\geo_fastice_2013_nic"), data = geo_fastice_2013_nic, overwrite = TRUE)

# geo_fastice_2013_nws
geo_fastice_2013_nws <- sf::st_read(con, query = "SELECT * FROM surv_boss.geo_fastice_2013_nws") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_boss\\geo_fastice_2013_nws"), data = geo_fastice_2013_nws, overwrite = TRUE)

# geo_fmc_log
geo_fmc_log <- sf::st_read(con, query = "SELECT * FROM surv_boss.geo_fmc_log") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_boss\\geo_fmc_log"), data = geo_fmc_log, overwrite = TRUE)

# geo_hotspots
geo_hotspots <- sf::st_read(con, query = "SELECT * FROM surv_boss.geo_hotspots") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_boss\\geo_hotspots"), data = geo_hotspots, overwrite = TRUE)

# geo_images
geo_images <- sf::st_read(con, query = "SELECT * FROM surv_boss.geo_images") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_boss\\geo_images"), data = geo_images, overwrite = TRUE)

# geo_tracks_by_effort
geo_tracks_by_effort <- sf::st_read(con, query = "SELECT * FROM surv_boss.geo_tracks_by_effort") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_boss\\geo_tracks_by_effort"), data = geo_tracks_by_effort, overwrite = TRUE)

# geo_tracks_on_effort
geo_tracks_on_effort <- sf::st_read(con, query = "SELECT * FROM surv_boss.geo_tracks_on_effort") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_boss\\geo_tracks_on_effort"), data = geo_tracks_on_effort, overwrite = TRUE)

# geo_tracks_on_effort_2012
geo_tracks_on_effort_2012 <- sf::st_read(con, query = "SELECT * FROM surv_boss.geo_tracks_on_effort_2012") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_boss\\geo_tracks_on_effort_2012"), data = geo_tracks_on_effort_2012, overwrite = TRUE)

# geo_tracks_on_effort_2013
geo_tracks_on_effort_2013 <- sf::st_read(con, query = "SELECT * FROM surv_boss.geo_tracks_on_effort_2013") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_boss\\geo_tracks_on_effort_2013"), data = geo_tracks_on_effort_2013, overwrite = TRUE)



### surv_chess --------------------
# geo_fastice
geo_fastice <- sf::st_read(con, query = "SELECT * FROM surv_chess.geo_fastice") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_chess\\geo_fastice"), data = geo_fastice, overwrite = TRUE)

# geo_polarbear
geo_polarbear <- sf::st_read(con, query = "SELECT * FROM surv_chess.geo_polarbear") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_chess\\geo_polarbear"), data = geo_polarbear, overwrite = TRUE)

# geo_process_with_effort
geo_process_with_effort <- sf::st_read(con, query = "SELECT * FROM surv_chess.geo_process_with_effort") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_chess\\geo_process_with_effort"), data = geo_process_with_effort, overwrite = TRUE)

# geo_track_by_effort
geo_track_by_effort <- sf::st_read(con, query = "SELECT * FROM surv_chess.geo_track_by_effort") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_chess\\geo_track_by_effort"), data = geo_track_by_effort, overwrite = TRUE)

# geo_track_by_flight
geo_track_by_flight <- sf::st_read(con, query = "SELECT * FROM surv_chess.geo_track_by_flight") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_chess\\geo_track_by_flight"), data = geo_track_by_flight, overwrite = TRUE)

# tbl_detect
tbl_detect <- sf::st_read(con, query = "SELECT * FROM surv_chess.gtbl_detect") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_chess\\tbl_detect"), data = tbl_detect, overwrite = TRUE)

# tbl_effort_raw
tbl_effort_raw <- sf::st_read(con, query = "SELECT * FROM surv_chess.tbl_effort_raw") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_chess\\tbl_effort_raw"), data = tbl_effort_raw, overwrite = TRUE)

# tbl_process
tbl_process <- sf::st_read(con, query = "SELECT * FROM surv_chess.tbl_process") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_chess\\tbl_process"), data = tbl_process, overwrite = TRUE)

# tbl_unfilt_detect_seal
tbl_unfilt_detect_seal <- sf::st_read(con, query = "SELECT * FROM surv_chess.tbl_unfilt_detect_seal") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_chess\\tbl_unfilt_detect_seal"), data = tbl_unfilt_detect_seal, overwrite = TRUE)

# tbl_valid
tbl_valid <- sf::st_read(con, query = "SELECT * FROM surv_chess.tbl_valid") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_chess\\tbl_valid"), data = tbl_valid, overwrite = TRUE)




### surv_jobss --------------------
# geo_detections_by_frame
geo_detections_by_frame <- sf::st_read(con, query = "SELECT * FROM surv_jobss.geo_detections_by_frame") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_jobss\\geo_detections_by_frame"), data = geo_detections_by_frame, overwrite = TRUE)

# geo_detections_by_seal
geo_detections_by_seal <- sf::st_read(con, query = "SELECT * FROM surv_jobss.geo_detections_by_seal") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_jobss\\geo_detections_by_seal"), data = geo_detections_by_seal, overwrite = TRUE)

# geo_images_meta
geo_images_meta <- sf::st_read(con, query = "SELECT * FROM surv_jobss.geo_images_meta") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_jobss\\geo_images_meta"), data = geo_images_meta, overwrite = TRUE)




### surv_polar_bear --------------------
# geo_detections_by_frame
geo_detections_by_frame <- sf::st_read(con, query = "SELECT * FROM surv_polar_bear.geo_detections_by_frame") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_polar_bear\\geo_detections_by_frame"), data = geo_detections_by_frame, overwrite = TRUE)

# geo_detections_by_seal
geo_detections_by_seal <- sf::st_read(con, query = "SELECT * FROM surv_polar_bear.geo_detections_by_seal") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_polar_bear\\geo_detections_by_seal"), data = geo_detections_by_seal, overwrite = TRUE)

# geo_images_footprint
geo_images_footprint <- sf::st_read(con, query = "SELECT * FROM surv_polar_bear.geo_images_footprint") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_polar_bear\\geo_images_footprint"), data = geo_images_footprint, overwrite = TRUE)

# geo_images_meta
geo_images_meta <- sf::st_read(con, query = "SELECT * FROM surv_polar_bear.geo_images_meta") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_polar_bear\\geo_images_meta"), data = geo_images_meta, overwrite = TRUE)




### surv_pv_cst --------------------
# geo_abundance_4agol
geo_abundance_4agol <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.geo_abundance_4agol") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\geo_abundance_4agol"), data = geo_abundance_4agol, overwrite = TRUE)

# geo_flir_plane2target
geo_flir_plane2target <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.geo_flir_plane2target") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\geo_flir_plane2target"), data = geo_flir_plane2target, overwrite = TRUE)

# geo_haulout
geo_haulout <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.geo_haulout", geometry = "geom") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\geo_haulout"), data = geo_haulout, overwrite = TRUE)

# geo_image_count
geo_image_count <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.geo_image_count") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\geo_image_count"), data = geo_image_count, overwrite = TRUE)

# geo_polys
geo_polys <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.geo_polys") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\geo_polys"), data = geo_polys, overwrite = TRUE)

# geo_priorities_201706
geo_priorities_201706 <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.geo_priorities_201706") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\geo_priorities_201706"), data = geo_priorities_201706, overwrite = TRUE)

# geo_priorities_201708
geo_priorities_201708 <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.geo_priorities_201708") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\geo_priorities_201708"), data = geo_priorities_201708, overwrite = TRUE)

# geo_priorities_201808
geo_priorities_201808 <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.geo_priorities_201808") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\geo_priorities_201808"), data = geo_priorities_201808, overwrite = TRUE)

# geo_priorities_201809
geo_polys <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.geo_priorities_201809") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\geo_priorities_201809"), data = geo_priorities_201809, overwrite = TRUE)

# geo_priorities_201906
geo_priorities_201906 <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.geo_priorities_201906") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\geo_priorities_201906"), data = geo_priorities_201906, overwrite = TRUE)

# geo_priorities_201908
geo_priorities_201908 <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.geo_priorities_201908s") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\geo_priorities_201908"), data = geo_priorities_201908, overwrite = TRUE)

# geo_priorities_202108
geo_priorities_202108 <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.geo_priorities_202108") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\geo_priorities_202108"), data = geo_priorities_202108, overwrite = TRUE)

# geo_track_lines
geo_tracklines <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.geo_track_lines") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\geo_track_lines"), data = geo_track_lines, overwrite = TRUE)

# geo_track_pts
geo_track_pts <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.geo_track_pts") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\geo_track_pts"), data = geo_track_pts, overwrite = TRUE)

# summ_count_by_image
summ_count_by_image <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.summ_count_by_image") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\summ_count_by_image"), data = summ_count_by_image, overwrite = TRUE)

# summ_count_by_image_iliamna
summ_count_by_image_iliamna <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.summ_count_by_image_iliamna") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\summ_count_by_image_iliamna"), data = summ_count_by_image_iliamna, overwrite = TRUE)

# tbl_effort
tbl_effort <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.tbl_effort") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\tbl_effort"), data = tbl_effort, overwrite = TRUE)

# tbl_image_exif
tbl_image_exif <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.tbl_image_exif") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\tbl_image_exif"), data = tbl_image_exif, overwrite = TRUE)

# tbl_image_flir
tbl_image_flir <- sf::st_read(con, query = "SELECT * FROM surv_pv_cst.tbl_image_flir") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_cst\\tbl_image_flir"), data = tbl_image_flir, overwrite = TRUE)



### surv_pv_gla -------------------
# geo_glaciers
geo_glaciers <- sf::st_read(con, query = "SELECT * FROM surv_pv_gla.geo_glaciers") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_gla\\geo_glaciers"), data = geo_glaciers, overwrite = TRUE)

# geo_images_meta
geo_images_meta <- sf::st_read(con, query = "SELECT * FROM surv_pv_gla.geo_images_metas") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_gla\\geo_images_meta"), data = geo_images_meta, overwrite = TRUE)

# geo_routes
geo_routes <- sf::st_read(con, query = "SELECT * FROM surv_pv_gla.geo_routes") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_gla\\geo_routes"), data = geo_routes, overwrite = TRUE)

# geo_survey_count
geo_survey_count <- sf::st_read(con, query = "SELECT * FROM surv_pv_gla.geo_survey_count") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_gla\\geo_survey_count"), data = geo_survey_count, overwrite = TRUE)

# geo_waypoints
geo_waypoints <- sf::st_read(con, query = "SELECT * FROM surv_pv_gla.geo_waypoints") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_pv_gla\\geo_waypoints"), data = geo_waypoints, overwrite = TRUE)



### surv_test_kotz --------------------
# geo_detections_by_frame
geo_detections_by_frame <- sf::st_read(con, query = "SELECT * FROM surv_test_kotz.geo_detections_by_frame") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_test_kotz\\geo_detections_by_frame"), data = geo_detections_by_frame, overwrite = TRUE)

# geo_detections_by_seal
geo_detections_by_seal <- sf::st_read(con, query = "SELECT * FROM surv_test_kotz.geo_detections_by_seal") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_test_kotz\\geo_detections_by_seal"), data = geo_detections_by_seal, overwrite = TRUE)

# geo_images_footprint
geo_images_footprint <- sf::st_read(con, query = "SELECT * FROM surv_test_kotz.geo_images_footprint") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_test_kotz\\geo_images_footprint"), data = geo_images_footprint, overwrite = TRUE)

# geo_images_meta
geo_images_meta <- sf::st_read(con, query = "SELECT * FROM surv_test_kotz.geo_images_meta") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "surv_test_kotz\\geo_images_meta"), data = geo_images_meta, overwrite = TRUE)



### telem --------------------
# adfg_locs
adfg_locs <- sf::st_read(con, query = "SELECT * FROM telem.adfg_locs") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "telem\\adfg_locs"), data = adfg_locs, overwrite = TRUE)

# geo_wc_locs
geo_wc_locs <- sf::st_read(con, query = "SELECT * FROM telem.geo_wc_locs") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "telem\\geo_wc_locs"), data = geo_wc_locs, overwrite = TRUE)

# geo_wc_locs_qa
geo_wc_locs_qa <- sf::st_read(con, query = "SELECT * FROM telem.geo_wc_locs_qa") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "telem\\geo_wc_locs_qa"), data = geo_wc_locs_qa, overwrite = TRUE)

# hw_locs
hw_locs <- sf::st_read(con, query = "SELECT * FROM telem.hw_locs") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "telem\\hw_locs"), data = hw_locs, overwrite = TRUE)

# nsb_deploy
nsb_deploy <- sf::st_read(con, query = "SELECT * FROM telem.nsb_deploy") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "telem\\nsb_deploy"), data = nsb_deploy, overwrite = TRUE)

# nsb_locs
nsb_locs <- sf::st_read(con, query = "SELECT * FROM telem.nsb_locs") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "telem\\nsb_locs"), data = nsb_locs, overwrite = TRUE)

# res_iceseal_haulout
res_iceseal_haulout <- sf::st_read(con, query = "SELECT * FROM telem.res_iceseal_haulout") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "telem\\res_iceseal_haulout"), data = res_iceseal_haulout, overwrite = TRUE)

# res_iceseal_haulout_cov
res_iceseal_haulout_cov <- sf::st_read(con, query = "SELECT * FROM telem.res_iceseal_haulout_cov") %>%
  sf::as_Spatial()
arc.write(file.path(fgdb_path, "telem\\res_iceseal_haulout_cov"), data = res_iceseal_haulout_cov, overwrite = TRUE)




# Disconnect from DB  --------------------------------------
RPostgreSQL::dbDisconnect(con)
rm(con)
