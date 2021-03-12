library("rvest")
library("lubridate")
link <- "https://www.mamh.gouv.qc.ca/repertoire-des-municipalites/fiche/region/07/"
download_html(link, file = "websites/municipalities.html")
file_connection <-file("websites/municipalities_download_time.txt")
writeLines(as.character(now()), file_connection)
close(file_connection)
webpage <- read_html("websites/municipalities.html")
tab <- tryCatch(webpage %>% html_nodes(css = "table") %>% html_table(fill = TRUE), error = function(x) return(NULL) )
municipalities <- tab[[1]]
names(municipalities) <- c("code", "designation", "municipality", "mrc")
save(municipalities, file = "data/municipalities.RData")
write_csv(municipalities, file = "data/municipalities.csv")
