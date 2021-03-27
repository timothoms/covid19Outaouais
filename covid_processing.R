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

### initial tables
sort(unique(unlist(lapply(tables, length))))
# unique(lapply(tables[unlist(lapply(tables, length)) == 2], function(set) names(set[[1]])))
covid <- list(
  cases = c(
    lapply(tables[unlist(lapply(tables, length)) == 5], function(set) set[[1]]),
    lapply(tables[unlist(lapply(tables, length)) == 6], function(set) set[[1]]),
    lapply(tables[unlist(lapply(tables, length)) == 7], function(set) set[[1]]),
    lapply(tables[unlist(lapply(tables, length)) == 8], function(set) set[[2]])
  ),
  rls = c(
    lapply(tables[unlist(lapply(tables, length)) == 3], function(set) set[[1]]),
    lapply(tables[unlist(lapply(tables, length)) == 4], function(set) set[[1]]),
    lapply(tables[unlist(lapply(tables, length)) == 5], function(set) set[[2]]),
    lapply(tables[unlist(lapply(tables, length)) == 6], function(set) set[[2]]),
    lapply(tables[unlist(lapply(tables, length)) == 7], function(set) set[[2]]),
    lapply(tables[unlist(lapply(tables, length)) == 8], function(set) set[[3]])
  ),
  areas = c(
    lapply(tables[unlist(lapply(tables, length)) == 2], function(set) set[[1]]),
    lapply(tables[unlist(lapply(tables, length)) == 3], function(set) set[[2]]),
    lapply(tables[unlist(lapply(tables, length)) == 4], function(set) set[[2]]),
    lapply(tables[unlist(lapply(tables, length)) == 5], function(set) set[[3]]),
    lapply(tables[unlist(lapply(tables, length)) == 6], function(set) set[[3]]),
    lapply(tables[unlist(lapply(tables, length)) == 7], function(set) set[[3]]),
    lapply(tables[unlist(lapply(tables, length)) == 8], function(set) set[[4]])
  )
)
lapply(covid, function(set) unique(lapply(set, names)))
## duplicate tables
lapply(covid, function(set) {
  paste(length(unique(set)), "/", length(set))
})

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
covid <- lapply(covid, function(set) lapply(names(set), FormatTable, tables = set))
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

# jsonlite::fromJSON("https://api.opencovid.ca/version")
api_link <- "https://api.opencovid.ca/timeseries?stat=cases&loc=2407"
opencovid <- jsonlite::fromJSON(api_link)
opencovid <- opencovid$cases[, c("date_report", "health_region", "cases", "cumulative_cases")]
names(opencovid) <- c("time", "key", "cases", "cumulative_cases")
opencovid$time <- lubridate::as_datetime(opencovid$time, tz = "America/Montreal", format = "%d-%m-%Y")
opencovid <- opencovid[opencovid$time > "2020-03-14", ]
new <- opencovid[, c("time", "key", "cases")]
new$key <- "New cases (Outaouais)"
names(new)[3] <- "value"
opencovid <- opencovid[, c("time", "key", "cumulative_cases")]
opencovid$key <- "Total cases (Outaouais)"
names(opencovid)[3] <- "value"
opencovid <- rbind(opencovid, new)
opencovid$table <- "opencovid.ca"
covid <- rbind(covid, opencovid)

### de-duplication and calculating change variables
# sort(unique(covid$key))
exclude <- c(municipalities$municipality, "", "Average screening tests per day", "To be determined", "To be determined", "Daily increase", "New cases")
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
