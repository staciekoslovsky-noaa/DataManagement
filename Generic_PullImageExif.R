library(exifr)
tags <- c("SourceFile", "FileName", "FileAccessDate", "AuxCount", "NonPupCount", "PupCount", "GPSLatitude", "GPSLongitude", "GPSAltitude",
          "Agency", "AirPhotog", "AircraftType", "CountCompromised", "CountConf", "CountType", "NumDist", "PlaneDist", "SealsInWater", 
          "TrackID", "AircraftSide", "DateTimeOriginal", "GPSDateTime", "SourceFile", "CountDate", "CounterName", "PhotoComments",
          "CountFinal", "Disturbed", "SiteDisturbance", "SurveyRegion", "TrackRep")
counted_exif <- read_exif("//nmfs/akc-nmml/Polar_Imagery/Surveys_HS/Coastal/Counted/2014/2014-09-15/SPD/SPD_20140915_0077_count.jpg")
, tags = tags)
