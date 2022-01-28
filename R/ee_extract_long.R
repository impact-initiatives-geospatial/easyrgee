#' wrapper for ee_extract
#' @param ic ImageCollection
#' @param sf sf object for spatial disaggregation
#' @param sf_col sf column to include in output
#' @param scale scale (meters) of imageCollection
#' @param reducer sf_col level reducer
#' @export



ee_extract_long <-  function(ic,
                             sf,
                             sf_col,
                             # parameter_name,
                             scale,
                             reducer
                             # via="rgee_backup"
){

  reducer_fun<- switch(
    reducer,
    "mean" = ee$Reducer$mean(),
    "max" = ee$Reducer$mean(),
    "min" = ee$Reducer$min(),
    "median"= ee$Reducer$median(),
    "sum"= function(x)x$sum(),
    "sd" = x$reduce(ee$Reducer$stdDev()),
    NULL
  )


  cat("renaming bands with dates\n")
  ic_renamed<- ic |>
    map_date_to_bandname_ic()

  cat("starting ee_extract\n")
  ic_extracted_wide_sf <- rgee::ee_extract(x = ic_renamed,
                                           y=sf[sf_col],
                                           scale=scale,
                                           fun= reducer_fun,
                                           via = "drive",
                                           sf=T)


  # client side
  band_names_cli<- ic$first()$bandNames()$getInfo()
  rm_rgx <- paste0(".*",band_names_cli)
  rm_rgx <- glue::glue_collapse(rm_rgx,sep = "|")
  extract_rgx <- glue::glue_collapse(band_names_cli,sep = "|")

  ic_extracted_wide_sf |>
    st_drop_geometry() |>
    pivot_longer(-1) |>
    mutate(
      parameter=str_extract(name, pattern=extract_rgx),
      date= str_remove(string = name, pattern = rm_rgx) |>
        str_replace_all("_","-") |> lubridate::ymd()

    ) |>
    select(-name)


}
