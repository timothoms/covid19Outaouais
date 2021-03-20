links <- list(
  local_sit_en = "https://cisss-outaouais.gouv.qc.ca/language/en/covid19-en/",
  local_sit_fr = "https://cisss-outaouais.gouv.qc.ca/covid-19/",
  qc_sit_en = "https://www.quebec.ca/en/health/health-issues/a-z/2019-coronavirus/situation-coronavirus-in-quebec/",
  qc_sit_fr = "https://www.quebec.ca/sante/problemes-de-sante/a-z/coronavirus-2019/situation-coronavirus-quebec/",
  schools_sit_en = "https://www.quebec.ca/en/health/health-issues/a-z/2019-coronavirus/highlights-public-private-school-systems/",
  schools_sit_fr = "https://www.quebec.ca/sante/problemes-de-sante/a-z/coronavirus-2019/faits-saillants-covid-ecoles/",
  qc_variants_fr = "https://www.inspq.qc.ca/covid-19/donnees/variants"
)
path <- "~/Documents/GitHub/covid19Outaouais/websites/"
lapply(names(links), function(x) {
  xml2::download_html(links[[x]], file = paste(path, x, "/", format(lubridate::now(), "%Y%m%d%H%M%S"), ".html", sep = ""))
})
file_connection <- file(paste(path, "last_download_time.txt", sep = ""))
writeLines(as.character(lubridate::now()), file_connection)
close(file_connection)
