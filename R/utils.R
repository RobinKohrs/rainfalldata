




#' get the dates and set up the output structure
#'
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
