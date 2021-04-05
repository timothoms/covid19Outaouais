library("tidyverse")
Sys.setlocale(category = "LC_ALL", locale = "en_CA.UTF-8")

### school listings
link <- "https://cdn-contenu.quebec.ca/cdn-contenu/education/coronavirus/Liste_ecole_DCOM.csv"
new <- readr::read_delim(link, delim = ";")
new$time <- lubridate::now()
names(new)[1:4] <- c("region", "admin", "school", "code")
new$region_code <- stringr::str_sub(new$region, 2, 3)
new$region <- stringr::str_trim(new$region)
new$admin <- stringr::str_trim(new$admin)
stringr::str_sub(new$region, 1, 5) <- ""
new$relisted <- stringr::str_detect(new$school, stringr::fixed("*"))
new$school <- stringr::str_replace(new$school, stringr::fixed("*"), "")
new$note[new$code == 1] <- "reaffected listed school (pink)" # "already on list, with new confirmed case(s) [pink]"
new$note[new$code == 2] <- "relisted newly affected school (green*)" # "relisted due to new confirmed case(s) [green*]"
new$note[new$code == 3] <- "newly listed school (green)" # "new listing due to new confirmed case(s) [green]"
# table(new$note, new$relisted)
new <- new[c("time", "region", "region_code", "admin", "school", "code", "note")]
load("data/schools.RData", verbose = TRUE)
schools <- rbind(schools, new)
schools <- schools %>% arrange(region, admin, school, time)
save(schools, file = "data/schools.RData")

# mobility snapshots: https://health-infobase.canada.ca/covid-19/covidtrends/?HR=1,2407&mapOpen=false
link <- "https://health-infobase.canada.ca/src/data/covidLive/covidTrends/mobility.csv"
mobility_new <- readr::read_csv(link)
load("data/mobility.RData")
mobility <- c(mobility, list(mobility_new))
save(mobility, file = "data/mobility.RData")

# complete historical: https://www.inspq.qc.ca/covid-19/donnees
# link <- "https://www.inspq.qc.ca/sites/default/files/covid/donnees/covid19-hist.csv"
# hist <- readr::read_csv(link)
