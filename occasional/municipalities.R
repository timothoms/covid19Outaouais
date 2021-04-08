link <- "https://www.mamh.gouv.qc.ca/repertoire-des-municipalites/fiche/region/07/"
xml2::download_html(link, file = "websites/municipalities.html")
file_connection <- file("websites/municipalities_download_time.txt")
writeLines(as.character(lubridate::now()), file_connection)
close(file_connection)
webpage <- read_html("websites/municipalities.html")
municipalities <- tryCatch(webpage %>% html_node(css = "table") %>% html_table(fill = TRUE), error = function(x) return(NULL) )
names(municipalities) <- c("code", "designation", "municipality", "mrc")
save(municipalities, file = "data/municipalities.RData")
