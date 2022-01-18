library("tidyverse")
library("feather")
Sys.setlocale(category = "LC_ALL", locale = "en_CA.UTF-8")
source("_R/ParseHTMLtables.R")
source("_R/FormatTable.R")
source("_R/GetOpenCovid.R")
source("_R/VisualCheck.R")

tables <- ParseHTMLtables(path = "_websites/local_sit_en/")
# vars <- unique(unlist(lapply(tables, function(set) lapply(set, names)), recursive = FALSE))
# vars <- unique(unlist(vars))
# vars[!vars %in% c("X1", "X3", "Territory", "City or Municipality", "City or municipality", "Ville ou Municipalité", "Local service area (RLS)", "Réseaux locaux de services (RLS)", "Senior residence name", "Facilities name", "Facilities")]
cisss <- list(
  cases = lapply(tables, function(set)
    set[unlist(lapply(set, function(tf)
      identical(names(tf), c("X1", "X2"))))]),
  # hours = lapply(tables, function(set)
  #   set[unlist(lapply(set, function(tf)
  #     identical(names(tf), c("X1", "X2", "X3"))))]),
  areas = lapply(tables, function(set)
    set[unlist(lapply(set, function(tf)
      names(tf)[1] %in% c("Territory", "City or Municipality", "City or municipality", "Ville ou Municipalité")))]),
  rls = lapply(tables, function(set)
    set[unlist(lapply(set, function(tf)
      names(tf)[1] %in% c("Local service area (RLS)", "Réseaux locaux de services (RLS)")))]),
  seniors = lapply(tables, function(set)
    set[unlist(lapply(set, function(tf)
      names(tf)[1] %in% c("Senior residence name")))]),
  facilities = lapply(tables, function(set)
    set[unlist(lapply(set, function(tf)
      names(tf)[1] %in% c("Facilities name", "Facilities")))])
)
cisss <- lapply(cisss, function(toplevel) {toplevel[lapply(toplevel, length) > 0]})
# lapply(cisss, function(toplevel) sum(unlist(lapply(toplevel, function(set) length(set) > 1))))
# lapply(cisss, function(toplevel) unique(unlist(lapply(toplevel, length))))
cisss$cases <- lapply(cisss$cases, function(set) do.call(rbind, set))
cisss[-1] <- lapply(cisss[-1], function(set) unlist(set, recursive = FALSE))
# lapply(cisss, function(set) unique(lapply(set, names)))

### duplicate tables
lapply(cisss, function(set) { paste(length(unique(set)), "/", length(set)) })

### checking
lapply(cisss[c("cases", "areas", "rls")], function(toplevel) unique(lapply(toplevel, names)))

### standardizing tables
cisss <- lapply(cisss[c("cases", "areas", "rls")], function(set) lapply(names(set), FormatTable, tables = set))
lapply(cisss, function(set) unique(lapply(set, names)))

