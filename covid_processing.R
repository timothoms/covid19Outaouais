library("tidyverse")
Sys.setlocale(category = "LC_ALL", locale = "en_CA.UTF-8")

### reading HTML source files
ParseHTMLtables <- function(path) {
  ids <- files <- dir(path)
  ids <- str_replace(ids, ".snapshot", "")
  ids <- str_replace(ids, ".html", "")
  files <- paste(path, files, sep = "")
  names(files) <- ids
  tables <- parallel::mclapply(files, function(page) {
    webpage <- rvest::read_html(page, encoding = "UTF-8")
    tab <- tryCatch(webpage %>%
      rvest::html_nodes(css = "table") %>%
      rvest::html_table(fill = TRUE), error = function(x) return(NULL) )
      return(tab)
  })
  return(tables)
}
tables <- ParseHTMLtables(path = "websites/local_sit_en/")
## make sure to catch all tables, count them
# sum(unlist(lapply(tables, length)))
# unique(unlist(lapply(tables, function(set) lapply(set, names)), recursive = FALSE))
# lapply(tables, function(set) lapply(set, function(tf) identical(names(tf), c("X1", "X2", "X3"))))
covid <- list(
  cases = lapply(tables, function(set) set[unlist(lapply(set, function(tf) identical(names(tf), c("X1", "X2"))))]),
  hours = lapply(tables, function(set) set[unlist(lapply(set, function(tf) identical(names(tf), c("X1", "X2", "X3"))))]),
  areas = lapply(tables, function(set) set[unlist(lapply(set, function(tf) names(tf)[1] %in% c("Territory", "City or Municipality", "City or municipality", "Ville ou Municipalité")))]),
  rls = lapply(tables, function(set) set[unlist(lapply(set, function(tf) names(tf)[1] %in% c("Local service area (RLS)", "Réseaux locaux de services (RLS)")))]),
  seniors = lapply(tables, function(set) set[unlist(lapply(set, function(tf) names(tf)[1] %in% c("Senior residence name")))]),
  facilities = lapply(tables, function(set) set[unlist(lapply(set, function(tf) names(tf)[1] %in% c("Facilities name", "Facilities")))])
)
# sum(unlist(lapply(covid, function(toplevel) lapply(toplevel, length) )))
covid <- lapply(covid, function(toplevel) {toplevel[lapply(toplevel, length) > 0]})
# sum(unlist(lapply(covid, function(toplevel) lapply(toplevel, length) )))
# lapply(covid, function(toplevel) sum(unlist(lapply(toplevel, function(set) length(set) > 1))))
lapply(covid, function(toplevel) unique(unlist(lapply(toplevel, length))))
lapply(covid, function(toplevel) unique(unlist(lapply(toplevel, class))))
# covid <- lapply(covid, function(toplevel) lapply(toplevel, function(set) do.call(rbind, set)))
covid$cases <- lapply(covid$cases, function(set) do.call(rbind, set))
covid[-1] <- lapply(covid[-1], function(set) unlist(set, recursive = FALSE))
covid$hours <- NULL

