#------------------------------------------
# Extract the rainfall at a point location
# for different times prior to the selcted date
#------------------------------------------


# load the libs -----------------------------------------------------------

library(dplyr)
library(sf)
library(raster)
library(ncdf4)
library(ncmeta)
library(assertthat)
library(tidyverse)


# define some paths -------------------------------------------------------

data_path = "\\\\projectdata.eurac.edu/projects/Proslide/PREC_GRIDS/"
shape_points_path = "\\\\projectdata.eurac.edu/projects/Proslide/Landslides/Iffi_db_xxxx_to_2018/exportperEurac2020/Shapefiles/IFFI10_1.shp"
shape_poly_path = "\\\\projectdata.eurac.edu/projects/Proslide/Landslides/Iffi_db_xxxx_to_2018/exportperEurac2020/Shapefiles/IFFI10_5.shp"


# -------------------------------------------------------------------------



get_rainfall = function(spatial.obj = NULL,
                        ncdf_path = NULL,
                        dts = NULL,
                        seqq = TRUE, # do you want all dates in this sequence or only specific dates?
                        days_back = 1:2){

  # verify its an object of type sf
  assert_that(class(spatial.obj)[[1]] == "sf", msg="The spatial data is not of class sf")
  # assert that dates are actually dates
  assert_that(is.date(dts), msg = "dts must be an object of type date")
  # integer range of dates
  assert_that(is.integer(days_back), msg = "The date range must be of type integer")


  # get the geometry type of the sf object
  gtype = st_geometry_type(spatial.obj, by_geometry = FALSE) %>% as.character()
  if(!gtype=="POINT"){
    gtype="poly"
  }  else{
    gtype="point"
  }

  # get the dates
  if(length(dts) > 1) {
    if (seqq) {
      dts = seq(dts[[1]], dts[[2]], by = "day")
      n_days = length(dts)
      message(paste("Extracting data for a sequential range of", n_days,  "dates"))
      message(paste("with", max(days_back), "day(s) in antecedence"))

      # output will be a list of datafames
      out = vector("list", length = length(dts))

    } else{
      # only specifc dates
      message(paste("Extracting data for", length(dts), "specific dates"))
      message(paste("with", max(days_back), "day(s) in antecedence"))
      dts = dts

      # output will be a list of datafames
      out = vector("list", length = length(dts))

    }
  } else{
    # only one specific date
    message(paste("Extracting data for one date:", dts, "\n",
                  "with", max(days_back), "day(s) in antecedence" ))
    dts = dts

    # output will be only one dataframe
    out = data.frame()

  }


  #### Exract the data from NETCDF

  # for each day create a dataframe
  for (day in dts) {

  # get the year the month and the day
   y = format(day, "%Y")
   m = format(day, "%m")
   d = format(day, "%d")

   # create the path to the data for one month
   path_year_month = paste0(data_path, y, "/", "DAILYPCP_", y, formatC(m, flag = 0, width = 2), ".nc")

   ncin = ncdf4::nc_open(path_year_month)


  }



}
