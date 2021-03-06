library(here)
library(lubridate)
Sys.setlocale(category = "LC_ALL", locale = "en_CA.UTF-8")

links <- list(
  local_sit_en = "https://cisss-outaouais.gouv.qc.ca/language/en/covid19-en/",
  local_sit_fr = "https://cisss-outaouais.gouv.qc.ca/covid-19/",
  qc_sit_en = "https://www.quebec.ca/en/health/health-issues/a-z/2019-coronavirus/situation-coronavirus-in-quebec/",
  qc_sit_fr = "https://www.quebec.ca/sante/problemes-de-sante/a-z/coronavirus-2019/situation-coronavirus-quebec/",
  schools_sit_en = "https://www.quebec.ca/en/health/health-issues/a-z/2019-coronavirus/highlights-public-private-school-systems/",
  schools_sit_fr = "https://www.quebec.ca/sante/problemes-de-sante/a-z/coronavirus-2019/faits-saillants-covid-ecoles/",
  timeline = "https://www.inspq.qc.ca/covid-19/donnees/ligne-du-temps"
)
lapply(names(links), function(x) {
  xml2::download_html(links[[x]],
    file = here("_websites", x, paste(format(now(), "%Y%m%d%H%M%S"), ".html", sep = "")))
})
file_connection <- file(here("_websites", "last_download_time.txt"))
writeLines(as.character(now()), file_connection)
close(file_connection)

source("covid_datasets.R")
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

# link <- "https://www.inspq.qc.ca/covid-19/donnees/ligne-du-temps"
# timeline <- xml2::read_html(link)
# timeline <- rvest::html_table(timeline)
# timeline <- do.call(rbind, timeline)