### this was the old way, superseded by more robust code above for sorting through the initial tables
# sort(unique(unlist(lapply(tables, length))))
## cases: 5-1; 6-1; 7-1; 8-2
## rls: 3-1; 4-1; 5-2; 6-2; 7-2; 8-3
## areas: 2-1; 3-2; 4-2; 5-3; 6-3; 7-3; 8-4
## seniors' residences details: 4-4; 6-6; 7-7; 8-8
#### hospital facilities details: 5-5;
## outbreak in facilities summary: 6-5; 7-6; 8-7
#### hospitals summary: 2-2; 3-3; 4-3; 5-4; 6-4; 7-4; 7-5; 8-5; 8-6
# unique(lapply(tables[unlist(lapply(tables, length)) == 2], function(set) names(set[[1]])))
# covid <- list(
#   cases = c(
#     lapply(tables[unlist(lapply(tables, length)) == 5], function(set) set[[1]]),
#     lapply(tables[unlist(lapply(tables, length)) == 6], function(set) set[[1]]),
#     lapply(tables[unlist(lapply(tables, length)) == 7], function(set) set[[1]]),
#     lapply(tables[unlist(lapply(tables, length)) == 8], function(set) set[[2]])
#   ),
#   rls = c(
#     lapply(tables[unlist(lapply(tables, length)) == 3], function(set) set[[1]]),
#     lapply(tables[unlist(lapply(tables, length)) == 4], function(set) set[[1]]),
#     lapply(tables[unlist(lapply(tables, length)) == 5], function(set) set[[2]]),
#     lapply(tables[unlist(lapply(tables, length)) == 6], function(set) set[[2]]),
#     lapply(tables[unlist(lapply(tables, length)) == 7], function(set) set[[2]]),
#     lapply(tables[unlist(lapply(tables, length)) == 8], function(set) set[[3]])
#   ),
#   areas = c(
#     lapply(tables[unlist(lapply(tables, length)) == 2], function(set) set[[1]]),
#     lapply(tables[unlist(lapply(tables, length)) == 3], function(set) set[[2]]),
#     lapply(tables[unlist(lapply(tables, length)) == 4], function(set) set[[2]]),
#     lapply(tables[unlist(lapply(tables, length)) == 5], function(set) set[[3]]),
#     lapply(tables[unlist(lapply(tables, length)) == 6], function(set) set[[3]]),
#     lapply(tables[unlist(lapply(tables, length)) == 7], function(set) set[[3]]),
#     lapply(tables[unlist(lapply(tables, length)) == 8], function(set) set[[4]])
#   ),
#   hospital = c(
#     lapply(tables[unlist(lapply(tables, length)) == 2], function(set) set[[2]]),
#     lapply(tables[unlist(lapply(tables, length)) == 3], function(set) set[[3]]),
#     lapply(tables[unlist(lapply(tables, length)) == 4], function(set) set[[3]]),
#     lapply(tables[unlist(lapply(tables, length)) == 5], function(set) set[[4]]),
#     lapply(tables[unlist(lapply(tables, length)) == 6], function(set) set[[4]]),
#     lapply(tables[unlist(lapply(tables, length)) == 7], function(set) set[[4]]),
#     lapply(tables[unlist(lapply(tables, length)) == 7], function(set) set[[5]]),
#     lapply(tables[unlist(lapply(tables, length)) == 8], function(set) set[[5]]),
#     lapply(tables[unlist(lapply(tables, length)) == 8], function(set) set[[6]])
#   ),
#   facilities = lapply(tables[unlist(lapply(tables, length)) == 5], function(set) set[[5]])
# )

lapply(covid, function(set) unique(lapply(set, names)))
## duplicate tables
lapply(covid, function(set) {
  paste(length(unique(set)), "/", length(set))
})
## checking
lapply(covid[c("cases", "areas", "rls")], function(toplevel) unique(lapply(toplevel, names)))

### standardizing tables
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
covid <- lapply(covid[c("cases", "areas", "rls")], function(set) lapply(names(set), FormatTable, tables = set))
lapply(covid, function(set) unique(lapply(set, names)))
## missing labels
# covid$areas[unlist(lapply(covid$areas, function(df) sum(df$key == "")) > 0)]

### combining tables
covid <- lapply(covid, function(set) do.call(rbind, set))
covid <- lapply(covid, function(df) df[order(df$time), ])
names(covid_tables) <- covid_tables <- names(covid)
covid <- lapply(covid_tables, function(table_name) {
  df <- covid[[table_name]]
  df$table <- table_name
  return(df)
})

