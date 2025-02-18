# Data Management

This respository contains code for program data management or code that is applicable to multiple projects.

The data management processing code is as follows:
* **DataMgmt_00_ApplyPermissionsToDB.txt** - code for managing permissions for permission groups within the pep PostgreSQL database; this code is run in PGAdmin
* **DataMgmt_00_PostGIS2EsriGeoDB.R** - code for pulling spatial data from the pep PostgreSQL database and storing it in an Esri file geodatabase; this code is important to keep up to date to ensure consistency of data access across spatial software
* **Generic_ArchiveData.R** - code for archiving data from one location to another
* **Generic_CompareImages.R** - code for comparing two images, useful when we had questions about whether images with the same name were the same image (because of data collection issues)
* **Generic_CopyImagesAndCreateList.R** - code for copying images and creating image lists for use in image processing software; this code is largely outdated based on how image data are stored and accessed now, but could be useful reference information
* **Generic_KAMERA_DroppedFrameRates.R** - code for evaluating dropped frame rates in the KAMERA system; generic in that it points to a particular folder of imagery for processing; might need to be updated periodically as the KAMERA system is updated, but these updates will be done as-needed, rather than each time KAMERA is updated
* **Generic_MoveImageFiles.R** - code for moving images from one location to another; this code is largely outdated based on how image data are stored and accessed now, but could be useful reference information
* **Generic_PullImageExif.R** - code for extracting exif information from a provided image name/path
* **Grid_00_AssignEEZ+Sea.txt** - the "grid" is the base for ice seal survey planning and abundance estimates; this code assigns individual grid cells to either the Bering, Chukchi, or Beaufort Seas and denotes which grid cells fall in the EEZ
* **PARR_ExportDataFromDB.R** - code to extract data across projects to meet PARR requirements; moving forward, this code will be updated to include new datasets and run when datasets made publically available need to be updated
* **PostgreSQL_CreateIndexesH.txt** - generic code for creating spatial indexes and needs to be run every month and kept up to date with new spatial datasets; this code is run in PGAdmin
* **PostgreSQL_MedianFunction.txt** - code for creating a median function in PostgreSQL; this code is run in PGAdmin
* **PostgreSQL_ProcessDependenciesFunction.txt** - code for creating a function that allows for dependencies to be handled when tables or queries require dependencies to be removed before updates can be made

This repository is a scientific product and is not official communication of the National Oceanic and Atmospheric Administration, or the United States Department of Commerce. All NOAA GitHub project code is provided on an ‘as is’ basis and the user assumes responsibility for its use. Any claims against the Department of Commerce or Department of Commerce bureaus stemming from the use of this GitHub project will be governed by all applicable Federal law. Any reference to specific commercial products, processes, or services by service mark, trademark, manufacturer, or otherwise, does not constitute or imply their endorsement, recommendation or favoring by the Department of Commerce. The Department of Commerce seal and logo, or the seal and logo of a DOC bureau, shall not be used in any manner to imply endorsement of any commercial product or activity by DOC or the United States Government.