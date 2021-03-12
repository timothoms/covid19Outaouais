library("tidyverse")
library("lubridate")
library("rvest")
library("parallel")
library("runner")

links <- list(
    local_sit_defunct = "https://cisss-outaouais.gouv.qc.ca/language/en/18907-2/",
    local_sit_en = "https://cisss-outaouais.gouv.qc.ca/language/en/covid19-en/",
    local_sit_fr = "https://cisss-outaouais.gouv.qc.ca/covid-19/",
    qc_sit_en = "https://www.quebec.ca/en/health/health-issues/a-z/2019-coronavirus/situation-coronavirus-in-quebec/",
    qc_sit_fr = "https://www.quebec.ca/sante/problemes-de-sante/a-z/coronavirus-2019/situation-coronavirus-quebec/",
    qc_public_health = "https://www.inspq.qc.ca/covid-19/donnees",
    qc_alert = "https://www.quebec.ca/en/health/health-issues/a-z/2019-coronavirus/progressive-regional-alert-and-intervention-system/map-of-covid-19-alert-levels-by-region/",
    qc_schools_pdf = "https://cdn-contenu.quebec.ca/cdn-contenu/adm/min/education/publications-adm/covid-19/reseauScolaire_listeEcoles_ANG.pdf",
    can_visual = "https://health-infobase.canada.ca/covid-19/",
    can_data = "https://www.canada.ca/en/public-health/services/diseases/coronavirus-disease-covid-19/epidemiological-economic-research-data.html"
)

ParseHTMLtables <- function(path) {
    ids <- files <- dir(path)
    ids <- str_replace(ids, ".snapshot", "")
    ids <- str_replace(ids, ".html", "")
    files <- paste(path, files, sep = "")
    names(files) <- ids
    tables <- mclapply(files, function(page) {
        webpage <- read_html(page)
        tab <- tryCatch(webpage %>% html_nodes(css = "table") %>% html_table(fill = TRUE), error = function(x) return(NULL) )
        return(tab)
    })
    return(tables)
}
tables <- ParseHTMLtables(path = "websites/local_sit_en/")
sort(unique(unlist(lapply(tables, length))))
# unique(lapply(tables[unlist(lapply(tables, length)) == 2], function(set) names(set[[1]])))
# lapply(tables[unlist(lapply(tables, length)) == 2], function(set) set[[1]])
cases <- c(
    lapply(tables[unlist(lapply(tables, length)) == 5], function(set) set[[1]]),
    lapply(tables[unlist(lapply(tables, length)) == 6], function(set) set[[1]]),
    lapply(tables[unlist(lapply(tables, length)) == 7], function(set) set[[1]]),
    lapply(tables[unlist(lapply(tables, length)) == 8], function(set) set[[2]])
)
rls <- c(
    lapply(tables[unlist(lapply(tables, length)) == 3], function(set) set[[1]]),
    lapply(tables[unlist(lapply(tables, length)) == 4], function(set) set[[1]]),
    lapply(tables[unlist(lapply(tables, length)) == 5], function(set) set[[2]]),
    lapply(tables[unlist(lapply(tables, length)) == 6], function(set) set[[2]]),
    lapply(tables[unlist(lapply(tables, length)) == 7], function(set) set[[2]]),
    lapply(tables[unlist(lapply(tables, length)) == 8], function(set) set[[3]])
)
### territories, City or Municipality
areas <- c(
    lapply(tables[unlist(lapply(tables, length)) == 2], function(set) set[[1]]),
    lapply(tables[unlist(lapply(tables, length)) == 3], function(set) set[[2]]),
    lapply(tables[unlist(lapply(tables, length)) == 4], function(set) set[[2]]),
    lapply(tables[unlist(lapply(tables, length)) == 5], function(set) set[[3]]),
    lapply(tables[unlist(lapply(tables, length)) == 6], function(set) set[[3]]),
    lapply(tables[unlist(lapply(tables, length)) == 7], function(set) set[[3]]),
    lapply(tables[unlist(lapply(tables, length)) == 8], function(set) set[[4]])
)
unique(lapply(cases, names))
unique(lapply(areas, names))
unique(lapply(rls, names))
covid <- list(cases = cases, rls = rls, areas = areas)

### duplicate tables
# lapply(covid, function(set) {
#     paste(length(unique(set)), "/", length(set))
# })

