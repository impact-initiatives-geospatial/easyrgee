#' make monthly composites from image collection
#' @param ic ImageCollection
#' @param month_range months to create composites for
#' @param year_range years to consider
#' @param stat statistic/reducer to reduce ImageCollection by
#' @param monthly_stat_per time period to calculate monthly stat over. There are two options: `year` (default), or `range`.
#' if year is selected it will calculate each monthly statistic for every year set in `year_range`. If `range` is selected it will calculate 1 monthly statistic
#' across all years provided in `year_range`
#' @export



ic_yr_mo_composite_stat <- function(ic,
                                     month_range=c(1,12),
                                     year_range=c(2004,2005),
                                     stat="mean",
                                     monthly_stat_per = "year"
){
  #v2

  month_list <- ee$List$sequence(month_range[1], month_range[2])
  year_list <- ee$List$sequence(year_range[1],year_range[2])
  num_years<- year_range[2]-year_range[1]



  collapse_ic_fun <- fun_sel(stat)



  if(monthly_stat_per=="year"){

    cat(crayon::green(glue::glue("calculating 1-year monthly {stat}s from {year_range[1]} to {year_range[2]}")),"\n")
    composites_list <-
      year_list$map(
        ee_utils_pyfunc(function (y) {
          month_list$map(
            ee_utils_pyfunc(function (m) {
              # ic_pre_filt <-
              ic_filtered_yr_mo<- ic$
                filter(ee$Filter$calendarRange(y, y, 'year'))$
                filter(ee$Filter$calendarRange(m, m, 'month'))


              collapse_ic_fun(ic_filtered_yr_mo)$
                set('year',y)$
                set('month',m)$
                set('date',ee$Date$fromYMD(y,m,1))$
                # set('system:time_start',ee$Date$fromYMD(y,m,1))$
                set('system:time_start',ee$Date$millis(ee$Date$fromYMD(y,m,1)))


            })
          )
        })
      )
  }
  if(monthly_stat_per=="range"){
    cat(crayon::green(glue::glue("calculating {num_years}-year monthly {stat}s from {year_range[1]} to {year_range[2]}")),"\n")
    composites_list <-
      month_list$map(
        ee_utils_pyfunc(
          function(m) {
            ic_filtered_yr_mo <- ic$
              filter(ee$Filter$calendarRange(year_range[1], year_range[2], 'year'))$
              filter(ee$Filter$calendarRange(m, m, 'month'))

            bnames<- ic_filtered_yr_mo$first()$bandNames()
            bnames_new <- bnames$map(
              ee_utils_pyfunc(function(x){
                ee$String(x)$cat(ee$String("_"))$cat(ee$String(stat))

              })
            )$flatten()


            collapse_ic_fun(ic_filtered_yr_mo)$
              #   # select(bnames)$
              #   # rename(bnames_new)$
              set("system:time_start",
                  ee$Date$millis(ee$Date$fromYMD(year_range[1],m,1)))


          }
        )
      )
  }




  cat("returning  ImageCollection of x\n")
  return(ee$ImageCollection$fromImages(composites_list$flatten()))
}

#' function/reducer selecter - helper function
#' @param x reducer/statistic using typical r-syntax (character)

fun_sel <-  function(x){switch(x,

                               "mean" = function(x)x$reduce(ee$Reducer$mean()),
                               "max" = function(x)x$reduce(ee$Reducer$max()),
                               "min" = function(x)x$reduce(ee$Reducer$min()),
                               "median"= function(x)x$reduce(ee$Reducer$median()),
                               "sum"= function(x)x$reduce(ee$Reducer$stdDev()),
                               "sd" =  function(x)x$reduce(ee$Reducer$stdDev()),
                               NULL

)
}




