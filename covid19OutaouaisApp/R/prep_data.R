require(tidyverse)
require(lubridate)

# library(feather)
# info <- read_feather(path = "../_data/info.feather")
# outaouais <- read_feather(path = "../_data/covid19Outaouais.feather")

load(url("https://github.com/timothoms/covid19Outaouais/raw/main/_data/covid19Outaouais.RData"), verbose = TRUE)
load(url("https://github.com/timothoms/covid19Outaouais/raw/main/_data/info.RData"), verbose = TRUE)
# outaouais %>% select(key, table) %>% arrange(key) %>% unique() %>% print(n = Inf)

pop <- outaouais %>%
  filter(table == "INSPQ RLS pop")

outaouais <- outaouais %>%
  filter(table != "INSPQ RLS pop")

lookup <- outaouais %>%
  select(key, table) %>%
  unique() %>%
  arrange(key) %>%
  left_join(info %>%
              select(outaouais_table, source, source_link) %>%
              rename(table = outaouais_table) %>%
              unique(),
            by = "table") %>%
  mutate(series = paste(key, " [", table, "]", sep = ""))
# lookup %>% select(key, table) %>% filter(key %in% names(table(lookup$key)[table(lookup$key) > 1])) %>% print(n = Inf)

outaouais <- outaouais %>%
  left_join(lookup, by = c("key", "table")) %>%
  select(series, table, time, value) %>%
  rename(key = series)
