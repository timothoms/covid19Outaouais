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
tables <- ParseHTMLtables(path = "_websites/local_sit_en/")

## make sure to catch all tables, count them
# sum(unlist(lapply(tables, length)))
# unique(unlist(lapply(tables, function(set) lapply(set, names)), recursive = FALSE))
# lapply(tables, function(set) lapply(set, function(tf) identical(names(tf), c("X1", "X2", "X3"))))
cisss <- list(
  cases = lapply(tables, function(set) set[unlist(lapply(set, function(tf) identical(names(tf), c("X1", "X2"))))]),
  hours = lapply(tables, function(set) set[unlist(lapply(set, function(tf) identical(names(tf), c("X1", "X2", "X3"))))]),
  areas = lapply(tables, function(set) set[unlist(lapply(set, function(tf) names(tf)[1] %in% c("Territory", "City or Municipality", "City or municipality", "Ville ou Municipalité")))]),
  rls = lapply(tables, function(set) set[unlist(lapply(set, function(tf) names(tf)[1] %in% c("Local service area (RLS)", "Réseaux locaux de services (RLS)")))]),
  seniors = lapply(tables, function(set) set[unlist(lapply(set, function(tf) names(tf)[1] %in% c("Senior residence name")))]),
  facilities = lapply(tables, function(set) set[unlist(lapply(set, function(tf) names(tf)[1] %in% c("Facilities name", "Facilities")))])
)
# sum(unlist(lapply(cisss, function(toplevel) lapply(toplevel, length) )))
cisss <- lapply(cisss, function(toplevel) {toplevel[lapply(toplevel, length) > 0]})
# sum(unlist(lapply(cisss, function(toplevel) lapply(toplevel, length) )))
# lapply(cisss, function(toplevel) sum(unlist(lapply(toplevel, function(set) length(set) > 1))))
lapply(cisss, function(toplevel) unique(unlist(lapply(toplevel, length))))
lapply(cisss, function(toplevel) unique(unlist(lapply(toplevel, class))))
# cisss <- lapply(cisss, function(toplevel) lapply(toplevel, function(set) do.call(rbind, set)))
cisss$cases <- lapply(cisss$cases, function(set) do.call(rbind, set))
cisss[-1] <- lapply(cisss[-1], function(set) unlist(set, recursive = FALSE))
cisss$hours <- NULL
lapply(cisss, function(set) unique(lapply(set, names)))

## duplicate tables
lapply(cisss, function(set) {
  paste(length(unique(set)), "/", length(set))
})

## checking
lapply(cisss[c("cases", "areas", "rls")], function(toplevel) unique(lapply(toplevel, names)))

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
cisss <- lapply(cisss[c("cases", "areas", "rls")], function(set) lapply(names(set), FormatTable, tables = set))
lapply(cisss, function(set) unique(lapply(set, names)))
## missing labels
# cisss$areas[unlist(lapply(cisss$areas, function(df) sum(df$key == "")) > 0)]

### combining tables
cisss <- lapply(cisss, function(set) do.call(rbind, set))
cisss <- lapply(cisss, function(df) df[order(df$time), ])
names(cisss_tables) <- cisss_tables <- names(cisss)
cisss <- lapply(cisss_tables, function(table_name) {
  df <- cisss[[table_name]]
  df$table <- table_name
  return(df)
})

