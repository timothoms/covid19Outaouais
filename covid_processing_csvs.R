library("tidyverse")
library("parallel")
Sys.setlocale(category = "LC_ALL", locale = "en_CA.UTF-8")

source("covid_datasets.R")
# unlist(lapply(csvs, function(item) paste("csv/", item$path, item$file_name, sep = "")))

### hospitalization
hospitalization <- readr::read_csv("csv/msss_hosp_rss/COVID19_Qc_HistoHospit.csv")
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
save(hospitalization, file = "data/hospitalization.RData")

### vaccination
vaccination <- mclapply(dir("csv/vaccine_doses/"), function(file) {
  df <- readr::read_delim(paste("csv/vaccine_doses/", file, sep = ""), delim = ";")
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
save(vaccination, file = "data/vaccination.RData")

### school listings
schools <- mclapply(dir("csv/schools_list/"), function(file) {
  df <- readr::read_delim(paste("csv/schools_list/", file, sep = ""), delim = ";")
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
schools$note[schools$code == 1] <- "reaffected listed school (pink)" # "already on list, with new confirmed case(s) [pink]"
schools$note[schools$code == 2] <- "relisted newly affected school (green*)" # "relisted due to new confirmed case(s) [green*]"
schools$note[schools$code == 3] <- "newly listed school (green)" # "new listing due to new confirmed case(s) [green]"
# table(schools$note, schools$relisted)
schools <- schools %>% arrange(region, admin, school, time)
schools <- schools[schools$region == "Outaouais", c("time", "region", "admin", "school", "code", "note")]
save(schools, file = "data/schools.RData")

### mobility snapshots
# mobility <- lapply(dir("csv/mobility/"), function(file) {
#   readr::read_csv(paste("csv/mobility/", file, sep = ""))
# })
# mobility <- do.call(rbind, mobility)
# table(mobility$health_care_region)

### RLS
rls <- mclapply(dir("csv/inspq_rss_rls/"), function(file) {
  df <- readr::read_csv(paste("csv/inspq_rss_rls/", file, sep = ""))
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
save(rls, file = "data/rls.RData")

### complete historical case data
dictionary <- readr::read_csv("data/inspq_dictionary.csv")
inspq <- readr::read_csv("csv/inspq_hist/covid19-hist.csv")
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
vaccination <- readr::read_csv("csv/vaccination/vaccination.csv")
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
avg <- inspq[inspq$key %in% c("New cases"), ]
avg <- avg %>% arrange(date) %>% group_by(key) %>% mutate(value = runner::mean_run(x = value, k = 7, lag = 0, idx = date)) %>% ungroup()
avg$key <- "Average increase per day"
avg$table <- "average"
inspq <- rbind(inspq, avg)
save(inspq, file = "data/inspq.RData")
