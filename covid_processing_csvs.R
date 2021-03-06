library("tidyverse")
library("parallel")
Sys.setlocale(category = "LC_ALL", locale = "en_CA.UTF-8")

source("covid_datasets.R")
# unlist(lapply(datasets, function(item) paste("_csv/", item$path, item$file_name, sep = "")))

### hospitalization
hospitalization <- readr::read_csv("_csv/msss_hosp_rss/COVID19_Qc_HistoHospit.csv")
hospitalization <- hospitalization[, c("Date", "ACT_Hsi_RSS07", "ACT_Si_RSS07")]
hospitalization$Date <- lubridate::as_date(hospitalization$Date, format = "%m/%d/%Y")
indicators <- c(ACT_Hsi_RSS07 = "Active hospitalizations, non-ICU", ACT_Si_RSS07 = "Active hospitalizations, ICU")
hospitalization <- lapply(names(indicators), function(var) {
  df <- hospitalization[, c("Date", var)]
  names(df) <- c("date", "value")
  df$key <- indicators[var]
  return(df[, c("key", "date", "value")])
})
hospitalization <- do.call(rbind, hospitalization)
hospitalization <- hospitalization %>% arrange(key, date)
save(hospitalization, file = "_data/hospitalization.RData")

### vaccination
vaccination <- mclapply(dir("_csv/vaccine_doses/"), function(file) {
  df <- readr::read_delim(paste("_csv/vaccine_doses/", file, sep = ""), delim = ";")
  names(df) <- c("key", "value")
  time <- file
  time <- stringr::str_replace(time, "doses-vaccins_", "")
  time <- stringr::str_replace(time, ".csv", "")
  if(nchar(time) == 16) df$time <- lubridate::as_datetime(time, tz = "America/Montreal", format = "%Y-%m-%d_%H-%M")
  if(nchar(time) == 19) df$time <- lubridate::as_datetime(time, tz = "America/Montreal", format = "%Y-%m-%d-%H-%M-%S")
  return(df)
})
vaccination <- do.call(rbind, vaccination)
vaccination$value <- stringr::str_replace(vaccination$value, fixed(" "), "")
vaccination$value <- as.integer(vaccination$value)
# vaccination$code <- as.integer(stringr::str_sub(vaccination$key, 1, 2))
# vaccination$code[is.na(vaccination$code)] <- stringr::str_sub(vaccination$key[is.na(vaccination$code)], 1, 1)
vaccination$region_code <- stringr::str_sub(vaccination$key, 1, 2)
vaccination <- vaccination %>% arrange(region_code)
vaccination$key <- do.call(rbind, lapply(unique(vaccination$region_code), function(no) {
  set <- vaccination[vaccination$region_code == no, c("region_code", "key")]
  set$key <- names(which(table(set$key) == max(table(set$key))))[1]
  return(set)
}))$key
vaccination$key <- stringr::str_replace(vaccination$key, fixed(" – "), " - ")
vaccination$key <- stringr::str_replace(vaccination$key, fixed("-   "), " - ")
vaccination$region_code <- as.integer(vaccination$region_code)
stringr::str_sub(vaccination$key[!is.na(vaccination$region_code)], 1, 5) <-""
# vaccination[, c("region_code", "key")] %>% arrange(region_code) %>% unique() %>% print(n = Inf)
vaccination <- vaccination %>% arrange(key, time)
vaccination <- vaccination[vaccination$key == "Outaouais", c("time", "key", "value")]
vaccination$key <- "Total vaccine doses administered (Outaouais)"
save(vaccination, file = "_data/vaccination.RData")