### missing labels: figure out here
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
# lapply(cisss, function(set) unique(set$key))
cisss <- lapply(cisss, function(df) {
  df$key <- str_replace(df$key, fixed("**"), "")
  df$key <- str_replace(df$key, fixed("*"), "")
  vars <- c("Cumulative cases", "Total number of cases in Outaouais", "Total")
  df$key[df$key %in% vars & df$table == "cases"] <- "Total cases (Outaouais)"
  df$key[df$key %in% vars & df$table == "rls"] <- "Total cases (RLS)"
  df$key[df$key %in% vars & df$table == "areas"] <- "Total cases (municipalities)"
  vars <- c("To be determined", "To be determined0", "À déterminer")
  df$key[df$key %in% vars] <- "To be determined"
  df$key[df$key == "To be determined" & df$table %in% c("rls", "active")] <- "To be determined (RLS)"
  vars <- c("Average screening test per day (last 6 days)", "Average screening test per day (last 7 days)",
            "Average screening test per day534", "Average screening test per day")
  df$key[df$key %in% vars] <- "Average screening tests per day"
  df$key[df$key == "Number of deaths" & df$table == "hospital"] <- "Deaths"
  df$key[df$key %in% c("Deaths", "Number of deaths")] <- "Total deaths"
  vars <- c("Healed cases", "Total number of healed cases in Outaouais", "Resolved cases")
  df$key[df$key %in% vars] <- "Healed/resolved cases"
  vars <- c("Active cases", "Total of active cases in Outaouais")
  df$key[df$key %in% vars] <- "Active cases"
  vars <- c("Collines-de-l'Outaouais", "RLS des Collines-de-l'Outaouais")
  df$key[df$key %in% vars & df$table == "rls"] <- "RLS des Collines-de-l'Outaouais"
  vars <- c("Papineau", "RLS de Papineau")
  df$key[df$key %in% vars & df$table == "rls"] <- "RLS de Papineau"
  vars <- c("Pontiac", "RLS du Pontiac")
  df$key[df$key %in% vars & df$table == "rls"] <- "RLS du Pontiac"
  vars <- c("Gatineau", "RLS de Gatineau", "Ville de Gatineau")
  df$key[df$key %in% vars & df$table == "rls"] <- "RLS de Gatineau"
  vars <- c("Vallée-de-la-Gatineau", "RLS de la Vallée-de-la-Gatineau")
  df$key[df$key %in% vars & df$table == "rls"] <- "RLS de la Vallée-de-la-Gatineau"
  df$key <- str_replace(df$key, fixed("Municipality of "), "")
  df$key <- str_replace(df$key, fixed("Municipalité de "), "")
  vars <- c("Lac-des-Plages", "Lac-Des-Plages")
  df$key[df$key %in% vars & df$table == "areas"] <- "Lac-des-Plages"
  vars <- c("Gatineau", "Ville de Gatineau")
  df$key[df$key %in% vars & df$table == "areas"] <- "Gatineau"
  vars <- c("Pontiac", "MRC du Pontiac")
  df$key[df$key %in% vars & df$table == "areas"] <- "MRC du Pontiac"
  vars <- c("Val-des-Bois", "Val-des-bois")
  df$key[df$key %in% vars & df$table == "areas"] <- "Val-des-Bois"
  vars <- c("L'Isle-aux-Allumettes", "L'Îsles-aux-Allumettes")
  df$key[df$key %in% vars & df$table == "areas"] <- "L'Isle-aux-Allumettes"
  vars <- c("Denholm", "Denholm6")
  df$key[df$key %in% vars & df$table == "areas"] <- "Denholm"
  df <- df[df$key != df$value, ]
  df$key <- str_replace(df$key, "Number of ", "")
  vars <- c("hospitalizations at the designated COVID-19 centre (including intensive care patients)",
            "Hospitalizations at the designated COVID-19 center (including intensive care patients)",
            "Hospitalisations at the designated COVID-19 unit (including patients at intensive care)")
  df$key[df$key %in% vars] <- "Hospitalizations"
  vars <- c("People in intensive care at the designated COVID-19 centre",
            "patients at the COVID-19 intensive care",
            "Hospitalizations in the intensive care unit of the designated COVID-19 center")
  df$key[df$key %in% vars] <- "Hospitalizations, ICU"
  vars <- c("employees with COVID-19 since the beginning of the pandemic",
            "employees affected by COVID-19 since beginning of pandemic",
            "employees affected by COVID-19")
  df$key[df$key %in% vars] <- "Hospital employees affected"
  vars <- c("employees with COVID-19 recovered", "employees affected by COVID-19 healed")
  df$key[df$key %in% vars] <- "Hospital employees recovered"
  vars <- c("employees currently positive with COVID-19")
  df$key[df$key %in% vars] <- "Hospital employees currently positive"
  vars <- c("employees in isolation (contact with positive case)")
  df$key[df$key %in% vars] <- "Hospital employees in isolation"
  vars <- c("seniors' residences where there is an outbreak",
            "Total number of seniors' residences where there is an outbreak",
            "seniors' residences affected (CHSLD, private seniors' residences)",
            "Total number of facilitises where there is an outbreak")
  df$key[df$key %in% vars] <- "Facilities with outbreaks"
  vars <- c("seniors' residences where there is an active outbreak",
            "facilitises where there is an active outbreak")
  df$key[df$key %in% vars] <- "Facilities with active outbreaks"
  return(df)
})
lapply(cisss, function(set) sort(unique(set$key)))
cisss <- unique(do.call(rbind, cisss))
# print(cisss[cisss$key == "", ], n = Inf)