### clean & consistent labels
lapply(cisss, function(set) unique(set$key))
cisss <- lapply(cisss, function(df) {
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
  df$key[df$key %in% c("Denholm", "Denholm6") & df$table == "areas"] <- "Denholm"
  df <- df[df$key != df$value, ]
  df$key <- str_replace(df$key, "Number of ", "")
  df$key[df$key %in% c("hospitalizations at the designated COVID-19 centre (including intensive care patients)",
                       "Hospitalizations at the designated COVID-19 center (including intensive care patients)",
                       "Hospitalisations at the designated COVID-19 unit (including patients at intensive care)")] <- "Hospitalizations"
  df$key[df$key %in% c("People in intensive care at the designated COVID-19 centre",
                       "patients at the COVID-19 intensive care",
                       "Hospitalizations in the intensive care unit of the designated COVID-19 center")] <- "Hospitalizations, ICU"
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
lapply(cisss, function(set) sort(unique(set$key)))
cisss <- unique(do.call(rbind, cisss))
# cisss[cisss$key == "", ]

### active cases column
table(cisss$key[!is.na(cisss$active)])
to_add <- cisss[!is.na(cisss$active), ]
cisss$active <- NULL
to_add$value <- to_add$active
to_add$active <- NULL
to_add$table <- paste(to_add$table, "active", sep = "_")
cisss <- rbind(cisss, to_add)

### checks on labels
load("_data/municipalities.RData")
unique(municipalities$municipality)[!unique(municipalities$municipality) %in% unique(cisss$key)]
unique(cisss$key)[!unique(cisss$key) %in% unique(municipalities$municipality)]
unique(cisss$key)[str_detect(unique(cisss$key), "MRC")]
unique(municipalities$mrc)[!unique(municipalities$mrc) %in% unique(cisss$key)]

### cleaning data points
cisss$time <- lubridate::as_datetime(cisss$time, tz = "America/Montreal")
cisss$value <- str_replace(cisss$value, fixed("**"), "")
cisss$value <- str_replace(cisss$value, fixed("*"), "")
cisss <- cisss[cisss$value != "", ]
cisss <- cisss[cisss$value != "ND", ]
### this is for simplifying the automation and needs to be flagged
# cisss[cisss$value %in% c("5 et moins", "5 or moins", "5 or less", "5 ou moins"), ]
cisss$value[cisss$value %in% c("5 et moins", "5 or moins", "5 or less", "5 ou moins")] <- "5"
cisss$value <- as.integer(cisss$value)
cisss <- cisss %>% arrange(time, key, table)

### error checking: checks & fix extreme values that are likely due to input error
### (still need a simple and consistent approach to error detection, perhaps from the time series methodological literature)
VisualCheck <- function(keys, tab, exclude = NULL) {
  keys <- keys[!keys %in% exclude]
  ggplot(data = cisss[cisss$key %in% keys & cisss$table == tab, ]) +
    geom_line(mapping = aes(x = time, y = value, group = key, color = key)) +
    geom_point(data = cisss[cisss$key == "" & cisss$table == tab, ], mapping = aes(x = time, y = value, group = key, color = key)) +
    theme_classic() + labs(x = "", y = "") +
    theme(legend.position = "bottom")
}
# check <- unique(cisss$key)[unique(cisss$key) %in% municipalities$municipality[municipalities$mrc == "Papineau"]]
# cisss[cisss$key == "" & cisss$time > "2020-09-28" & cisss$time < "2020-10-02", ]
# VisualCheck(keys = c("Montpellier"), tab = "areas")
# as.data.frame(cisss[cisss$key %in% c("", "Montpellier") & cisss$time >= "2021-03-10" & cisss$time <= "2021-03-19", ])
cisss$key[cisss$key == "" & cisss$time >= "2021-03-10" & cisss$time <= "2021-03-19" & cisss$table == "areas"] <- "Montpellier"
# VisualCheck(keys = tapply(cisss$key, cisss$table, unique)[["cases"]], tab = "cases")
cisss <- cisss[!(cisss$key == "Healed/resolved cases" & cisss$time > "2020-10-31" & cisss$time < "2020-11-03" & cisss$value == 281), ]
# VisualCheck(keys = c("Healed/resolved cases", "Cumulative cases"), tab = "cases")
# VisualCheck(keys = tapply(cisss$key, cisss$table, unique)[["cases"]], tab = "cases", exclude = c("Healed/resolved cases", "Cumulative cases"))
# VisualCheck(keys = tapply(cisss$key, cisss$table, unique)[["rls"]], tab = "rls")
cisss$value[cisss$time > "2020-05-23" & cisss$time < "2020-05-25" & cisss$key == "Total cases (RLS)" & cisss$value == 4729] <- 479
cisss$value[cisss$time > "2020-06-24" & cisss$time < "2020-06-25" & cisss$key == "RLS de Gatineau" & cisss$value == 47] <- 497
cisss <- cisss[!(cisss$time > "2020-12-15" & cisss$time < "2020-12-16" & cisss$key == "RLS de Gatineau" & cisss$value == 32172), ]
# VisualCheck(keys = c("Total cases", "Total cases (RLS)", "Total", "RLS de Gatineau"), tab = "rls")
# VisualCheck(keys = c("Total deaths", "To be determined", "To be determined (active)"), tab = "rls")
# VisualCheck(keys = c("Active cases", "Total cases (active)", "Healed/resolved cases"), tab = "rls")
# VisualCheck(keys = c("RLS de Gatineau", "RLS de Gatineau (active)"), tab = "rls")
# VisualCheck(keys = c("RLS de Papineau", "RLS de Papineau (active)"), tab = "rls")
cisss <- cisss[!(cisss$time > "2021-01-06" & cisss$time < "2021-01-07" & cisss$key == "RLS du Pontiac" & cisss$value == 0), ]
# VisualCheck(keys = c("RLS du Pontiac", "RLS du Pontiac (active)"), tab = "rls")
# VisualCheck(keys = c("RLS des Collines-de-l'Outaouais", "RLS des Collines-de-l'Outaouais (active)"), tab = "rls")
# VisualCheck(keys = c("RLS de la Vallée-de-la-Gatineau", "RLS de la Vallée-de-la-Gatineau (active)"), tab = "rls")
# VisualCheck(keys = tapply(cisss$key, cisss$table, unique)[["areas"]], tab = "areas")
cisss$value[cisss$time > "2020-05-09" & cisss$time < "2020-05-11" & cisss$key %in% c("Total", "Total cases", "Total cases (municipalities)") & cisss$value == 3334] <- 334
# VisualCheck(keys = c("Total cases", "Total", "Gatineau"), tab = "areas")
# VisualCheck(keys = tapply(cisss$key, cisss$table, unique)[["areas"]], tab = "areas", exclude = c("Total cases", "Gatineau", "To be determined"))
# VisualCheck(keys = c("Hospitalizations", "Hospitalizations, ICU"), tab = "cases")

# opencovid_update<- jsonlite::fromJSON("https://api.opencovid.ca/version")[[1]]
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
new <- opencovid[, c("health_region", "time", "key", "value")]
new$key <- paste("New", new$key)
opencovid <- opencovid[, c("health_region", "time", "key", "cumulative")]
opencovid$key <- paste("Total", opencovid$key)
names(opencovid)[names(opencovid) == "cumulative"] <- "value"
opencovid <- rbind(opencovid, new)
opencovid$table <- "opencovid.ca"
opencovid$key <- paste(opencovid$key, " (", opencovid$health_region, ")", sep = "")
opencovid$health_region <- NULL
cisss <- rbind(cisss, opencovid)

### de-duplication and calculating change variables
# sort(unique(cisss$key))
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
daily <- cisss[!cisss$key %in% exclude, ]
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
cisss <- cisss %>% arrange(table, key, time) %>% group_by(table, key) %>% mutate(previous_time = dplyr::lag(time))
cisss <- cisss %>% mutate(prev = round(difftime(time, previous_time, units = "days"), 1))
cisss <- cisss[, c("table", "time", "prev",  "key", "value")]
# tapply(cisss$key, cisss$table, unique)

### saving data
save(cisss, file = "_data/cisss.RData")
save(daily, file = "_data/cisss_daily.RData")
# save(opencovid, file = "_data/opencovid.RData")
file_connection <- file("_data/data_update_time.txt")
writeLines(as.character(lubridate::now()), file_connection)
close(file_connection)
