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
### duplicates
# lapply(covid, function(set) {
#     paste(length(unique(set)), "/", length(set))
# })
# unique(lapply(rls[lapply(rls, ncol) == 3], names))
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
# mrcs <- list(
#     "MRC de Papineau" = c("Chénéville", "Fassett", "Lac-Des-Plages", "Lac-Simon", "Montebello", "Montpellier", "Papineauville", "Ripon", "Saint-André-Avellin", "Saint-Émile-de-Suffolk", "Thurso"),
#     "MRC des Collines-de-l'Outaouais" = c("Cantley", "Chelsea", "L'Ange-Gardien", "La Pêche", "Lochaber-Partie-Ouest", "Val-des-Monts"),
#     "MRC du Pontiac" = c("Fort-Coulonge", "L'Île-du-Grand-Calumet", "Mansfield-et-Pontefract", "Pontiac", "Shawville"),
#     "MRC de la Vallée-de-la-Gatineau" = c("Blue Sea", "Bouchette", "Déléage", "Maniwaki", "Sainte-Thérèse-de-la-Gatineau")
# )
covid <- lapply(covid, function(df) {
    df$key <- str_replace(df$key, fixed("**"), "")
    df$key <- str_replace(df$key, fixed("*"), "")
    df$key[df$key %in% c("Average screening test per day (last 6 days)", "Average screening test per day (last 7 days)", "Average screening test per day")] <- "Average screening test per day"
    df$key[df$key %in% c("Deaths", "Number of deaths")] <- "Deaths"
    df$key[df$key %in% c("Healed cases", "Total number of healed cases in Outaouais", "Resolved cases")] <- "Healed/resolved cases"
    df$key[df$key %in% c("Active cases", "Total of active cases in Outaouais")] <- "Active cases"
    df$key[df$key %in% c("Cumulative cases", "Total number of cases in Outaouais", "Total") & df$table == "cases"] <- "Cumulative cases"
    df$key[df$key %in% c("Cumulative cases", "Total number of cases in Outaouais", "Total") & df$table != "cases"] <- "Total cases"
    ### rls
    df$key[df$key %in% c("Collines-de-l'Outaouais", "RLS des Collines-de-l'Outaouais") & df$table == "rls"] <- "RLS des Collines-de-l'Outaouais"
    df$key[df$key %in% c("Papineau", "RLS de Papineau") & df$table == "rls"] <- "RLS de Papineau"
    df$key[df$key %in% c("Pontiac", "RLS du Pontiac") & df$table == "rls"] <- "RLS du Pontiac"
    df$key[df$key %in% c("Gatineau", "RLS de Gatineau", "Ville de Gatineau") & df$table == "rls"] <- "RLS de Gatineau"
    df$key[df$key %in% c("Vallée-de-la-Gatineau", "RLS de la Vallée-de-la-Gatineau") & df$table == "rls"] <- "RLS de la Vallée-de-la-Gatineau"
    ### areas
    df$key[df$key %in% c("To be determined", "To be determined0", "À déterminer")] <- "To be determined"
    df$key <- str_replace(df$key, fixed("Municipality of "), "")
    df$key <- str_replace(df$key, fixed("Municipalité de "), "")
    df$key[df$key %in% c("Lac-des-Plages", "Lac-Des-Plages") & df$table == "areas"] <- "Lac-des-Plages"
    df$key[df$key %in% c("Gatineau", "Ville de Gatineau") & df$table == "areas"] <- "Ville de Gatineau"
    df$key[df$key %in% c("Pontiac", "MRC du Pontiac") & df$table == "areas"] <- "MRC du Pontiac"
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

### fix extreme values that are likely due to input error
ggplot(data = covid[covid$key %in% c("Deaths", "Active cases", "Total cases (active)"), ]) +
    geom_line(aes(x = time, y = value, color = key)) + theme_classic()
covid <- covid[!(covid$key == "Healed/resolved cases" & covid$time > "2020-10-31" & covid$time < "2020-11-03" & covid$value == 281), ]
covid$value[covid$time > "2020-05-09" & covid$time < "2020-05-11" & covid$key == "Total cases" & covid$value == 3334] <- 334
covid$value[covid$time > "2020-05-23" & covid$time < "2020-05-25" & covid$key == "Total cases" & covid$value == 4729] <- 479
ggplot(data = covid[covid$key %in% c("Healed/resolved cases", "Cumulative cases", "Total cases", "Average screening test per day"), ]) +
    geom_line(aes(x = time, y = value, colour = key)) + theme_classic() + theme(legend.position="bottom")
### need a simple and consistent approach to error detection, from the time series methodological literature

### saving data
save(covid, file = "data/covid_local.RData")
write_csv(covid, file = "data/covid_local.csv")
file_connection <-file("data/data_update_time.txt")
writeLines(as.character(now()), file_connection)
close(file_connection)

### deduplication by date

## FROM HERE >>>

# data <- data %>% dplyr::arrange(key, time)
# ## based on afternoon download
# data$flag <- ifelse(duplicated(data[, c("key", "value", "table", "date")]) | duplicated(data[, c("key", "value", "table", "date")], fromLast = TRUE), 1, 0)
# data$morning <- hour(data$time) < 12
# data <- data[!(data$flag == 1 & data$morning), ]
# data$morning <- NULL
# ## based on last download of the day
# data$flag <- ifelse(duplicated(data[, c("key", "value", "table", "date")]) | duplicated(data[, c("key", "value", "table", "date")], fromLast = TRUE), 1, 0)
# data <- data %>% dplyr::arrange(key, time) %>% group_by(key, date) %>% mutate(latest = max(time) == time)
# data <- data[!(data$flag == 1 & !data$latest), ]
# data$latest <- NULL
# ## based on which table the key-value came from
# data$flag <- ifelse(duplicated(data[, c("key", "value", "date")]) | duplicated(data[, c("key", "value", "date")], fromLast = TRUE), 1, 0)
# data <- data[!(data$flag == 1 & data$table == "areas"), ]
# data$table[data$flag == 1] <- paste(data$table[data$flag == 1], "; areas", sep = "")
# ## final check on duplicate values
# data$flag <- ifelse(duplicated(data[, c("key", "value", "date")]) | duplicated(data[, c("key", "value", "date")], fromLast = TRUE), 1, 0)
# sum(data$flag)
# ## now check on duplicate key-time-table obs
# data$flag <- ifelse(duplicated(data[, c("key", "table", "date")]) | duplicated(data[, c("key", "table", "date")], fromLast = TRUE), 1, 0)
# data$morning <- hour(data$time) < 12
# data <- data[!(data$flag == 1 & data$morning), ]
# data$morning <- NULL
# data$flag <- ifelse(duplicated(data[, c("key", "table", "date")]) | duplicated(data[, c("key", "table", "date")], fromLast = TRUE), 1, 0)
# data <- data %>% dplyr::arrange(key, time) %>% group_by(key, date) %>% mutate(latest = max(time) == time)
# data <- data[!(data$flag == 1 & !data$latest), ]
# data$latest <- NULL
# ## now check on duplicate key-time obs
# data$flag <- ifelse(duplicated(data[, c("key", "date")]) | duplicated(data[, c("key", "date")], fromLast = TRUE), 1, 0)
# sum(data$flag)
#
# ### still need to take care of duplicate key-dates for cumulative cases
#
# # check <- data[data$flag == 1, ]
# # print(check[order(check$key, check$time), ], n = Inf)
# data$flag <- NULL
#
# ### calculate daily increases
# table(data$key)
# keys_to_calc_avg <- c("Active cases", "Cumulative cases", "Healed/resolved cases", "Deaths", "Chelsea", "La Pêche", "MRC de la Vallée-de-la-Gatineau", "MRC de Papineau", "MRC des Collines-de-l'Outaouais", "MRC du Pontiac", "RLS de Gatineau", "RLS de la Vallée-de-la-Gatineau", "RLS de Papineau", "RLS des Collines-de-l'Outaouais", "RLS du Pontiac")
# # data <- data %>% dplyr::arrange(key, date) %>% dplyr::group_by(key) %>% dplyr::mutate(moving3 = zoo::rollmean(value, k = 3, fill = NA, align = "right"), moving7 = zoo::rollmean(value, k = 7, fill = NA, align = "right")) %>% dplyr::ungroup()
# data <- data %>% dplyr::arrange(key, date) %>% dplyr::group_by(key) %>% dplyr::mutate(moving3 = zoo::rollmean(value, k = 3, fill = NA, align = "right"), moving7 = zoo::rollmean(value, k = 7, fill = NA, align = "right")) %>% dplyr::ungroup()
# # mean_run(x = data$value, k = 7, lag = 0, idx = as_date(data$date))
#
# print(data[data$key %in% c("Cumulative cases") & data$table %in% c("cases", "rls", "cases; areas", "rls; areas"), ], n = Inf)
# print(data[data$key %in% c("Active cases") & data$table %in% c("cases", "rls", "cases; areas", "rls; areas"), ], n = Inf)
# print(data[data$key %in% c("Average screening test per day"), ], n = Inf)
# ggplot(data = data[data$key %in% keys_to_calc_avg[4:5], ]) + geom_line(mapping = aes(x = time, y = value, group = key, color = key)) + theme_bw() + ggtitle("Outaouais") + theme(legend.position = "top")
# ggplot(data = data[data$key %in% c("Average screening test per day", "Active cases"), ]) + geom_line(mapping = aes(x = time, y = value, group = key, color = key)) + theme_bw() + ggtitle("Outaouais") + theme(legend.position = "top")


