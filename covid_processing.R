library("tidyverse")
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

### missing labels
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
# cisss[cisss$key == "", ]

### active cases column
table(cisss$key[!is.na(cisss$active)])
to_add <- cisss %>%
  filter(!is.na(active)) %>%
  mutate(value = active,
         table = paste(table, "active", sep = "_")) %>%
  select(-active)
cisss <- cisss %>%
  select(-active)
cisss <- rbind(cisss, to_add)

### checks on labels
# load("_data/municipalities.RData")
# unique(municipalities$municipality)[!unique(municipalities$municipality) %in% unique(cisss$key)]
# unique(cisss$key)[!unique(cisss$key) %in% unique(municipalities$municipality)]
# unique(cisss$key)[str_detect(unique(cisss$key), "MRC")]
# unique(municipalities$mrc)[!unique(municipalities$mrc) %in% unique(cisss$key)]

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
cisss <- cisss %>%
  arrange(time, key, table)

### error checking & corrections
### checks & fix extreme values that are likely due to input error
# check <- unique(cisss$key)[unique(cisss$key) %in% municipalities$municipality[municipalities$mrc == "Papineau"]]
# cisss[cisss$key == "" & cisss$time > "2020-09-28" & cisss$time < "2020-10-02", ]
# as.data.frame(cisss[cisss$key %in% c("", "Montpellier") & cisss$time >= "2021-03-10" & cisss$time <= "2021-03-19", ])
cisss$key[cisss$key == "" & cisss$time >= "2021-03-10" & cisss$time <= "2021-03-19" & cisss$table == "areas"] <- "Montpellier"
# VisualCheck(keys = c("Montpellier"), tab = "areas")
# vars <- tapply(cisss$key, cisss$table, unique)[["cases"]]
# vars <- vars[vars != "Healed/resolved cases"]
cisss <- cisss[!(cisss$key == "Healed/resolved cases" & cisss$time > "2020-10-31" & cisss$time < "2020-11-03" & cisss$value == 281), ]
# VisualCheck(keys = "Healed/resolved cases", tab = "cases")
# as.data.frame(cisss[cisss$key == "Total cases (Outaouais)" & cisss$time >= "2021-08-06" & cisss$time <= "2021-08-10", ])
cisss$value[cisss$time > "2021-08-06" & cisss$time < "2021-08-10" & cisss$key == "Total cases (Outaouais)" & cisss$value == 1262] <- 12620
# VisualCheck(keys = "Total cases (Outaouais)", tab = "cases")
# vars <- vars[vars != "Total cases (Outaouais)"]
# VisualCheck(keys = tapply(cisss$key, cisss$table, unique)[["cases"]], tab = "cases", exclude = c("Healed/resolved cases", "Cumulative cases"))
cisss$value[cisss$time > "2020-05-23" & cisss$time < "2020-05-25" & cisss$key == "Total cases (RLS)" & cisss$value == 4729] <- 479
cisss$value[cisss$time > "2020-06-24" & cisss$time < "2020-06-25" & cisss$key == "RLS de Gatineau" & cisss$value == 47] <- 497
cisss <- cisss[!(cisss$time > "2020-12-15" & cisss$time < "2020-12-16" & cisss$key == "RLS de Gatineau" & cisss$value == 32172), ]
# VisualCheck(keys = tapply(cisss$key, cisss$table, unique)[["rls"]], tab = "rls")
# VisualCheck(keys = c("Total cases", "Total cases (RLS)", "Total", "RLS de Gatineau"), tab = "rls")
# VisualCheck(keys = c("Total deaths", "To be determined", "To be determined (active)"), tab = "rls")
# VisualCheck(keys = c("Active cases", "Total cases (active)", "Healed/resolved cases"), tab = "rls")
# as.data.frame(cisss[cisss$key == "RLS de Gatineau" & cisss$table == "rls" & cisss$time >= "2021-09-25" & cisss$value == 1004, ])
cisss <- cisss[!(cisss$key == "RLS de Gatineau" & cisss$table == "rls" & cisss$time >= "2021-09-25" & cisss$value == 1004), ]
# VisualCheck(keys = c("RLS de Gatineau", "RLS de Gatineau (active)"), tab = "rls")
# as.data.frame(cisss[cisss$key == "RLS de Gatineau" & cisss$table == "rls_active" & cisss$time >= "2021-04-10" & cisss$time <= "2021-04-14", ])
cisss$value[cisss$time > "2021-04-10" & cisss$time < "2021-04-14" & cisss$key == "RLS de Gatineau" & cisss$value == 63] <- 637
# VisualCheck(keys = c("RLS de Gatineau", "RLS de Gatineau (active)"), tab = "rls_active")
# VisualCheck(keys = c("RLS de Papineau", "RLS de Papineau (active)"), tab = "rls")
cisss <- cisss[!(cisss$time > "2021-01-06" & cisss$time < "2021-01-07" & cisss$key == "RLS du Pontiac" & cisss$value == 0), ]
# VisualCheck(keys = c("RLS du Pontiac", "RLS du Pontiac (active)"), tab = "rls")
# VisualCheck(keys = c("RLS des Collines-de-l'Outaouais", "RLS des Collines-de-l'Outaouais (active)"), tab = "rls")
# VisualCheck(keys = c("RLS de la Vallée-de-la-Gatineau", "RLS de la Vallée-de-la-Gatineau (active)"), tab = "rls")
# VisualCheck(keys = c("Hospitalizations", "Hospitalizations, ICU"), tab = "cases")
# VisualCheck(keys = c("Total cases", "Total", "Gatineau", "Total cases (municipalities)"), tab = "areas")
cisss$value[cisss$time > "2020-05-09" & cisss$time < "2020-05-11" & cisss$key %in% c("Total", "Total cases", "Total cases (municipalities)") & cisss$value == 3334] <- 334
# as.data.frame(cisss[cisss$key == "Gatineau" & cisss$table == "areas" & cisss$time >= "2021-05-01" & cisss$time <= "2021-06-01", ])
cisss$value[cisss$time > "2021-05-10" & cisss$time < "2021-05-14" & cisss$key == "Gatineau" & cisss$value == 936] <- 9360
# VisualCheck(keys = "Gatineau", tab = "areas")
# VisualCheck(keys = tapply(cisss$key, cisss$table, unique)[["areas"]], tab = "areas")
# VisualCheck(keys = tapply(cisss$key, cisss$table, unique)[["areas"]], tab = "areas", exclude = c("Total", "Total cases", "Gatineau", "To be determined", "Total cases (municipalities)"))

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
opencovid <- opencovid %>%
  mutate(table = "opencovid.ca",
         key = paste(key, " (", health_region, ")", sep = "")) %>%
  select(-health_region)