FormatTable <- function(table_id, tables) {
    tab <- tables[[table_id]]
    names(tab) <- str_to_lower(names(tab))
    names(tab)[1] <- "key"
    names(tab)[names(tab) %in% c("x2", "number", "nombre", "total")] <- "value"
    names(tab)[names(tab) %in% c("actifs", "actives")] <- "active"
    tab$time <- table_id
    if(!"active" %in% names(tab)) tab$active <- NA
    return(tab[, c("time", "key", "value", "active")])
}
covid <- lapply(covid, function(set) lapply(names(set), FormatTable, tables = set))
lapply(covid, function(set) unique(lapply(set, names)))
# covid$areas[unlist(lapply(covid$areas, function(df) sum(df$key == ""))) == 1] # areas[50] ## Thurso
covid <- lapply(covid, function(set) do.call(rbind, set))
covid <- lapply(covid, function(df) df[order(df$time), ])
names(covid_tables) <- covid_tables <- names(covid)
covid <- lapply(covid_tables, function(table_name) {
    df <- covid[[table_name]]
    df$table <- table_name
    return(df)
})
### consistent labels
covid <- lapply(covid, function(df) {
    df$key <- str_replace(df$key, fixed("**"), "")
    df$key <- str_replace(df$key, fixed("*"), "")
    df$key[df$key %in% c("Average screening test per day (last 6 days)", "Average screening test per day (last 7 days)", "Average screening test per day")] <- "Average screening test per day"
    df$key[df$key %in% c("Deaths", "Number of deaths")] <- "Deaths"
    df$key[df$key %in% c("Healed cases", "Total number of healed cases in Outaouais", "Resolved cases")] <- "Healed/resolved cases"
    df$key[df$key %in% c("Active cases", "Total of active cases in Outaouais")] <- "Active cases"
    df$key[df$key %in% c("Cumulative cases", "Total number of cases in Outaouais", "Total") & df$table == "cases"] <- "Cumulative cases"
    df$key[df$key %in% c("Cumulative cases", "Total number of cases in Outaouais", "Total") & df$table != "cases"] <- "Total cases"
    df$key[df$key %in% c("Collines-de-l'Outaouais", "RLS des Collines-de-l'Outaouais") & df$table == "rls"] <- "RLS des Collines-de-l'Outaouais"
    df$key[df$key %in% c("Papineau", "RLS de Papineau") & df$table == "rls"] <- "RLS de Papineau"
    df$key[df$key %in% c("Pontiac", "RLS du Pontiac") & df$table == "rls"] <- "RLS du Pontiac"
    df$key[df$key %in% c("Gatineau", "RLS de Gatineau", "Ville de Gatineau") & df$table == "rls"] <- "RLS de Gatineau"
    df$key[df$key %in% c("Vallée-de-la-Gatineau", "RLS de la Vallée-de-la-Gatineau") & df$table == "rls"] <- "RLS de la Vallée-de-la-Gatineau"
    df$key[df$key %in% c("To be determined", "To be determined0", "À déterminer")] <- "To be determined"
    df$key <- str_replace(df$key, fixed("Municipality of "), "")
    df$key <- str_replace(df$key, fixed("Municipalité de "), "")
    df$key[df$key %in% c("Lac-des-Plages", "Lac-Des-Plages") & df$table == "areas"] <- "Lac-des-Plages"
    df$key[df$key %in% c("Gatineau", "Ville de Gatineau") & df$table == "areas"] <- "Gatineau"
    df$key[df$key %in% c("Pontiac", "MRC du Pontiac") & df$table == "areas"] <- "MRC du Pontiac"
    df$key[df$key %in% c("Val-des-Bois", "Val-des-bois") & df$table == "areas"] <- "Val-des-Bois"
    df$key[df$key %in% c("L'Isle-aux-Allumettes", "L'Îsles-aux-Allumettes") & df$table == "areas"] <- "L'Isle-aux-Allumettes"
    df$key[df$key == ""] <- "Thurso"
    df <- df[df$key != df$value, ]
    return(df)
})
lapply(covid, function(set) unique(set$key))
covid <- unique(do.call(rbind, covid))

### active cases column
table(covid$key[!is.na(covid$active)])
to_add <- covid[!is.na(covid$active), ]
covid$active <- NULL
to_add$value <- to_add$active
to_add$key <- paste(to_add$key, "(active)")
to_add$active <- NULL
covid <- rbind(covid, to_add)