### active cases column
# table(cisss$key[!is.na(cisss$active)])
to_add <- cisss %>%
  filter(!is.na(active)) %>%
  mutate(value = active,
         table = "active") %>%
  select(-active)
cisss <- cisss %>%
  select(-active)
cisss <- rbind(cisss, to_add)
rm(to_add)

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
cisss <- cisss[!cisss$value %in% c("", "ND"), ]
## this is for simplifying the automation and needs to be flagged
# cisss[cisss$value %in% c("5 et moins", "5 or moins", "5 or less", "5 ou moins", "5 or les"), ]
# unique(cisss$value)[str_detect(unique(cisss$value), "5 ")]
cisss$value[cisss$value %in% c("5 or less", "5 et moins", "5 ou moins", "5 or moins", "5 or les")] <- "5"
cisss$value <- str_trim(cisss$value)
cisss$value <- str_squish(cisss$value)
cisss$value <- str_replace(cisss$value, fixed(" "), "")
cisss$value <- str_replace(cisss$value, fixed(","), "")
# sum(is.na(as.integer(cisss$value)))
cisss$value <- as.integer(cisss$value)

### fix extreme values that are likely due to input error
cisss <- cisss %>% arrange(time, key, table)
condition <- cisss$key %in% c("Total", "Total cases", "Total cases (municipalities)") & cisss$time > "2020-05-09" & cisss$time < "2020-05-11" & cisss$value == 3334
cisss$value[condition] <- 334
condition <- cisss$key == "Total cases (RLS)" & cisss$time > "2020-05-23" & cisss$time < "2020-05-25" & cisss$value == 4729
cisss$value[condition] <- 479
condition <- cisss$key == "RLS de Gatineau" & cisss$time > "2020-06-24" & cisss$time < "2020-06-25" & cisss$value == 47
cisss$value[condition] <- 497
condition <- cisss$key == "" & cisss$time > "2020-09-28" & cisss$time < "2020-10-02"
cisss[condition, ]
condition <- !(cisss$key == "Healed/resolved cases" & cisss$time > "2020-10-31" & cisss$time < "2020-11-03" & cisss$value == 281)
cisss <- cisss[condition, ]
condition <- !(cisss$key == "RLS de Gatineau" & cisss$time > "2020-12-15" & cisss$time < "2020-12-16" & cisss$value == 32172)
cisss <- cisss[condition, ]
condition <- !(cisss$key == "RLS du Pontiac" & cisss$time > "2021-01-06" & cisss$time < "2021-01-07" & cisss$value == 0)
cisss <- cisss[condition, ]
condition <- cisss$key %in% c("", "Montpellier") & cisss$time >= "2021-03-10" & cisss$time <= "2021-03-19"
print(cisss[condition, ], n = Inf)
condition <- cisss$key == "" & cisss$time >= "2021-03-10" & cisss$time <= "2021-03-19" & cisss$table == "areas" & cisss$value == 10
cisss$key[condition] <- "Montpellier"
condition <- !(cisss$key == "RLS de Gatineau" & cisss$table == "rls_active" & cisss$time > "2021-04-10" & cisss$time < "2021-04-14" & cisss$value == 63)
cisss <- cisss[condition, ]
condition <- !(cisss$key == "Gatineau" & cisss$table == "areas" & cisss$time > "2021-05-10" & cisss$time < "2021-05-14" & cisss$value == 936)
cisss <- cisss[condition, ]
condition <- !(cisss$key == "Total cases (Outaouais)" & cisss$time > "2021-08-06" & cisss$time < "2021-08-09" & cisss$value == 1262)
cisss <- cisss[condition, ]
condition <- !(cisss$key == "RLS de Gatineau" & cisss$table == "rls" & cisss$time >= "2021-09-25" & cisss$time <= "2021-09-28" & cisss$value == 1004)
cisss <- cisss[condition, ]
rm(condition)