cisss <- rbind(cisss, opencovid)

### de-duplication and calculating change variables
exclude <- c(municipalities$municipality,
             "", "Average screening tests per day", "To be determined", "To be determined",
             "Daily increase", "Healed/resolved cases",
             "New cases (Ottawa)", "New cases (Outaouais)", "New cases (Toronto)",
             "New deaths (Ottawa)", "New deaths (Outaouais)", "New deaths (Toronto)",
             "Total deaths", "Total deaths (Ottawa)", "Total deaths (Outaouais)", "Total deaths (Toronto)",
             "Hospital employees affected", "Hospital employees currently positive",
             "Hospital employees in isolation", "Hospital employees recovered",
             "Facilities with active outbreaks", "Facilities with outbreaks",
             "Active outbreaks", "Ended outbreaks")
daily <- cisss %>%
  filter(!key %in% exclude) %>%
  arrange(key, time) %>%
  mutate(date = lubridate::as_date(time)) %>%
  group_by(table, key, date) %>%
  filter(time == max(time))
# daily[duplicated(daily[, c("table", "key", "date")]), ]
# daily %>% filter(key %in% c("Total", "Total cases", "Cumulative cases")) %>% arrange(time) %>% print(n = Inf)
## these are closely related and often the same but different aggregation:
## cumulative for entire region, total aggregation across RLS or MRC
## "Total"/"Total cases (RLS)" sometimes different for RLS and municipalities
daily$table[daily$key %in% c("Total deaths", "Healed/resolved cases", "Active cases") & daily$table %in% c("rls", "areas")] <- "cases"
daily <- daily %>%
  select(table, key, date, value)
  arrange(table, key, date) %>%
  group_by(table, key) %>%
  mutate(previous_date = dplyr::lag(date),
         days_from_prev = as.integer(date - previous_date),
         previous_value = dplyr::lag(value),
         change_from_prev = value - previous_value,
         daily_change = round(change_from_prev / days_from_prev, 3)) %>%
  select(-previous_date, -previous_value) %>%
  mutate(value = runner::mean_run(x = daily_change, k = 7, lag = 0, idx = date)) %>%
  ungroup()
# sort(unique(unlist(tapply(daily$key, daily$table, unique))))
daily$key <- str_replace(daily$key, "Total cases", "Average increase per day")
daily$key <- str_replace(daily$key, "Active cases", "Average increase in active cases per day")

### time since previous
cisss <- cisss %>%
  arrange(table, key, time) %>%
  group_by(table, key) %>%
  mutate(previous_time = dplyr::lag(time),
         prev = round(difftime(time, previous_time, units = "days"), 1)) %>%
  select(table, time, prev, key, value)
# tapply(cisss$key, cisss$table, unique)

### saving data
save(cisss, file = "_data/cisss.RData")
save(daily, file = "_data/cisss_daily.RData")
file_connection <- file("_data/data_update_time.txt")
writeLines(as.character(lubridate::now()), file_connection)
close(file_connection)

source("_R/data_schools.R")
source("_R/data_hospitalization.R")
source("_R/data_vaccination.R")
source("_R/data_rls.R")
source("_R/data_inspq.R")
