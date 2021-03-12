library("rvest")
library("lubridate")
links <- list(
    local_sit_en = "https://cisss-outaouais.gouv.qc.ca/language/en/covid19-en/",
    local_sit_fr = "https://cisss-outaouais.gouv.qc.ca/covid-19/",
    qc_sit_en = "https://www.quebec.ca/en/health/health-issues/a-z/2019-coronavirus/situation-coronavirus-in-quebec/",
    qc_sit_fr = "https://www.quebec.ca/sante/problemes-de-sante/a-z/coronavirus-2019/situation-coronavirus-quebec/"
)
path <- "~/Documents/GitHub/covid19Outaouais/websites/"
download_html(links$local_sit_fr, file = paste(path, "local_sit_fr/", format(now(), "%Y%m%d%H%M%S"), ".html", sep = ""))
download_html(links$local_sit_en, file = paste(path, "local_sit_en/", format(now(), "%Y%m%d%H%M%S"), ".html", sep = ""))
download_html(links$qc_sit_en, file = paste(path, "qc_sit_en/", format(now(), "%Y%m%d%H%M%S"), ".html", sep = ""))
download_html(links$qc_sit_fr, file = paste(path, "qc_sit_fr/", format(now(), "%Y%m%d%H%M%S"), ".html", sep = ""))
file_connection <-file(paste(path, "last_download_time.txt", sep = ""))
writeLines(as.character(now()), file_connection)
close(file_connection)
