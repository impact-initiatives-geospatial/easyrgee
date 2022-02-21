## code to prepare `DATASET` dataset goes here

# usethis::use_data(DATASET, overwrite = TRUE)




# code to produce internal data for vignette ------------------------------


library(easyrgee)
library(rgee)
ee_Initialize()
dat<- easyrgee::adm1_ne_nga


chirps <-  ee$ImageCollection("UCSB-CHG/CHIRPS/DAILY")$
  filterDate("2016-01-01","2016-12-31")

precip_cumulative<- ee_accumulate_band_ic(ic = chirps, band = "precipitation")
median_cumulative_rainfall<- ee_extract_long(ic = precip_cumulative,sf = dat,sf_col = "ADM1_EN",scale = 5000,reducer = "median")



modis_ndvi <- ee$ImageCollection("MODIS/006/MOD13Q1")$select("NDVI" )$filterDate("2016-01-01","2016-12-31")


median_ndvi<- ee_extract_long(ic = modis_ndvi,
                              sf = dat,
                              sf_col = "ADM1_EN",
                              scale = 250,
                              reducer = "median")
# dat_internal <- list(median_cumulative_rainfall=median_cumulative_rainfall,median_ndvi=median_ndvi)
# dat_internal |> usethis::use_data(internal = T,overwrite = T)
