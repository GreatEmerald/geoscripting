library(devtools)
install_github("dutri001/bfastSpatial")

library(bfastSpatial)
download.file("http://e4ftl01.cr.usgs.gov//MODV6_Cmp_A/MOTA/MCD15A2H.006/2002.07.04/MCD15A2H.A2002185.h19v03.006.2015149105834.hdf", method = "wget", )

QC <- raster(get_subdatasets("MCD15A2H.A2002193.h19v03.006.2015149105839.hdf")[3])
QC <- raster(readGDAL(get_subdatasets("MCD15A2H.A2002193.h19v03.006.2015149105839.hdf")[3]))

