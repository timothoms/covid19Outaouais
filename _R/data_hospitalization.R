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
