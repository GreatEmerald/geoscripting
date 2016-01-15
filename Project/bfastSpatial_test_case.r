library(devtools)
install_git("https://github.com/dutri001/bfastSpatial.git", branch = "master") # GitHub one doesn't work on openSUSE

library(bfastSpatial)
download.file("http://e4ftl01.cr.usgs.gov//MODV6_Cmp_A/MOTA/MCD15A2H.006/2002.07.04/MCD15A2H.A2002185.h19v03.006.2015149105834.hdf", method = "wget", )

# All three work for me...
QCB <- raster(get_subdatasets("data/MCD15A2H.A2002193.h19v03.006.2015149105839.hdf")[3])
QCG <- raster(get_subdatasets(normalizePath("data/MCD15A2H.A2002193.h19v03.006.2015149105839.hdf"))[3])
QC1 <- raster(readGDAL(get_subdatasets("data/MCD15A2H.A2002193.h19v03.006.2015149105839.hdf")[3]))
