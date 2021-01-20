#--------------------
library(request)
library(rjson)
library(httr)

# make a getcoverage request
query = "/rasdaman/ows?&SERVICE=WCS&VERSION=2.0.1&REQUEST=GetCoverage&COVERAGEID=ST_GRIDDED_CLIMATE_SERIES_PRECIPITATION&FORMAT=application/netcdf"

wcps_rasdaman = function(query=NULL, ip="http://saocompute.eurac.edu", only.head=FALSE, todisk=FALSE){

  # you nee to provide a query
  if(is.null(query)){
    stop("Provide a query")
  }

  # build up the url to query the daat
  url = paste0(ip, query)

  if(!todisk){
    # make the GET request
    if(only.head == FALSE){
      res = GET(url)
    }else{
      res = HEAD(url)
    }
  }else{
    out.path = "data"
    if(!file.exists(out.path)){
      dir.create(out.path, recursive = T)
    }
    file_path = paste0( out.path, "/mean_rainfall_southTyrol.nc")
    download.file(url, destfile = file_path)
  }



  # if the statuscode is not 200
  # better use stop_for_status function
  if(!res$status_code == 200){
    stop("Something went wrong in the request")
  }
}


# make the request
res = wcps_rasdaman(query=query, only.head = T, todisk = T)