### school listings
schools <- mclapply(dir("_csv/schools_list/"), function(file) {
  df <- readr::read_delim(paste("_csv/schools_list/", file, sep = ""), delim = ";")
  df <- df[, c("Régions", "Centres de services scolaires/Commissions scolaires/Écoles privées", "Écoles", "Particularités")]
  names(df) <- c("region", "admin", "school", "code")
  time <- file
  time <- stringr::str_replace(time, "Liste_ecole_DCOM_", "")
  time <- stringr::str_replace(time, ".csv", "")
  if(nchar(time) == 16) df$time <- lubridate::as_datetime(time, tz = "America/Montreal", format = "%Y-%m-%d_%H-%M")
  if(nchar(time) == 19) df$time <- lubridate::as_datetime(time, tz = "America/Montreal", format = "%Y-%m-%d-%H-%M-%S")
  return(df)
})
schools <- do.call(rbind, schools)
schools$region_code <- stringr::str_sub(schools$region, 2, 3)
schools$region <- stringr::str_trim(schools$region)
schools$admin <- stringr::str_trim(schools$admin)
stringr::str_sub(schools$region, 1, 5) <- ""
schools$relisted <- stringr::str_detect(schools$school, stringr::fixed("*"))
schools$school <- stringr::str_replace(schools$school, stringr::fixed("*"), "")
schools$note[is.na(schools$code)] <- "previously listed"
schools$note[schools$code == 1] <- "reaffected previously listed" # "already on list, with new confirmed case(s) [pink]"
schools$note[schools$code == 2] <- "relisted newly affected" # "relisted due to new confirmed case(s) [green*]"
schools$note[schools$code == 3] <- "newly listed" # "new listing due to new confirmed case(s) [green]"
# table(schools$note, schools$relisted)
schools$color_code[is.na(schools$code)] <- ""
schools$color_code[schools$code == 1] <- "pink" # "already on list, with new confirmed case(s) [pink]"
schools$color_code[schools$code == 2] <- "green*" # "relisted due to new confirmed case(s) [green*]"
schools$color_code[schools$code == 3] <- "green" # "new listing due to new confirmed case(s) [green]"
schools <- schools[schools$region == "Outaouais", c("admin", "time", "school", "note", "color_code")]
schools <- schools %>% group_by(admin, school) %>% arrange(admin, school, time)
schools <- schools[!(is.na(schools$admin) & is.na(schools$school)), ]
schools$date <- lubridate::as_date(schools$time)
schools <- schools %>% group_by(admin, school, date) %>% filter(time == min(time))
schools <-schools[, c("admin", "school","date", "note", "color_code")]
# schools <- schools %>% group_by(admin, school) %>% arrange(admin, school, date)
# table(schools[, c("note", "color_code")])
# tapply(schools$school, schools$admin, function(x) length(unique(x)))
schools$admin[schools$admin == "Centre de services scolaire au C\u009cur-des-Vallées"] <- "Centre de services scolaire au Cœur-des-Vallées"
schools$school <- str_replace(schools$school, "Sacré-C\u009cur", "Sacré-Cœur")
schools$school <- str_replace(schools$school,
                              "École Cité Étudiante de la Haute-Gatineau",
                              "École Cité Étudiante\nde la Haute-Gatineau")
schools$school <- str_replace(schools$school,
                              "Centre d'éducation des adultes Portages-de-l'Outaouais",
                              "Centre d'éducation des adultes")
schools$school <- str_replace(schools$school,
                              "Centre d'éducation des Adultes, programme FIS maison amitié de Maniwaki",
                              "Centre d'éducation des Adultes,\nprogramme FIS maison\namitié de Maniwaki")
board <- "Centre de services scolaire des Hauts-Bois-de-l'Outaouais"
schools$school[schools$admin == board] <-
  str_replace(schools$school[schools$admin == board], fixed(", "), ",\n")
schools$school <- str_replace(schools$school,
                              "Service régional de la formation professionnelle et du service aux entreprises Réseautact",
                              "SRFP Réseautact")
# unique(schools$school[str_detect(schools$school, "Vision-Avenir")])
schools$school <- str_replace(schools$school,
                              "Centre Vision-Avenir",
                              "Centre de formation professionnelle Vision-Avenir")
schools$school <- str_replace(schools$school, "École", "É.")
schools$school <- str_replace(schools$school, "école", "É.")
schools$school <- str_replace(schools$school, "School", "S.")
schools$school <- str_replace(schools$school, "Shcool", "S.")
schools$school <- str_replace(schools$school, "Education", "Ed.")
schools$school <- str_replace(schools$school, "Éducation", "Éd.")
schools$school <- str_replace(schools$school, "éducation", "Éd.")
schools$school <- str_replace(schools$school,
                              "Centre de formation professionnelle des métiers",
                              "CFP")
