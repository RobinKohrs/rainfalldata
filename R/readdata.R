
##---------------------------------------------------------------
##                 Read the precipitation data                 --
##---------------------------------------------------------------

# libraries
library(raster)
library(ncdf4)
library(ggplot2)
library(tidyverse)
library(scales)
library(stars)
library(tidync)
library(ncmeta)
library(RColorBrewer)
library(here)
library(iffitoR)
library(exactextractr)




##################################################################
##                         Get the data                         ##
##################################################################

# what have we got --------------------------------------------------------


# the path and some attributes
data_path = "\\\\projectdata.eurac.edu/projects/Proslide/PREC_GRIDS/"
year = 2017
month = 8

# the path to the data
path_year_month = paste0(data_path,
                         year,
                         "/",
                         "DAILYPCP_",
                         year,
                         formatC(month, flag = 0, width = 2),
                         ".nc")

# open the connection
ncin = ncdf4::nc_open(path_year_month)

# grids, data and attributes
(grids = ncmeta::nc_grids(path_year_month))
(vars  = ncmeta::nc_vars(path_year_month))
(atts = ncmeta::nc_atts(path_year_month))


# read the dates ----------------------------------------------------------


# get the DATE vars
dates = ncdf4::ncvar_get(ncin, "DATE")
dunits = ncdf4::ncatt_get(ncin, "DATE", "units")
# convert the time variable
tustr = strsplit(dunits$value, " ")
tdstr = strsplit(unlist(tustr)[[3]], "-")
tmonth = as.integer(unlist(tdstr)[[2]])
tday = as.integer(unlist(tdstr)[[3]])
tyear = as.integer(unlist(tdstr)[[1]])
all_dates = chron::chron(dates, origin = c(tmonth, tday, tyear))
# dates as strings
all_dates_chr = all_dates %>% str_replace_all(., "\\(", "") %>% substr(., 1, 8) %>% str_replace_all(., "\\/", ".")
# dates as posix datatype
all_dates_pos = all_dates %>% str_replace_all(., "\\(", "") %>% substr(., 1, 8) %>% as.Date(., "%m/%d/%y")



# read the precip values --------------------------------------------------

# return a 3d array object [rows, cols, days]
vals = ncvar_get(ncin, "precipitation")

# get the fillvalues
fillval = ncatt_get(ncin, "precipitation", "_Fillvalue")


# get the projection ------------------------------------------------------

proj = nc.get.proj4.string(ncin, "precipitation")

# close the connection
nc_close(ncin)



##################################################################
##                      Work with the data                      ##
##################################################################

#### Version 1 of extracting

# create the grid
r_ex = raster(path_year_month)
r_ex[] = NA

# create the raster stack
prec_stack = list()

# extract the values for each date and reverse the order of y for netcdf
for (i in 1:length(dates)){
  tmp = vals[,,i]
  mat = matrix(tmp, ncol(r_ex))
  mat_rev = mat[, ncol(mat) : 1]
  r_ex[] = as.vector(mat_rev)
  prec_stack[[i]] = r_ex
}

# convert the list into a raster stack
prec_stack = stack(prec_stack)
crs(prec_stack) = proj


#### Version 2 of extracting

precip_brick = raster::brick(path_year_month)


#################################################################
##                        Example Plots                        ##
#################################################################

# plot the brick
levelplot(precip_brick[[7:10]], col.regions=colorRampPalette(brewer.pal(9, "GnBu")), margin=F, names.attr=all_dates_chr[7:10],
          colorkey=list(title="mm"), par.settings=list(panel.background = list(col="grey")))

# plot the stack
levelplot(prec_stack[[7:10]],col.regions=colorRampPalette((brewer.pal(9,"GnBu"))),margin=F,names.attr=all_dates_chr[7:10],
          colorkey=list(title="mm"),par.settings=list(panel.background = list(col="grey")))


##################################################################
##                       Point Extraction                       ##
##################################################################

# extract Bolzano and convert them in tmerc
xy_latlong=data.frame(X=11.33982,Y=46.49067)
coordinates(xy_latlong)=c("X", "Y")
proj4string(xy_latlong) = CRS("+proj=longlat +datum=WGS84")
xy_conv = spTransform(xy_latlong, CRS(proj))

# extract the point from the rasterstack and plot it
ts = data.frame(date=all_dates_pos, value=raster::extract(precip_brick, xy_conv)[1,])


ggplot(data = ts, aes(x = date, y = value)) +
  geom_bar(stat = "identity", fill =
             "darkblue") + scale_x_date(
               breaks = date_breaks("5 days"),
               date_labels = "%Y/%m/%d",
               expand = c(0, 0)
             ) +
  theme_bw() +
  theme(panel.grid.minor.y = element_blank()) +
  labs(x = NULL,
       y = "mm",
       title = (paste0(
         "Daily precipitation Bolzano: ",
         as.character(dates[1], format = "%b %Y")
       )))