### clean & consistent labels
lapply(covid, function(set) unique(set$key))
covid <- lapply(covid, function(df) {
  df$key <- str_replace(df$key, fixed("**"), "")
  df$key <- str_replace(df$key, fixed("*"), "")
  df$key[df$key %in% c("Cumulative cases", "Total number of cases in Outaouais", "Total") & df$table == "cases"] <- "Total cases (Outaouais)"
  df$key[df$key %in% c("Cumulative cases", "Total number of cases in Outaouais", "Total") & df$table == "rls"] <- "Total cases (RLS)"
  df$key[df$key %in% c("Cumulative cases", "Total number of cases in Outaouais", "Total") & df$table == "areas"] <- "Total cases (municipalities)"
  df$key[df$key %in% c("To be determined", "To be determined0", "À déterminer")] <- "To be determined"
  df$key[df$key %in% c("Average screening test per day (last 6 days)", "Average screening test per day (last 7 days)", "Average screening test per day534", "Average screening test per day")] <- "Average screening tests per day"
  df$key[df$key == "Number of deaths" & df$table == "hospital"] <- "Deaths"
  df$key[df$key %in% c("Deaths", "Number of deaths")] <- "Total deaths"
  df$key[df$key %in% c("Healed cases", "Total number of healed cases in Outaouais", "Resolved cases")] <- "Healed/resolved cases"
  df$key[df$key %in% c("Active cases", "Total of active cases in Outaouais")] <- "Active cases"
  df$key[df$key %in% c("Collines-de-l'Outaouais", "RLS des Collines-de-l'Outaouais") & df$table == "rls"] <- "RLS des Collines-de-l'Outaouais"
  df$key[df$key %in% c("Papineau", "RLS de Papineau") & df$table == "rls"] <- "RLS de Papineau"
  df$key[df$key %in% c("Pontiac", "RLS du Pontiac") & df$table == "rls"] <- "RLS du Pontiac"
  df$key[df$key %in% c("Gatineau", "RLS de Gatineau", "Ville de Gatineau") & df$table == "rls"] <- "RLS de Gatineau"
  df$key[df$key %in% c("Vallée-de-la-Gatineau", "RLS de la Vallée-de-la-Gatineau") & df$table == "rls"] <- "RLS de la Vallée-de-la-Gatineau"
  df$key <- str_replace(df$key, fixed("Municipality of "), "")
  df$key <- str_replace(df$key, fixed("Municipalité de "), "")
  df$key[df$key %in% c("Lac-des-Plages", "Lac-Des-Plages") & df$table == "areas"] <- "Lac-des-Plages"
  df$key[df$key %in% c("Gatineau", "Ville de Gatineau") & df$table == "areas"] <- "Gatineau"
  df$key[df$key %in% c("Pontiac", "MRC du Pontiac") & df$table == "areas"] <- "MRC du Pontiac"
  df$key[df$key %in% c("Val-des-Bois", "Val-des-bois") & df$table == "areas"] <- "Val-des-Bois"
  df$key[df$key %in% c("L'Isle-aux-Allumettes", "L'Îsles-aux-Allumettes") & df$table == "areas"] <- "L'Isle-aux-Allumettes"
  df <- df[df$key != df$value, ]
  df$key <- str_replace(df$key, "Number of ", "")
  df$key[df$key %in% c("hospitalizations at the designated COVID-19 centre (including intensive care patients)",
                       "Hospitalizations at the designated COVID-19 center (including intensive care patients)")] <- "Hospitalizations"
  df$key[df$key %in% c("People in intensive care at the designated COVID-19 centre",
                       "Hospitalizations in the intensive care unit of the designated COVID-19 center")] <- "Hospitalizations in ICU"
  df$key[df$key %in% c("employees with COVID-19 since the beginning of the pandemic",
                       "employees affected by COVID-19 since beginning of pandemic",
                       "employees affected by COVID-19")] <- "Hospital employees affected"
  df$key[df$key %in% c("employees with COVID-19 recovered",
                       "employees affected by COVID-19 healed")] <- "Hospital employees recovered"
  df$key[df$key %in% c("employees currently positive with COVID-19")] <- "Hospital employees currently positive"
  df$key[df$key %in% c("employees in isolation (contact with positive case)")] <- "Hospital employees in isolation"
  df$key[df$key %in% c("seniors' residences where there is an outbreak",
                       "Total number of seniors' residences where there is an outbreak",
                       "seniors' residences affected (CHSLD, private seniors' residences)",
                       "Total number of facilitises where there is an outbreak")] <- "Facilities with outbreaks"
  df$key[df$key %in% c("seniors' residences where there is an active outbreak",
                       "facilitises where there is an active outbreak")] <- "Facilities with active outbreaks"
  return(df)
})
lapply(covid, function(set) sort(unique(set$key)))
covid <- unique(do.call(rbind, covid))

### active cases column
table(covid$key[!is.na(covid$active)])
to_add <- covid[!is.na(covid$active), ]
covid$active <- NULL
to_add$value <- to_add$active
to_add$active <- NULL
to_add$table <- paste(to_add$table, "active", sep = "_")
covid <- rbind(covid, to_add)

