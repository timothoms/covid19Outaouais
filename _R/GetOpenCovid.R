# opencovid_update <- jsonlite::fromJSON("https://api.opencovid.ca/version")[[1]]
GetOpenCovid <- function(stat, loc) {
  names(stat) <- stat
  df <- lapply(stat, function (stat_code) {
    tab <- lapply(loc, function(location_code) {
      link <- paste("https://api.opencovid.ca/timeseries?stat=", stat_code, "&loc=", location_code, sep = "")
      jsonlite::fromJSON(link)[[stat_code]]
    })
    tab <- do.call(rbind, tab)
    names(tab)[stringr::str_detect(names(tab), "date")] <- "time"
    key <- names(tab)[stringr::str_detect(names(tab), "cumulative_")]
    key <- stringr::str_replace(key, "cumulative_", "")
    names(tab)[stringr::str_detect(names(tab), "cumulative_")] <- "cumulative"
    tab$key <- key
    names(tab)[!names(tab) %in% c("province", "health_region", "key", "time", "cumulative")] <- "value"
    return(tab[, c("province", "health_region", "key", "time", "value", "cumulative")])
  })
  do.call(rbind, df)
}