### checks on labels
load("data/municipalities.RData")
unique(municipalities$municipality)[!unique(municipalities$municipality) %in% unique(covid$key)]
unique(covid$key)[!unique(covid$key) %in% unique(municipalities$municipality)]
unique(covid$key)[str_detect(unique(covid$key), "MRC")]
unique(municipalities$mrc)[!unique(municipalities$mrc) %in% unique(covid$key)]

### cleaning
covid$time <- as_datetime(covid$time, tz = "America/Montreal")
covid$value <- str_replace(covid$value, fixed("**"), "")
covid$value <- str_replace(covid$value, fixed("*"), "")
covid <- covid[covid$value != "", ]
covid <- covid[covid$value != "ND", ]
### this is for simplifying the automation but needs to be flagged in the description
# covid[covid$value %in% c("5 et moins", "5 or moins", "5 or less", "5 ou moins"), ]
covid$value[covid$value %in% c("5 et moins", "5 or moins", "5 or less", "5 ou moins")] <- "5"
covid$value <- as.integer(covid$value)
covid <- covid %>% arrange(time, key, table)

### checks & fix extreme values that are likely due to input error
### (still need a simple and consistent approach to error detection, perhaps from the time series methodological literature)
VisualCheck <- function(keys, tab, exclude = NULL) {
    keys <- keys[!keys %in% exclude]
    ggplot(data = covid[covid$key %in% keys & covid$table == tab, ]) +
        geom_line(mapping = aes(x = time, y = value, group = key, color = key)) +
        theme_classic() + labs(x = "", y = "") +
        theme(legend.position = "bottom")
}
# VisualCheck(keys = tapply(covid$key, covid$table, unique)[["cases"]], tab = "cases")
covid <- covid[!(covid$key == "Healed/resolved cases" & covid$time > "2020-10-31" & covid$time < "2020-11-03" & covid$value == 281), ]
VisualCheck(keys = c("Healed/resolved cases", "Cumulative cases"), tab = "cases")
VisualCheck(keys = tapply(covid$key, covid$table, unique)[["cases"]], tab = "cases", exclude = c("Healed/resolved cases", "Cumulative cases"))
# VisualCheck(keys = tapply(covid$key, covid$table, unique)[["rls"]], tab = "rls")
covid$value[covid$time > "2020-05-23" & covid$time < "2020-05-25" & covid$key == "Total cases" & covid$value == 4729] <- 479
covid$value[covid$time > "2020-06-24" & covid$time < "2020-06-25" & covid$key == "RLS de Gatineau" & covid$value == 47] <- 497
covid <- covid[!(covid$time > "2020-12-15" & covid$time < "2020-12-16" & covid$key == "RLS de Gatineau" & covid$value == 32172), ]
VisualCheck(keys = c("Total cases", "RLS de Gatineau"), tab = "rls")
VisualCheck(keys = c("Deaths", "To be determined", "To be determined (active)"), tab = "rls")
VisualCheck(keys = c("Active cases", "Total cases (active)", "Healed/resolved cases"), tab = "rls")
VisualCheck(keys = c("RLS de Gatineau", "RLS de Gatineau (active)"), tab = "rls")
VisualCheck(keys = c("RLS de Papineau", "RLS de Papineau (active)"), tab = "rls")
covid <- covid[!(covid$time > "2021-01-06" & covid$time < "2021-01-07" & covid$key == "RLS du Pontiac" & covid$value == 0), ]
VisualCheck(keys = c("RLS du Pontiac", "RLS du Pontiac (active)"), tab = "rls") ### FIX 1!
VisualCheck(keys = c("RLS des Collines-de-l'Outaouais", "RLS des Collines-de-l'Outaouais (active)"), tab = "rls")
VisualCheck(keys = c("RLS de la Vallée-de-la-Gatineau", "RLS de la Vallée-de-la-Gatineau (active)"), tab = "rls")
# VisualCheck(keys = tapply(covid$key, covid$table, unique)[["areas"]], tab = "areas")
covid$value[covid$time > "2020-05-09" & covid$time < "2020-05-11" & covid$key == "Total cases" & covid$value == 3334] <- 334
VisualCheck(keys = c("Total cases", "Gatineau"), tab = "areas")
VisualCheck(keys = tapply(covid$key, covid$table, unique)[["areas"]], tab = "areas", exclude = c("Total cases", "Gatineau", "To be determined"))

### saving data
save(covid, file = "data/covid_local.RData")
write_csv(covid, file = "data/covid_local.csv")
file_connection <-file("data/data_update_time.txt")
writeLines(as.character(now()), file_connection)
close(file_connection)