### checks on labels
load("data/municipalities.RData")
unique(municipalities$municipality)[!unique(municipalities$municipality) %in% unique(covid$key)]
unique(covid$key)[!unique(covid$key) %in% unique(municipalities$municipality)]
unique(covid$key)[str_detect(unique(covid$key), "MRC")]
unique(municipalities$mrc)[!unique(municipalities$mrc) %in% unique(covid$key)]

### cleaning data points
covid$time <- lubridate::as_datetime(covid$time, tz = "America/Montreal")
covid$value <- str_replace(covid$value, fixed("**"), "")
covid$value <- str_replace(covid$value, fixed("*"), "")
covid <- covid[covid$value != "", ]
covid <- covid[covid$value != "ND", ]
### this is for simplifying the automation but needs to be flagged in the description
# covid[covid$value %in% c("5 et moins", "5 or moins", "5 or less", "5 ou moins"), ]
covid$value[covid$value %in% c("5 et moins", "5 or moins", "5 or less", "5 ou moins")] <- "5"
covid$value <- as.integer(covid$value)
covid <- covid %>% arrange(time, key, table)

### error checking: checks & fix extreme values that are likely due to input error
### (still need a simple and consistent approach to error detection, perhaps from the time series methodological literature)
VisualCheck <- function(keys, tab, exclude = NULL) {
  keys <- keys[!keys %in% exclude]
  ggplot(data = covid[covid$key %in% keys & covid$table == tab, ]) +
    geom_line(mapping = aes(x = time, y = value, group = key, color = key)) +
    geom_point(data = covid[covid$key == "" & covid$table == tab, ], mapping = aes(x = time, y = value, group = key, color = key)) +
    theme_classic() + labs(x = "", y = "") +
    theme(legend.position = "bottom")
}
# check <- unique(covid$key)[unique(covid$key) %in% municipalities$municipality[municipalities$mrc == "Papineau"]]
# covid[covid$key == "" & covid$time > "2020-09-28" & covid$time < "2020-10-02", ]
# VisualCheck(keys = c("Montpellier"), tab = "areas")
# as.data.frame(covid[covid$key %in% c("", "Montpellier") & covid$time >= "2021-03-10" & covid$time <= "2021-03-19", ])
covid$key[covid$key == "" & covid$time >= "2021-03-10" & covid$time <= "2021-03-19" & covid$table == "areas"] <- "Montpellier"
# VisualCheck(keys = tapply(covid$key, covid$table, unique)[["cases"]], tab = "cases")
covid <- covid[!(covid$key == "Healed/resolved cases" & covid$time > "2020-10-31" & covid$time < "2020-11-03" & covid$value == 281), ]
# VisualCheck(keys = c("Healed/resolved cases", "Cumulative cases"), tab = "cases")
# VisualCheck(keys = tapply(covid$key, covid$table, unique)[["cases"]], tab = "cases", exclude = c("Healed/resolved cases", "Cumulative cases"))
# VisualCheck(keys = tapply(covid$key, covid$table, unique)[["rls"]], tab = "rls")
covid$value[covid$time > "2020-05-23" & covid$time < "2020-05-25" & covid$key == "Total cases (RLS)" & covid$value == 4729] <- 479
covid$value[covid$time > "2020-06-24" & covid$time < "2020-06-25" & covid$key == "RLS de Gatineau" & covid$value == 47] <- 497
covid <- covid[!(covid$time > "2020-12-15" & covid$time < "2020-12-16" & covid$key == "RLS de Gatineau" & covid$value == 32172), ]
# VisualCheck(keys = c("Total cases", "Total cases (RLS)", "Total", "RLS de Gatineau"), tab = "rls")
# VisualCheck(keys = c("Total deaths", "To be determined", "To be determined (active)"), tab = "rls")
# VisualCheck(keys = c("Active cases", "Total cases (active)", "Healed/resolved cases"), tab = "rls")
# VisualCheck(keys = c("RLS de Gatineau", "RLS de Gatineau (active)"), tab = "rls")
# VisualCheck(keys = c("RLS de Papineau", "RLS de Papineau (active)"), tab = "rls")
covid <- covid[!(covid$time > "2021-01-06" & covid$time < "2021-01-07" & covid$key == "RLS du Pontiac" & covid$value == 0), ]
# VisualCheck(keys = c("RLS du Pontiac", "RLS du Pontiac (active)"), tab = "rls")
# VisualCheck(keys = c("RLS des Collines-de-l'Outaouais", "RLS des Collines-de-l'Outaouais (active)"), tab = "rls")
# VisualCheck(keys = c("RLS de la Vallée-de-la-Gatineau", "RLS de la Vallée-de-la-Gatineau (active)"), tab = "rls")
# VisualCheck(keys = tapply(covid$key, covid$table, unique)[["areas"]], tab = "areas")
covid$value[covid$time > "2020-05-09" & covid$time < "2020-05-11" & covid$key %in% c("Total", "Total cases", "Total cases (municipalities)") & covid$value == 3334] <- 334
# VisualCheck(keys = c("Total cases", "Total", "Gatineau"), tab = "areas")
# VisualCheck(keys = tapply(covid$key, covid$table, unique)[["areas"]], tab = "areas", exclude = c("Total cases", "Gatineau", "To be determined"))
# VisualCheck(keys = c("Hospitalizations", "Hospitalizations in ICU"), tab = "cases")

