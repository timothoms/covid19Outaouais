library("tidyverse")
library("parallel")
Sys.setlocale(category = "LC_ALL", locale = "en_CA.UTF-8")
source("_R/data_hospitalization.R")
source("_R/data_vaccination.R")
source("_R/data_schools.R")
source("_R/data_rls.R")
source("_R/data_inspq.R")
source("_R/data_inspq_vaccination.R")

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
