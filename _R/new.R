# source("_R/covid_datasets.R")
# jsonlite::write_json(datasets, "_data/data.json", auto_unbox = TRUE, pretty = TRUE, force = TRUE)
datasets <- jsonlite::fromJSON("_data/data_sources.json", simplifyVector = FALSE)
opencovid_datasets <- jsonlite::fromJSON("https://raw.githubusercontent.com/ccodwg/Covid19CanadaArchive/master/datasets.json", simplifyVector = FALSE)
opencovid_datasets <- lapply(opencovid_datasets, function(toplevel) {
  toplevel[names(toplevel) %in% c("can", "bc", "on", "qc", "other/can", "other/on", "other/qc")]
})

### to code active/inactive status from opencovid datasets list
# inactive <- unlist(lapply(opencovid_datasets$inactive, function(loc) {
#   unlist(lapply(loc, function(item) { item$uuid }))
# }))
# active <- unlist(lapply(opencovid_datasets$active, function(loc) {
#   unlist(lapply(loc, function(item) { item$uuid }))
# }))
# select <- unlist(lapply(datasets, function(item) "opencovid_uuid" %in% names(item)))
# select_active <- unlist(lapply(datasets[select], function(item) item$opencovid_uuid %in% active))
# select_inactive <- unlist(lapply(datasets[select], function(item) item$opencovid_uuid %in% inactive))
# datasets[select][select_active] <- lapply(datasets[select][select_active], function(item) {
#   item$active <- TRUE
#   item[sort(names(item))]
# })
# datasets[select][select_inactive] <- lapply(datasets[select][select_inactive], function(item) {
#   item$active <- FALSE
#   item[sort(names(item))]
# })
# jsonlite::write_json(datasets, "_data/data_sources.json", auto_unbox = TRUE, pretty = TRUE, force = TRUE)

### to check what's new in the opencovid datasets list
# included <- unlist(lapply(datasets[select], function(item) {item$opencovid_uuid}))
# to_check <- lapply(opencovid_datasets$active, function(loc) {
#   loc[unlist(lapply(loc, function(item) {
#     !item$uuid %in% included & !item$file_ext %in% c("html", "pdf", "png")
#   }))]
# })
# jsonlite::write_json(to_check, "_data/new_opencovid.json", auto_unbox = TRUE, pretty = TRUE, force = TRUE)









### Oxford covid policy response tracker
# policy_responses <- readr::read_csv("https://github.com/OxCGRT/covid-policy-tracker/raw/master/data/OxCGRT_latest.csv")