api_access<- jsonlite::fromJSON("https://api.opencovid.ca/version")[[1]]
GetOpenCovid <- function(stat, loc) {
  names(stat) <- stat
  df <- lapply(stat, function (stat_code) {
    tab <- lapply(loc, function(location_code) {
      link <- paste("https://api.opencovid.ca/timeseries?stat=", stat_code, "&loc=", location_code, sep = "")
      jsonlite::fromJSON(link)[[stat_code]]
    })
    tab <- do.call(rbind, tab)
    names(tab)[stringr::str_detect(names(tab), "date")] <- "time"
    key <- names(tab)[stringr::str_detect(names(tab), "cumulative_")]
    key <- stringr::str_replace(key, "cumulative_", "")
    names(tab)[stringr::str_detect(names(tab), "cumulative_")] <- "cumulative"
    tab$key <- key
    names(tab)[!names(tab) %in% c("province", "health_region", "key", "time", "cumulative")] <- "value"
    return(tab[, c("province", "health_region", "key", "time", "value", "cumulative")])
  })
  do.call(rbind, df)
}
opencovid <- GetOpenCovid(stat = c("cases", "mortality"), loc = c(2407, 3551, 3595))
opencovid$time <- lubridate::as_datetime(opencovid$time, tz = "America/Montreal", format = "%d-%m-%Y")
# opencovid <- opencovid[opencovid$time > "2020-03-14", ]
new <- opencovid[, c("health_region", "time", "key", "value")]
new$key <- paste("New", new$key)
opencovid <- opencovid[, c("health_region", "time", "key", "cumulative")]
opencovid$key <- paste("Total", opencovid$key)
names(opencovid)[names(opencovid) == "cumulative"] <- "value"
opencovid <- rbind(opencovid, new)
opencovid$table <- "opencovid.ca"
opencovid$key <- paste(opencovid$key, " (", opencovid$health_region, ")", sep = "")
opencovid$health_region <- NULL
covid <- rbind(covid, opencovid)

### de-duplication and calculating change variables
# sort(unique(covid$key))
exclude <- c(municipalities$municipality,
             "", "Average screening tests per day",
             "To be determined", "To be determined",
             "Daily increase", "Healed/resolved cases",
             "New cases (Ottawa)", "New cases (Outaouais)",
             "New cases (Toronto)", "New deaths (Ottawa)",
             "New deaths (Outaouais)", "New deaths (Toronto)",
             "Total deaths", "Total deaths (Ottawa)",
             "Total deaths (Outaouais)", "Total deaths (Toronto)",
             "Hospital employees affected",
             "Hospital employees currently positive",
             "Hospital employees in isolation",
             "Hospital employees recovered",
             "Facilities with active outbreaks",
             "Facilities with outbreaks",
             "Active outbreaks", "Ended outbreaks")