schools$school <- str_replace(schools$school,
                              "Centre de formation professionnelle",
                              "CFP")
schools$school <- str_replace(schools$school, "Centre", "C.")
schools$school <- str_replace(schools$school, " de l'Outaouais", "\nde l'Outaouais")
schools$school <- str_replace(schools$school, "Collège ", "Collège\n")
schools$school <- str_replace(schools$school, ", pavillon ", ", ")
schools$school <- str_replace(schools$school, fixed(" ("), "\n(")
schools$school <- str_trim(schools$school)
# unique(schools$school[nchar(schools$school) > quantile(nchar(schools$school), probs = seq(0, 1, 0.05)[20])])
# unique(schools$school)
# unique(schools$school[str_detect(schools$school, "blah")])
schools <- schools %>% arrange(admin, school, date)
schools$admin[schools$admin == "Centre de services scolaire au C\u009cur-des-Vallées"] <- "Centre de services scolaire au Cœur-des-Vallées"
schools$school <- str_replace(schools$school,
                              "École Cité Étudiante de la Haute-Gatineau",
                              "École Cité Étudiante\nde la Haute-Gatineau")
schools$school <- str_replace(schools$school,
                              "Centre d'éducation des adultes Portages-de-l'Outaouais",
                              "Centre d'éducation des adultes")
# schools$school <- str_replace(schools$school,
# "École Cœur de la Gatineau, pavillon St-Nom-de-Marie",
# "École Cœur de la Gatineau, pavillon St-Nom-de-Marie")
schools$school <- str_replace(schools$school,
                              "Centre d'éducation des Adultes, programme FIS maison amitié de Maniwaki",
                              "Centre d'éducation des Adultes,\nprogramme FIS maison\namitié de Maniwaki")
schools$school <- str_replace(schools$school, "École", "É.")
schools$school <- str_replace(schools$school, "école", "É.")
schools$school <- str_replace(schools$school, "School", "S.")
schools$school <- str_replace(schools$school, "Shcool", "S.")
schools$school <- str_replace(schools$school, "Education", "Ed.")
schools$school <- str_replace(schools$school, "Éducation", "Éd.")
schools$school <- str_replace(schools$school, "éducation", "Éd.")
schools$school <- str_replace(schools$school,
                              "Centre de formation professionnelle des métiers",
                              "CFP")
schools$school <- str_replace(schools$school,
                              "Centre de formation professionnelle",
                              "CFP")
schools$school <- str_replace(schools$school, "Centre", "C.")
schools$school <- str_replace(schools$school, " de l'Outaouais", "\nde l'Outaouais")
schools$school <- str_replace(schools$school, "Collège ", "Collège\n")
schools$school <- str_replace(schools$school, ", pavillon ", ", ")
schools$school <- str_replace(schools$school,
                              "Service régional de la formation professionnelle et du service aux entreprises Réseautact",
                              "SRFP Réseautact")
board <- "Centre de services scolaire des Hauts-Bois-de-l'Outaouais"
schools$school[schools$admin == board] <-
  str_replace(schools$school[schools$admin == board], fixed(", "), ",\n")
schools$school <- str_replace(schools$school, fixed(" ("), "\n(")
schools$school <- str_trim(schools$school)
# unique(schools$school[str_detect(schools$school, "blah")])
# tapply(schools$school, schools$admin, function(x) length(unique(x)))
# table(schools[, c("note", "color_code")])
# unique(schools$school)
# unique(schools$school[nchar(schools$school) > quantile(nchar(schools$school), probs = seq(0, 1, 0.05)[20])])
save(schools, file = "_data/schools.RData")

### mobility snapshots
# mobility <- lapply(dir("_csv/mobility/"), function(file) {
#   readr::read_csv(paste("_csv/mobility/", file, sep = ""))
# })
# mobility <- do.call(rbind, mobility)
# table(mobility$health_care_region)

