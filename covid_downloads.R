library(here)
library(lubridate)
Sys.setlocale(category = "LC_ALL", locale = "en_CA.UTF-8")

source("_R/covid_datasets.R")
links <- links[c("local_sit_en", "local_sit_fr", "qc_sit_en",  "qc_sit_fr", "schools_sit_en", "schools_sit_fr", "timeline")]
lapply(names(links), function(x) {
  xml2::download_html(links[[x]],
    file = here("_websites", x, paste(format(now(), "%Y%m%d%H%M%S"), ".html", sep = "")))
})
file_connection <- file(here("_websites", "last_download_time.txt"))
writeLines(as.character(now()), file_connection)
close(file_connection)

csvs <- datasets[unlist(lapply(datasets, function(item) item$download_daily ))]
unique_number <- round(as.numeric(as.period(interval(as_datetime("1970-01-02 4:00:00", tz = "EST"), now())), "minutes"))
lapply(csvs, function(item) {
  if(item$overwrite) {
    download.file(paste(item$url, "?randNum=", unique_number, sep = ""),
                  cacheOK = FALSE,
                  destfile = here::here("_csv", item$path,
                                        paste(item$file_name, ".csv", sep = "")))
  } else {
    download.file(paste(item$url, "?randNum=", unique_number, sep = ""),
                  cacheOK = FALSE,
                  destfile = here::here("_csv", item$path,
                                        paste(item$file_name, "_", format(now(), "%Y-%m-%d-%H-%M-%S"), ".csv", sep = "")))
  }
})
