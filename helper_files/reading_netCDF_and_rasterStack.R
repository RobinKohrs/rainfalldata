
# load packages
library(raster)
library(RNetCDF)
library(ncdf4)
library(ncdf.tools)
library(ncdf4.helpers)
library(rasterVis)
library(lubridate)
library(scales)
library(ggplot2)
#-----------------------------------------
# set the parth to files and year/month of interest
path.input<-"\\\\projectdata.eurac.edu/projects/Proslide/PREC_GRIDS/"
year<-2017
month<-8

# V.1
# the following code is one example of how reading a .nc file where all data info are stored
# open the connection
prec.grids<-nc_open(paste0(path.input,year,"/DAILYPCP_",year,formatC(month,flag=0,width=2),".nc"))
# before running the following rows print the attributes of the netCDF (just digit the name of the file in the console and click Enter)

# read the dates (in this case the time would be automatically set to the central hour of the day)
dates<-as.Date(convertDateNcdf2R(ncvar_get(prec.grids,"DATE"),units="days",origin=as.POSIXct("1970-01-01")),format="%Y/%m/%d")
# read the variable
values<-ncvar_get(prec.grids,"precipitation");  fillvalue<-ncatt_get(prec.grids,"precipitation","_FillValue")
# extract the projection: transverse mercator
proj<- nc.get.proj4.string(prec.grids, "precipitation")
# close the connection to the netCDF
nc_close(prec.grids)

# create the grid
r.ex<-raster(paste0(path.input,year,"/DAILYPCP_",year,formatC(month,flag=0,width=2),".nc")); r.ex[]<-NA
prec.stack<-list()
# in the loop the values from each daily fields are extracted and loaded in the list of rasters
# need to reverse y order for netcdf
for(i in 1:length(dates)){
  tmp <- values[,,i]; tmp[tmp==fillvalue$value]<-NA
  mat <- matrix(tmp, ncol(r.ex))
  mat <- mat[, ncol(mat) : 1 ]
  r.ex[]<-NA;r.ex[] <- as.vector(mat)
  prec.stack[[i]]<-r.ex
}

# convert the list in a stacked raster and assure that the projection is defined
prec.stack<-stack(prec.stack)
crs(prec.stack)<-proj

#------------------------------------------------------------------------------------------------------------------
# example of how the fields look like
levelplot(prec.stack[[7:10]],col.regions=colorRampPalette((brewer.pal(9,"GnBu"))),margin=F,names.attr=as.character(dates[7:10]),
          colorkey=list(title="mm"),par.settings=list(panel.background = list(col="grey")))
#------------------------------------------------------------------------------------------------------------------
# example of point extraction from raster using lat-long coordinates
# insert the coordinates of Bolzano and convert them in tmerc
xy.latlong<-data.frame(X=11.33982,Y=46.49067)
coordinates(xy.latlong) <- c("X", "Y")
proj4string(xy.latlong)<- CRS("+proj=longlat +datum=WGS84")
xy.conv <- spTransform(xy.latlong, CRS(proj))
# extract the point from the raster stack and plot
ts<-data.frame(date=as.Date(dates),value=extract(prec.stack,xy.conv)[1,])

ggplot(data=ts,aes(x=date,y=value))+geom_bar(stat="identity",fill="darkblue")+ scale_x_date(breaks=date_breaks("5 days"), date_labels = "%Y/%m/%d", expand = c(0,0))+
  theme_bw()+
  theme(panel.grid.minor.y = element_blank())+
  labs(x=NULL,y="mm",title=(paste0("Daily precipitation Bolzano: ",as.character(dates[1],format="%b %Y"))))
#--------------------------------------------------------------------------------------------------------------------
# V.2
# the following code is a (very) quick alternative to import the stacked raster directly from .nc
# it works well if you know in advance the metadat which are lost when they are imported this way
prec.stack<-stack(paste0(path.input,year,"/DAILYPCP_",year,formatC(month,flag=0,width=2),".nc"))
# you have to create the vector of correct dates
dates<-seq(as.Date(paste0(year,"/",formatC(month,flag=0,width=2),"/01",format="%Y/%m/%d")),as.Date(paste0(year,"/",formatC(month,flag=0,width=2),"/",nlayers(prec.stack),format="%Y/%m/%d")),"day")

levelplot(prec.stack[[7:10]],col.regions=colorRampPalette((brewer.pal(9,"GnBu"))),margin=F,names.attr=as.character(dates[7:10]),
          colorkey=list(title="mm"),par.settings=list(panel.background = list(col="grey")))