### RLS
rls <- mclapply(dir("_csv/inspq_rss_rls/"), function(file) {
  df <- readr::read_csv(paste("_csv/inspq_rss_rls/", file, sep = ""))
  if(!"Cas actifs" %in% names(df)) df$'Cas actifs' <- NA
  time <- file
  time <- stringr::str_replace(time, "tableau-rls-new_", "")
  time <- stringr::str_replace(time, "tableau-rls_", "")
  time <- stringr::str_replace(time, ".csv", "")
  if(nchar(time) == 16) df$time <- lubridate::as_datetime(time, tz = "America/Montreal", format = "%Y-%m-%d_%H-%M")
  if(nchar(time) == 19) df$time <- lubridate::as_datetime(time, tz = "America/Montreal", format = "%Y-%m-%d-%H-%M-%S")
  return(df[, c("time", "No", "RSS", "NoRLS", "RLS", "Cas", "Cas actifs", "Population")])
})
rls <- do.call(rbind, rls)
rls[, c("Cas", "Cas actifs", "Population")] <- lapply(rls[, c("Cas", "Cas actifs", "Population")], function(col) {
  col[col == "n.d."] <- NA
  col <- str_trim(col)
  col <- str_replace(col, " ", "")
  col <- as.numeric(col)
  return(col)
})
names(rls) <- c("time","rss_no", "rss", "rls_no", "rls", "cases", "active", "pop")
rls$rss_no <- as.integer(rls$rss_no)
rls$rls_no <- as.integer(rls$rls_no)
rls$rss <- unlist(tapply(rls$rss, rls$rss_no, function(group) names(which(table(group) == max(table(group))))[1], simplify = FALSE), use.names = FALSE)[rls$rss_no]
# unique(rls[is.na(rls$rls_no), c("rls_no", "rls")])
rls$rls_no[is.na(rls$rls_no)] <- as.integer(0)
rls <- rls %>% arrange(rls_no)
rls$rls <- do.call(rbind, lapply(unique(rls$rls_no), function(no) {
  set <- rls[rls$rls_no == no, c("rls_no", "rls")]
  set$rls <- names(which(table(set$rls) == max(table(set$rls))))[1]
  return(set)
}))$rls
rls$rss <- stringr::str_sub(rls$rss, 6, nchar(rls$rss))
rls$rls[rls$rls != "Total"] <- unlist(lapply(stringr::str_split(rls$rls[rls$rls != "Total"], fixed(" - ")), function(set) paste(set[-1], collapse = " - ")))
# print(unique(rls[order(rls$rls_no), c("rss_no", "rss", "rls_no", "rls")]), n = Inf)
rls <- rls[rls$rss == "Outaouais", c("time", "rls", "cases", "active", "pop")]
rls$rls <- str_replace(rls$rls, "Total", "Total cases (Outaouais)")
rls <- lapply(c("cases", "active", "pop"), function(var) {
  df <- rls[, c("time", "rls", var)]
  names(df) <- c("time", "key", "value")
  df$table <- var
  if(var == "active") df$key <- str_replace(df$key, "Total", "Active")
  if(var == "pop") df$key <- str_replace(df$key, "Total cases", "Population")
  return(df)
})
rls <- do.call(rbind, rls)
rls <- rls[!is.na(rls$value), ]
avg <- rls[rls$table == "cases", ]
avg <- avg %>% arrange(key, time)
avg$date <- lubridate::as_date(avg$time)
avg <- avg %>% group_by(key, date) %>% filter(time == max(time))
avg <- avg %>% arrange(key, date) %>% group_by(key) %>% mutate(previous_date = dplyr::lag(date))
avg <- avg %>% mutate(days_from_prev = as.integer(date - previous_date))
avg <- avg %>% arrange(key, date) %>% group_by(key) %>% mutate(previous_value = dplyr::lag(value))
avg <- avg %>% mutate(new_cases = value - previous_value)
avg <- avg %>% mutate(avg_change = round(new_cases / days_from_prev, 3))
avg <- avg %>% arrange(key, date) %>% group_by(key) %>% mutate(avg_change_avg = runner::mean_run(x = avg_change, k = 7, lag = 0, idx = date)) %>% ungroup()
avg <- avg[, c("time", "key", "value", "table", "new_cases", "avg_change_avg")]
names(avg) <- c("time", "key", "value", "table", "new", "average")
avg <- lapply(c("new", "average"), function(var) {
  df <- avg[, c("time", "key", var, "table")]
  names(df) <- c("time", "key", "value", "table")
  df$table <- var
  if(var == "new") df$key <- str_replace(df$key, "Total", "New")
  if(var == "average") df$key <- str_replace(df$key, "Total cases", "Average increase per day")
  return(df)
})
avg <- do.call(rbind, avg)
rls <- rbind(rls, avg)
rls <- rls %>% arrange(key, time)
save(rls, file = "_data/rls.RData")

