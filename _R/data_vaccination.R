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