### error checking
# unique(cisss$key)[unique(cisss$key) %in% municipalities$municipality[municipalities$mrc == "Papineau"]]
# tapply(cisss$key, cisss$table, unique)
# VisualCheck(keys = tapply(cisss$key, cisss$table, unique)[["cases"]], tab = "cases",
#             exclude = c("Total cases (Outaouais)", "Healed/resolved cases"))
# VisualCheck(keys = "Total cases (Outaouais)", tab = "cases")
# VisualCheck(keys = "Healed/resolved cases", tab = "cases")
# VisualCheck(keys = tapply(cisss$key, cisss$table, unique)[["rls"]], tab = "rls",
#             exclude = c("Total cases (RLS)", "RLS de Gatineau", "RLS du Pontiac"))
# VisualCheck(keys = "Total cases (RLS)", tab = "rls")
# VisualCheck(keys = "RLS de Gatineau", tab = "rls")
# VisualCheck(keys = "RLS du Pontiac", tab = "rls")
# VisualCheck(keys = tapply(cisss$key, cisss$table, unique)[["rls_active"]], tab = "rls_active",
#             exclude = "RLS de Gatineau")
# VisualCheck(keys = "RLS de Gatineau", tab = "rls_active")
# VisualCheck(keys = tapply(cisss$key, cisss$table, unique)[["areas"]], tab = "areas",
#             exclude = c("Total cases (municipalities)", "Healed/resolved cases", "Gatineau",
#                         "Active cases", "To be determined", "MRC de la Vallée-de-la-Gatineau",
#                         "MRC de Papineau", "MRC des Collines-de-l'Outaouais", "MRC du Pontiac"))
# VisualCheck(keys = "Total cases (municipalities)", tab = "areas")
# VisualCheck(keys = "Healed/resolved cases", tab = "areas")
# VisualCheck(keys = "Gatineau", tab = "areas")
# VisualCheck(keys = "Active cases", tab = "areas")
# VisualCheck(keys = "To be determined", tab = "areas")
# VisualCheck(keys = c("MRC de la Vallée-de-la-Gatineau", "MRC de Papineau", "MRC des Collines-de-l'Outaouais", "MRC du Pontiac"), tab = "areas")

cisss$table[cisss$key %in% c("Active cases", "Healed/resolved cases", "Total deaths") & cisss$table %in% c("rls", "areas")] <- "cases"
cisss$table[cisss$table %in% c("areas", "rls")] <- "cases"

### opencovid
opencovid <- GetOpenCovid(stat = c("cases", "mortality"), loc = c(2407, 3551, 3595))
opencovid$time <- lubridate::as_datetime(opencovid$time, tz = "America/Montreal", format = "%d-%m-%Y")
new <- opencovid %>%
  select(health_region, time, key, value) %>%
  mutate(key = paste("New", key))
opencovid <- opencovid %>%
  select(health_region, time, key, cumulative) %>%
  mutate(key = paste("Total", key)) %>%
  rename(value = cumulative)
opencovid <- rbind(opencovid, new)
rm(new)
opencovid <- opencovid %>%
  mutate(table = "opencovid",
         key = paste(key, " (", health_region, ")", sep = "")) %>%
  select(-health_region)
cisss <- rbind(cisss, opencovid)
cisss <- cisss %>%
  select(key, time, value, table) %>%
  arrange(table, key, time)

### time since previous
# cisss <- cisss %>%
#   arrange(table, key, time) %>%
#   group_by(table, key) %>%
#   mutate(previous_time = dplyr::lag(time),
#          prev = round(difftime(time, previous_time, units = "days"), 1)) %>%
#   select(key, time, value, table, prev)

