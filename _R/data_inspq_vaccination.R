### historical vaccination data
dictionary <- readr::read_csv("_data/inspq_dictionary.csv")
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
save(vaccination, file = "_data/inspq_vaccination.RData")
