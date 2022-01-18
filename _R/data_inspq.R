dictionary <- readr::read_csv("_data/inspq_dictionary.csv")
### vaccination data
inspq_vac <- readr::read_csv("_csv/vaccination/vaccination.csv")
inspq_vac <- inspq_vac[inspq_vac$Nom == "07 - Outaouais", names(inspq_vac) %in% dictionary$key[dictionary$use == 1]]
inspq_vac <- inspq_vac %>%
  select(-Regroupement, -Nom) %>%
  mutate(Date = lubridate::as_date(Date, format = "%Y-%m-%d"))
inspq_vac <- lapply(names(inspq_vac)[-1], function(var) {
  df <- inspq_vac[, c("Date", var)]
  names(df) <- c("date", "value")
  df$value <- as.numeric(df$value)
  df$key <- dictionary$label[dictionary$key == var]
  df$table <- dictionary$category[dictionary$key == var]
  df <- df[!is.na(df$value), c("key", "date", "value", "table")]
  return(df)
})
inspq_vac <- do.call(rbind, inspq_vac)

### other inspq data
inspq <- readr::read_csv("_csv/inspq_hist/covid19-hist.csv")
inspq <- inspq[inspq$Nom == "07 - Outaouais", names(inspq) %in% dictionary$key[dictionary$use == 1]]
inspq <- inspq %>%
  select(-Regroupement, -Nom) %>%
  mutate(Date = lubridate::as_date(Date, format = "%Y-%m-%d")) %>%
  filter(!is.na(Date))
inspq <- lapply(names(inspq)[-1], function(var) {
  df <- inspq[, c("Date", var)]
  names(df) <- c("date", "value")
  df$value <- as.numeric(df$value)
  df$key <- dictionary$label[dictionary$key == var]
  df$table <- dictionary$category[dictionary$key == var]
  df <- df[!is.na(df$value), c("key", "date", "value", "table")]
  return(df)
})
inspq <- do.call(rbind, inspq)
inspq <- rbind(inspq, inspq_vac)

### averages per day
to_calc <- c("New cases"                     = "Average increase in cases per day",
             "New hospitalizations"          = "Average hospitalizations per day",
             "New hospitalizations, non-ICU" = "Average non-ICU hospitalizations per day",
             "New hospitalizations, ICU"     = "Average ICU hospitalizations per day",
             "Persons tested"                = "Average testing per day",
             "Persons tested positive"       = "Average positive tests per day",
             "Persons tested negative"       = "Average negative tests per day",
             "Test positivity (%)"           = "Average test positivity (%)",
             "Vaccine doses administered"    = "Average vaccine doses administered")
avg <- lapply(names(to_calc), function(var) {
  df <- inspq[inspq$key == var, ] %>%
    arrange(date) %>%
    group_by(key) %>%
    mutate(value = runner::mean_run(x = value, k = 7, lag = 0, idx = date)) %>%
    ungroup()
  df$key <- to_calc[var]
  df$table <- "average"
  return(df)
})
avg <- do.call(rbind, avg)
inspq <- rbind(inspq, avg)
inspq <- inspq %>%
  mutate(time = lubridate::as_datetime(date + 5/24, tz = "EST"),
         key = as.factor(key),
         table = as.factor(table)) %>%
  select(key, date, time, value, table)
rm(inspq_vac, avg, to_calc)
save(inspq, file = "_data/inspq.RData")
