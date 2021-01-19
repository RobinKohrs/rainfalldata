#########################
# explanatory data analysis of the gridded daily rainfall data
# Jan. 21
#########################


# load libs ---------------------------------------------------------------

library(raster)
library(ncdf4)
library(ggplot2)
library(tidyverse)
library(stars)
library(tidync)

# paths to the data
data_path = "data/DailySeries_1980_2018_Prec.nc"

# load the data with ncdf4
nc_data = nc_open(data_path)
# what have we got?
print(nc_data)

# try stars...
nc_data = stars::read_ncdf(data_path) # will trow an error

# what does tidnc do?
data_tidy_nc = tidync(data_path)
print(data_tidy_nc)

#





