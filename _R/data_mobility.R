mobility <- lapply(dir("_csv/mobility/"), function(file) {
  readr::read_csv(paste("_csv/mobility/", file, sep = ""))
})
mobility <- do.call(rbind, mobility)
table(mobility$health_care_region)
