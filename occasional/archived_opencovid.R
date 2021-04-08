### base URLs
# HTTP: http://data.opencovid.ca/archive/.
# HTTPS: https://data.opencovid.ca.s3.amazonaws.com/archive/
### example URLS
# HTTP: http://data.opencovid.ca/archive/can/epidemiology-update-2/covid19-download_2020-11-04_23-38.csv
# HTTPS: https://data.opencovid.ca.s3.amazonaws.com/archive/can/epidemiology-update-2/covid19-download_2020-11-04_23-38.csv

library("aws.s3")

source("covid_datasets.R")
csvs <- csvs[unlist(lapply(csvs, function(item) "opencovid_dir" %in% names(item)))]
csvs <- csvs[!unlist(lapply(csvs, function(item) item$overwrite))]

download <- lapply(csvs, function(item) {
  cat("\n", item$opencovid_dir)
  files <- aws.s3::get_bucket(bucket = "data.opencovid.ca",
                              prefix = paste("archive/", item$opencovid_dir, sep = ""),
                              region = "us-east-2")
  files <- unlist(lapply(files, function(x) x[["Key"]]), use.names = FALSE)
  ### (optional) filter out supplementary material from list of files in the directory
  # files <- files[!grepl("^.*/supplementary/", files)]
  lapply(files, function(file) {
    cat(".")
    download.file(paste("http://data.opencovid.ca/", file, sep = ""),
                  destfile = paste("csv/", stringr::str_replace(file, paste("archive/", item$opencovid_dir, sep = ""), item$path), sep = ""))
  })
  return(files)
})
