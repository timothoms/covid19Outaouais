library("aws.s3")
source("_R/covid_datasets.R")
# csvs <- datasets[unlist(lapply(datasets, function(item) item$file_ext == "csv"))]
datasets <- datasets[unlist(lapply(datasets, function(item) "opencovid_dir" %in% names(item)))]
datasets <- datasets[!unlist(lapply(datasets, function(item) item$overwrite))]

download <- lapply(datasets, function(item) {
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
                  destfile = paste("_", item$file_ext, "/", stringr::str_replace(file, paste("archive/", item$opencovid_dir, sep = ""), item$path), sep = ""))
  })
  return(files)
})
### base URLs
# HTTP: http://data.opencovid.ca/archive/.
# HTTPS: https://data.opencovid.ca.s3.amazonaws.com/archive/
### example URLS
# HTTP: http://data.opencovid.ca/archive/can/epidemiology-update-2/covid19-download_2020-11-04_23-38.csv
# HTTPS: https://data.opencovid.ca.s3.amazonaws.com/archive/can/epidemiology-update-2/covid19-download_2020-11-04_23-38.csv