### de-duplication and calculating change variables
include <- c("Active cases", "MRC de la Vallée-de-la-Gatineau", "MRC de Papineau",
             "MRC des Collines-de-l'Outaouais", "MRC du Pontiac", "RLS de Gatineau",
             "RLS de la Vallée-de-la-Gatineau", "RLS de Papineau",
             "RLS des Collines-de-l'Outaouais", "RLS du Pontiac",
             "Total cases (municipalities)", "Total cases (Ottawa)",
             "Total cases (Outaouais)", "Total cases (RLS)")
daily <- cisss %>%
  filter(key %in% include) %>%
  arrange(key, time) %>%
  mutate(date = lubridate::as_date(time)) %>%
  group_by(table, key, date) %>%
  filter(time == max(time))
daily[duplicated(daily[, c("table", "key", "date")]), ]

### defunct: was checking sth in previous version
# daily %>% filter(key %in% c("Total", "Total cases", "Cumulative cases")) %>% arrange(time) %>% print(n = Inf)
## these are closely related and often the same but different aggregation:
## cumulative for entire region, total aggregation across RLS or MRC
## "Total"/"Total cases (RLS)" sometimes different for RLS and municipalities

daily <- daily %>%
  arrange(table, key, date, time) %>%
  group_by(table, key) %>%
  mutate(previous_date = dplyr::lag(date),
         days_from_prev = as.integer(date - previous_date),
         previous_value = dplyr::lag(value),
         change_from_prev = value - previous_value,
         daily_change = round(change_from_prev / days_from_prev, 3)) %>%
  mutate(value = runner::mean_run(x = daily_change, k = 7, lag = 0, idx = date)) %>%
  select(key, date, time, value, table) %>% ungroup()
# sort(unique(unlist(tapply(daily$key, daily$table, unique))))
daily$key <- str_replace(daily$key, "Total cases", "Average increase per day")
daily$key <- str_replace(daily$key, "Active cases", "Average increase in active cases per day")
daily <- daily %>%
    select(key, time, value, table) %>%
    filter(!is.na(value)) %>%
    mutate(table = paste(table, "average"))
cisss <- rbind(cisss, daily)
cisss <- cisss %>%
  filter(key != "") %>%
  arrange(table, key) %>%
  mutate(key = as.factor(key),
         table = as.factor(table))
rm(daily, cisss_tables, include)

### saving data
save(cisss, file = "_data/cisss.RData")
file_connection <- file("_data/data_update_time.txt")
writeLines(as.character(lubridate::now()), file_connection)
close(file_connection)

### other data sources
source("_R/data_schools.R")
source("_R/data_hospitalization.R")
hospitalization <- hospitalization %>%
  mutate(key = as.character(key),
         table = "MSSS")
source("_R/data_inspq.R")
inspq <- inspq %>%
  mutate(key = as.character(key),
         table = "INSPQ")
source("_R/data_rls.R")
rls <- rls %>%
  mutate(key = as.character(key),
         table = as.character(table),
         table = paste("INSPQ RLS", table))
cisss <- cisss %>%
  mutate(key = as.character(key),
         table = as.character(table),
         table = paste("CISSS", table),
         table = str_replace(table, "CISSS opencovid", "OpenCovid"))

### combining datasets (keep schools in separate df)
outaouais <- list(
  inspq = inspq,
  rls = rls,
  hospitalization = hospitalization,
  cisss = cisss
)
outaouais <- lapply(outaouais, function(df) {df[, c("key", "time", "value", "table")]})
outaouais <- do.call(rbind, outaouais)
# outaouais %>% select(key, table) %>% unique() %>% arrange(table) %>% print(n= Inf)
# table(outaouais$table, useNA = "always")
outaouais <- outaouais %>%
  arrange(key, date) %>%
  # filter(!(str_detect(key, "RLS") & table %in% c("CISSS active", "CISSS active average", "CISSS cases", "CISSS cases average"))) %>%
  mutate(key = as.factor(key),
         table = as.factor(table))
object.size(outaouais)
dim(outaouais)
save(outaouais, file = "_data/covid19Outaouais.RData")
# write_feather(outaouais, path = "_data/covid19Outaouais.feather")
