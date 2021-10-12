hospitalization <- readr::read_csv("_csv/msss_hosp_rss/COVID19_Qc_HistoHospit.csv")
hospitalization <- hospitalization %>%
  select(Date, ACT_Hsi_RSS07, ACT_Si_RSS07) %>%
  mutate(Date = lubridate::as_date(Date, format = "%m/%d/%Y"),
         time = lubridate::as_datetime(Date + 5/24, tz = "EST"))
indicators <- c(ACT_Hsi_RSS07 = "Active hospitalizations, non-ICU",
                ACT_Si_RSS07 = "Active hospitalizations, ICU")
hospitalization <- lapply(names(indicators), function(var) {
  df <- hospitalization[, c("Date", "time", var)]
  names(df) <- c("date", "time", "value")
  df$key <- indicators[var]
  return(df[, c("key", "date", "time", "value")])
})
hospitalization <- do.call(rbind, hospitalization)
hospitalization <- hospitalization %>%
  arrange(key, time) %>%
  mutate(table = "hospitalization") %>%
  select(key, date, time, value, table)
save(hospitalization, file = "_data/hospitalization.RData")
rm(indicators)
