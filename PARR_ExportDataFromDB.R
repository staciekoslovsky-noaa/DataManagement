# Export data for PARR requirements
# S. Hardy, 17APR2019

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
install_pkg("lubridate")
install_pkg("sf")

# Run code -------------------------------------------------------
# Connect to PostgreSQL 
con <- RPostgreSQL::dbConnect(PostgreSQL(), 
                              dbname = Sys.getenv("pep_db"), 
                              host = Sys.getenv("pep_ip"), 
                              user = Sys.getenv("pep_user"), 
                              rstudioapi::askForPassword(paste("Enter your DB password for user account: ", Sys.getenv("pep_user"), sep = "")))

# Process data for InPort record 17348 (glacial harbor seal surveys)
## This dataset will be handled through a separate process

# Process data for InPort record 17350 (capture morphometrics)
ip17350 <- RPostgreSQL::dbGetQuery(con, "SELECT speno, std_length_cm as StandardLength_cm, curv_length_cm as CurvilinearLength_cm, std_supine_length_cm as StandardSupineLength_cm,
                                   hip_girth_cm as HipGirth_cm, max_girth_cm as MaxGirth_cm, ax_girth_cm as AxillaryGirth_cm, final_mass_kg AS Mass_kg, blubber_thickness_cm as BlubberThickness_cm,
                                   blubber_depth_r_lat_hip_cm_a as BlubberDepthRightLateralHipA_cm, blubber_depth_r_lat_hip_cm_b as BlubberDepthRightLateralHipB_cm,
                                   blubber_depth_dor_hip_cm_a as BlubberDepthDorsalHipA_cm, blubber_depth_dor_hip_cm_b as BlubberDepthDorsalHipB_cm,
                                   blubber_depth_dor_ax_cm_a as BlubberDepthDorsalAxillaryA_cm, blubber_depth_dor_ax_cm_b as BlubberDepthDorsalAxillaryB_cm,
                                   blubber_depth_r_lat_ax_cm_a as BlubberDepthLateralAxillaryA_cm, blubber_depth_r_lat_ax_cm_b as BlubberDepthLateralAxillaryB_cm,
                                   condition as Condition, morph_comments as Morphometriccomments
                                   FROM capture.tbl_morph m
                                   INNER JOIN capture.tbl_event e
                                   ON e.id = m.event_id")
write.csv(ip17350, "C:/skh/Datasets_ArchiveReady/17350_AlaskaPhocidMorphometrics/capture_morphometrics.csv", row.names = FALSE)
rm(ip17350)

# Process data for InPort record 17353 (capture food habits)
## Handled manually for now while data are in Access DB

# Process data for InPort record 17355 (capture health and disease)
ip17355 <- RPostgreSQL::dbGetQuery(con, "SELECT DISTINCT speno AS SPENO, sample_type 
                                   FROM capture.tbl_event e
                                   INNER JOIN capture.tbl_sample s ON e.id = s.event_id
                                   INNER JOIN capture.lku_sample_type USING (sample_type_lku)
                                   ORDER BY speno")
write.csv(ip17355, "C:/skh/Datasets_ArchiveReady/17355_AlaskaPhocidHealthAndDisease/capture_samples.csv", row.names = FALSE)
rm(ip17355)

# Process data for InPort record 26619 (ADFG harbor seal counts)
ip26619 <- RPostgreSQL::dbGetQuery(con, "SELECT trackid, polyid, survey_dt, non_pup, pup
                                   FROM surv_pv_cst.archive_poly_counts_adfg
                                   WHERE survey_dt >= \'1983-01-01\' AND survey_dt <= \'2006-12-31\'
                                   AND polyid IN (SELECT polyid FROM surv_pv_cst.geo_polys WHERE trendpoly = \'Yes\')")
ip26619$survey_dt <- lubridate::with_tz(ip26619$survey_dt, "UTC")
write.csv(ip26619, "C:/skh/Datasets_ArchiveReady/26619_AerialSurveyTrendCounts_ADFG/harborSealCounts_ADFG_1983-2006.csv", row.names = FALSE)
rm(ip26619)

# Process data for InPort record 26740 (harbor seal counts 1998-2002)
ip26740 <- RPostgreSQL::dbGetQuery(con, "SELECT trackid, polyid, survey_dt, non_pup
                                   FROM surv_pv_cst.archive_poly_counts_9802")
ip26740$survey_dt <- lubridate::with_tz(ip26740$survey_dt, "UTC")
write.csv(ip26740, "C:/skh/Datasets_ArchiveReady/26740_AerialSurveyCountsOfHarborSeals_1998-2002/harborSealCounts_1998-2002.csv", row.names = FALSE)
rm(ip26740)

# Process data for InPort record 26741 (harbor seal counts 2003-present)
ip26741 <- RPostgreSQL::dbGetQuery(con, "SELECT trackid, polyid, survey_dt, non_pup, pup
                                   FROM surv_pv_cst.summ_count_by_polyid")
ip26741$survey_dt <- lubridate::with_tz(ip26741$survey_dt, "UTC")
write.csv(ip26741, "C:/skh/Datasets_ArchiveReady/26741_AerialSurveyCountsOfHarborSeals_2003-Present/harborSealCounts_2003-present.csv", row.names = FALSE)
rm(ip26741)

# Process data for InPort record 28213 (captures)
ip28213 <- RPostgreSQL::dbGetQuery(con, "SELECT speno, capture_type as CaptureType, common_name as Species, location_name as LocationName, 
                                   capture_lat as CaptureLatitude, capture_long AS CaptureLongitude, capture_dt AS CaptureDateTime,
                                   release_dt as ReleaseDateTime, age_class as AgeClass, sex As Sex, molt as Molt, pregnant as Pregnant,
                                   pv_pelage as PvPelageType
                                   FROM capture.tbl_event
                                   LEFT JOIN capture.lku_capture_type USING (capture_type_lku)
                                   LEFT JOIN capture.lku_species USING (species_lku)
                                   LEFT JOIN capture.lku_age_class USING (age_class_lku)
                                   LEFT JOIN capture.lku_sex USING (sex_lku)
                                   LEFT JOIN capture.lku_molt USING (molt_lku)
                                   LEFT JOIN capture.lku_pregnant USING (pregnant_lku)
                                   LEFT JOIN capture.lku_pv_pelage USING (pv_pelage_lku)")
ip28213$capturedatetime <- lubridate::with_tz(ip28213$capturedatetime, "UTC")
ip28213$releasedatetime <- lubridate::with_tz(ip28213$releasedatetime, "UTC")
write.csv(ip28213, "C:/skh/Datasets_ArchiveReady/28213_AlaskaPhocidCapturesAndSamples/captures.csv", row.names = FALSE)
rm(ip28213)

# Process data for InPort record 28315 (BOSS on-effort flight tracks)
ip28315 <- sf::st_read(con, query = "SELECT flightid, geom FROM surv_boss.geo_tracks_on_effort_2012
                          UNION
                          SELECT flightid, geom FROM surv_boss.geo_tracks_on_effort_2013")
st_write(ip28315, "C:/skh/Datasets_ArchiveReady/28315_BOSS_OnEffortFlightTracks/boss_onEffortTracks.shp", delete_layer = TRUE)
rm(ip28315)