### complete historical case data
dictionary <- readr::read_csv("_data/inspq_dictionary.csv")
inspq <- readr::read_csv("_csv/inspq_hist/covid19-hist.csv")
inspq <- inspq[, names(inspq) %in% dictionary$key[dictionary$use == 1]]
# print(unique(inspq[, c("Nom", "Regroupement")]), n = Inf)
inspq <- inspq[inspq$Nom == "07 - Outaouais", ]
inspq$Nom <- inspq$Regroupement <- NULL
inspq$Date <-lubridate::as_date(inspq$Date, format = "%Y-%m-%d")
inspq <- inspq[!is.na(inspq$Date), ]
inspq <- lapply(names(inspq)[-1], function(var) {
  df <- inspq[, c("Date", var)]
  names(df) <- c("date", "value")
  df$value <- as.numeric(df$value)
  df$key <- dictionary$label[dictionary$key == var]
  df$table <- dictionary$category[dictionary$key == var]
  return(df[, c("key", "date", "value", "table")])
})
inspq <- do.call(rbind, inspq)
inspq <- inspq[!is.na(inspq$value), ]

### historical vaccination data
vaccination <- readr::read_csv("_csv/vaccination/vaccination.csv")
vaccination <- vaccination[, names(vaccination) %in% dictionary$key[dictionary$use == 1]]
vaccination <- vaccination[vaccination$Nom == "07 - Outaouais", ]
vaccination$Nom <- vaccination$Regroupement <- NULL
vaccination$Date <-lubridate::as_date(vaccination$Date, format = "%Y-%m-%d")
vaccination <- vaccination[!is.na(vaccination$Date), ]
vaccination <- lapply(names(vaccination)[-1], function(var) {
  df <- vaccination[, c("Date", var)]
  names(df) <- c("date", "value")
  df$value <- as.numeric(df$value)
  df$key <- dictionary$label[dictionary$key == var]
  df$table <- dictionary$category[dictionary$key == var]
  return(df[, c("key", "date", "value", "table")])
})
vaccination <- do.call(rbind, vaccination)
vaccination <- vaccination[!is.na(vaccination$value), ]
inspq <- rbind(inspq, vaccination)
to_calc <- c("New cases" = "Average increase per day",
             "New hospitalizations" = "Average hospitalizations per day",
             "New hospitalizations, non-ICU" = "Average hospitalizations (non-ICU) per day",
             "New hospitalizations, ICU" = "Average ICU hospitalizations per day",
             "Persons tested" = "Average testing per day",
             "Persons tested positive" = "Average positive tests per day",
             "Persons tested negative" = "Average negative tests per day",
             "Test positivity (%)" = "Average test positivity (%)",
             "Vaccine doses administered" = "Average vaccine doses administered")
avg <- lapply(names(to_calc), function(var) {
  df <- inspq[inspq$key == var, ]
  df <- df %>% arrange(date) %>% group_by(key) %>% mutate(value = runner::mean_run(x = value, k = 7, lag = 0, idx = date)) %>% ungroup()
  df$key <- to_calc[var]
  df$table <- "average"
  return(df)
})
avg <- do.call(rbind, avg)
inspq <- rbind(inspq, avg)
save(inspq, file = "_data/inspq.RData")
