library("rvest")
library("lubridate")
link <- "https://www.mamh.gouv.qc.ca/repertoire-des-municipalites/fiche/region/07/"
download_html(link, file = "websites/municipalities.html")
file_connection <-file("websites/municipalities_download_time.txt")
writeLines(as.character(now()), file_connection)
close(file_connection)
webpage <- read_html("municipalities.html")
municipalities <- tryCatch(webpage %>% html_node(css = "table") %>% html_table(fill = TRUE), error = function(x) return(NULL) )
names(municipalities) <- c("code", "designation", "municipality", "mrc")
save(municipalities, file = "../data/municipalities.RData")
write_csv(municipalities, file = "../data/municipalities.csv")

### population size
links_pop <- list(
  report = list(
    file = "https://statistique.quebec.ca/en/fichier/la-population-des-regions-administratives-des-mrc-et-des-municipalites-du-quebec-en-2019.pdf"
  ),
  municipalities = list(
    site = "https://statistique.quebec.ca/en/document/population-and-age-and-sex-structure-municipalities",
    file = "https://statistique.quebec.ca/en/fichier/excel-population-estimates-municipalities-quebec-2001-2020.xlsx",
    file_groups = "https://statistique.quebec.ca/en/fichier/excel-population-estimates-by-age-group-and-sex-municipalities-quebec-2001-to-2020.xlsx"
  ),
  mrc = list(
    site = "https://statistique.quebec.ca/fr/document/population-et-structure-par-age-et-sexe-municipalites-regionales-de-comte-mrc/tableau/estimations-de-la-population-des-mrc",
    file = "https://statistique.quebec.ca/fr/fichier/excel-estimations-de-la-population-des-mrc-quebec-1996-2020.xlsx"
  ),
  regions = list(
    site = "https://statistique.quebec.ca/en/produit/tableau/estimations-population-regions-administratives",
    file = "https://statistique.quebec.ca/docs-ken/multimedia/RA_total.xlsx"
  ),
  regions_age_sex = list(
    site = "https://statistique.quebec.ca/fr/produit/tableau/estimations-population-regions-administratives-selon-age-sexe-age-median-age-moyen#tri_tertr=07&tri_pop=30",
    file = "https://statistique.quebec.ca/docs-ken/multimedia/RA_age_et_gr_age_et_sexe_avec_total_Quebec.xlsx"
  )
)
lapply(links_pop, names)


# file.remove()
# download.file(links_pop$municipalities$file, destfile = "temp.xlsx")
# temp <- readxl::read_excel("temp.xlsx", skip = 2)
# file.remove("temp.xlsx")