daily <- covid[!covid$key %in% exclude, ]
daily <- daily %>% arrange(key, time)
daily$date <- lubridate::as_date(daily$time)
daily <- daily %>% group_by(table, key, date) %>% filter(time == max(time))
# daily[duplicated(daily[, c("table", "key", "date")]), ]
# daily %>% filter(key == "To be determined") %>% arrange(time) %>% print(n = Inf)
## not currently showing this indicator in any figures
# daily %>% filter(key == "Total deaths") %>% arrange(time) %>% print(n = Inf)
# daily %>% filter(key == "Healed/resolved cases") %>% arrange(time) %>% print(n = Inf)
# daily %>% filter(key == "Active cases") %>% arrange(time) %>% print(n = Inf)
# daily %>% filter(key %in% c("Total cases", "Total cases (RLS)")) %>% arrange(time) %>% print(n = Inf)
# daily %>% filter(key == "Total") %>% arrange(time) %>% print(n = Inf)
# daily %>% filter(key %in% c("Total", "Total cases", "Cumulative cases")) %>% arrange(time) %>% print(n = Inf)
## these are closely related and often the same but different aggregation:
## cumulative for entire region, total aggregation across RLS or MRC
## "Total"/"Total cases (RLS)" sometimes different for RLS and municipalities;
daily$table[daily$key %in% c("Total deaths", "Healed/resolved cases", "Active cases") & daily$table %in% c("rls", "areas")] <- "cases" # , "Total cases"
daily <- daily[, c("table", "key", "date", "value")]
daily <- daily %>% arrange(table, key, date) %>% group_by(table, key) %>% mutate(previous_date = dplyr::lag(date))
daily <- daily %>% mutate(days_from_prev = as.integer(date - previous_date))
daily <- daily %>% arrange(table, key, date) %>% group_by(table, key) %>% mutate(previous_value = dplyr::lag(value))
daily <- daily %>% mutate(change_from_prev = value - previous_value)
daily$previous_date <- daily$previous_value <- NULL
daily <- daily %>% mutate(daily_change = round(change_from_prev / days_from_prev, 3))
daily <- daily %>% arrange(table, key, date) %>% group_by(table, key) %>% mutate(daily_change_avg = runner::mean_run(x = daily_change, k = 7, lag = 0, idx = date)) %>% ungroup()
# tapply(daily$key, daily$table, unique)
sort(unique(unlist(tapply(daily$key, daily$table, unique))))
daily$change_key <- daily$key
daily$change_key <- str_replace(daily$change_key, "Total cases", "Average increase per day")
daily$change_key <- str_replace(daily$change_key, "Active cases", "Average increase in active cases per day")
sort(unique(unlist(tapply(daily$change_key, daily$table, unique))))

### time since previous
covid <- covid %>% arrange(table, key, time) %>% group_by(table, key) %>% mutate(previous_time = dplyr::lag(time))
covid <- covid %>% mutate(prev = round(difftime(time, previous_time, units = "days"), 1))
covid <- covid[, c("table", "time", "prev",  "key", "value")]
# tapply(covid$key, covid$table, unique)

### saving data
save(covid, file = "data/covid_local.RData")
save(daily, file = "data/covid_local_daily.RData")
file_connection <- file("data/data_update_time.txt")
writeLines(as.character(lubridate::now()), file_connection)
close(file_connection)
file_connection <- file("data/api_access_time.txt")
writeLines(as.character(api_access), file_connection)
close(file_connection)

### vaccination dataset
link <- "https://cdn-contenu.quebec.ca/cdn-contenu/sante/documents/Problemes_de_sante/covid-19/csv/doses-vaccins.csv"
new_vac <- readr::read_delim(link, delim = ";")
new_vac$time <- lubridate::now()
# new_vac$note <- "Total vaccine doses administered"
names(new_vac)[1:2] <- c("key", "value")
new_vac$flag <- stringr::str_sub(new_vac$key, 3, 5) == " - "
new_vac$region_code[new_vac$flag] <- stringr::str_sub(new_vac$key[new_vac$flag], 1, 2)
stringr::str_sub(new_vac$key[new_vac$flag], 1, 5) <-""
new_vac <- new_vac[c("time", "key", "region_code", "value")]
load("data/vaccination.RData", verbose = TRUE)
vaccination <- rbind(vaccination, new_vac)
vaccination <- vaccination %>% arrange(key, time)
save(vaccination, file = "data/vaccination.RData")

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
