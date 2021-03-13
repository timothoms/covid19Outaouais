library("rvest")
library("lubridate")
links <- list(
    local_sit_en = "https://cisss-outaouais.gouv.qc.ca/language/en/covid19-en/",
    local_sit_fr = "https://cisss-outaouais.gouv.qc.ca/covid-19/",
    qc_sit_en = "https://www.quebec.ca/en/health/health-issues/a-z/2019-coronavirus/situation-coronavirus-in-quebec/",
    qc_sit_fr = "https://www.quebec.ca/sante/problemes-de-sante/a-z/coronavirus-2019/situation-coronavirus-quebec/",
    schools_sit_en = "https://www.quebec.ca/en/health/health-issues/a-z/2019-coronavirus/highlights-public-private-school-systems/",
    schools_sit_fr = "https://www.quebec.ca/sante/problemes-de-sante/a-z/coronavirus-2019/faits-saillants-covid-ecoles/",
    schools_list_en = "https://www.quebec.ca/en/health/health-issues/a-z/2019-coronavirus/list-schools-reporting-covid-19-cases/",
    schools_list_fr = "https://www.quebec.ca/sante/problemes-de-sante/a-z/coronavirus-2019/liste-des-cas-de-covid-19-dans-les-ecoles/",
    qc_variants_fr = "https://www.inspq.qc.ca/covid-19/donnees/variants",
    qc_vaccination_en = "https://www.quebec.ca/en/health/health-issues/a-z/2019-coronavirus/situation-coronavirus-in-quebec/covid-19-vaccination-data/",
    qc_vaccination_en = "https://www.quebec.ca/sante/problemes-de-sante/a-z/coronavirus-2019/situation-coronavirus-quebec/donnees-sur-la-vaccination-covid-19/"
)
path <- "~/Documents/GitHub/covid19Outaouais/websites/"
lapply(names(links), function(x) {
    download_html(links[x], file = paste(path, x, "/", format(now(), "%Y%m%d%H%M%S"), ".html", sep = ""))
})
file_connection <-file(paste(path, "last_download_time.txt", sep = ""))
writeLines(as.character(now()), file_connection)
close(file_connection)
