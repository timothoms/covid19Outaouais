rls <- parallel:: mclapply(dir("_csv/inspq_rss_rls/"), function(file) {
  df <- readr::read_csv(paste("_csv/inspq_rss_rls/", file, sep = ""))
  if(!"Cas actifs" %in% names(df)) df$'Cas actifs' <- NA
  time <- stringr::str_replace(file, "tableau-rls-new_", "")
  time <- stringr::str_replace(time, "tableau-rls_", "")
  time <- stringr::str_replace(time, ".csv", "")
  if(nchar(time) == 16) df$time <- lubridate::as_datetime(time, tz = "America/Montreal", format = "%Y-%m-%d_%H-%M")
  if(nchar(time) == 19) df$time <- lubridate::as_datetime(time, tz = "America/Montreal", format = "%Y-%m-%d-%H-%M-%S")
  df <- df %>% select("time", "No", "RSS", "NoRLS", "RLS", "Cas", "Cas actifs", "Population")
  return(df)
})
rls <- do.call(rbind, rls)
vars <- c("Cas", "Cas actifs", "Population")
rls[, vars] <- lapply(rls[, vars], function(col) {
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
rls <- rls %>%
  filter(rss == "Outaouais") %>%
  select(time, rls, cases, active, pop)
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
### 7-day average
avg <- rls %>%
  filter(table == "cases") %>%
  arrange(key, time) %>%
  mutate(date = lubridate::as_date(time)) %>%
  group_by(key, date) %>%
  filter(time == max(time)) %>%
  group_by(key) %>%
  mutate(previous_date = dplyr::lag(date),
         days_from_prev = as.integer(date - previous_date),
         previous_value = dplyr::lag(value),
         new_cases = value - previous_value,
         avg_change = round(new_cases / days_from_prev, 3),
         avg_change_avg = runner::mean_run(x = avg_change, k = 7, lag = 0, idx = date)) %>%
  select(time, key, value, table, new_cases, avg_change_avg) %>%
  ungroup()
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
rm(avg)
rls <- rls %>%
  select(key, time, value, table) %>%
  arrange(key, time)
save(rls, file = "_data/rls.RData")
