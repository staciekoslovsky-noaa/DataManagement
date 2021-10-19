library(raster)

x <- raster::raster("D://frame1-CHESS_FL12_C_160421_214630.573_THERM-16BIT.PNG")
y <- raster::raster("D://CHESS2016_N94S_FL12_C__20160421214630.573GMT_THERM-16BIT.PNG")
z <- x-y
raster::plot(z$layer)

x <- raster::raster("//nmfs/akc-nmml/NMML_CHESS_Imagery/FL12/left/CHESS2016_N94S_FL12_S_20160421_205214/UNFILTERED/detections_CHESS_FL12_S_6-300_200_110_70_R73/FILTERED/CHESS_FL12_S_160421_205943.650_THERM-16BIT.PNG")
y <- raster::raster("//nmfs/akc-nmml/NMML_CHESS_Imagery/FL12/left/CHESS2016_N94S_FL12_S_20160421_205214/UNFILTERED/CHESS2016_N94S_FL12_S__20160421205943.650GMT_THERM-16BIT.PNG")
z <- x-y
raster::plot(z$layer)
raster::plot(y)
