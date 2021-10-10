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
save(inspq, file = "_data/inspq.RData")
