schools <- parallel::mclapply(dir("_csv/schools_list/"), function(file) {
  df <- readr::read_delim(paste("_csv/schools_list/", file, sep = ""), delim = ";")
  df <- df[, c("Régions", "Centres de services scolaires/Commissions scolaires/Écoles privées", "Écoles", "Particularités")]
  names(df) <- c("region", "admin", "school", "code")
  time <- stringr::str_replace(file, "Liste_ecole_DCOM_", "")
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
schools$note[is.na(schools$code)] <- "previously listed"
schools$note[schools$code == 1] <- "reaffected previously listed" # "already on list, with new confirmed case(s) [pink]"
schools$note[schools$code == 2] <- "relisted newly affected" # "relisted due to new confirmed case(s) [green*]"
schools$note[schools$code == 3] <- "newly listed" # "new listing due to new confirmed case(s) [green]"
# table(schools$note, schools$relisted)
schools$color_code[is.na(schools$code)] <- ""
schools$color_code[schools$code == 1] <- "pink" # "already on list, with new confirmed case(s) [pink]"
schools$color_code[schools$code == 2] <- "green*" # "relisted due to new confirmed case(s) [green*]"
schools$color_code[schools$code == 3] <- "green" # "new listing due to new confirmed case(s) [green]"
schools <- schools %>%
  filter(region == "Outaouais") %>%
  select(admin, time, school, note, color_code) %>%
  group_by(admin, school) %>%
  arrange(admin, school, time)
schools <- schools[!(is.na(schools$admin) & is.na(schools$school)), ]
schools$date <- lubridate::as_date(schools$time)
schools <- schools %>%
  group_by(admin, school, date) %>%
  filter(time == min(time)) %>%
  select(admin, school, date, note, color_code)
# table(schools[, c("note", "color_code")])
# tapply(schools$school, schools$admin, function(x) length(unique(x)))

### various spelling & encoding issues
schools$admin <- str_replace(schools$admin,
                             "Centre de services scolaire au C\u009cur-des-Vallées",
                             "Centre de services scolaire au Cœur-des-Vallées")
board <- "Centre de services scolaire des Hauts-Bois-de-l'Outaouais"
# schools$school[schools$admin == board] <- str_replace(schools$school[schools$admin == board], fixed(", "), ",\n")
schools$school <- str_replace(schools$school, "Sacré-C\u009cur", "Sacré-Cœur")
schools$school <- str_replace(schools$school,
                              "École Cité Étudiante de la Haute-Gatineau",
                              "École Cité Étudiante\nde la Haute-Gatineau")
schools$school <- str_replace(schools$school,
                              "Centre d'éducation des adultes Portages-de-l'Outaouais",
                              "Centre d'éducation des adultes")
schools$school <- str_replace(schools$school,
                              "Centre d'éducation des Adultes, programme FIS maison amitié de Maniwaki",
                              "Centre d'éducation des Adultes,\nprogramme FIS maison\namitié de Maniwaki")
schools$school <- str_replace(schools$school,
                              "Service régional de la formation professionnelle et du service aux entreprises Réseautact",
                              "SRFP Réseautact")
schools$school <- str_replace(schools$school,
                              "Centre Vision-Avenir",
                              "Centre de formation professionnelle Vision-Avenir")
schools$school <- str_replace(schools$school, "École", "É.")
schools$school <- str_replace(schools$school, "école", "É.")
schools$school <- str_replace(schools$school, "School", "S.")
schools$school <- str_replace(schools$school, "Shcool", "S.")
schools$school <- str_replace(schools$school, "Education", "Ed.")
schools$school <- str_replace(schools$school, "Éducation", "Éd.")
schools$school <- str_replace(schools$school, "éducation", "Éd.")
schools$school <- str_replace(schools$school,
                              "Centre de formation professionnelle des métiers",
                              "CFP")
schools$school <- str_replace(schools$school,
                              "Centre de formation professionnelle",
                              "CFP")
schools$school <- str_replace(schools$school, "Centre", "C.")
schools$school <- str_replace(schools$school, " de l'Outaouais", "\nde l'Outaouais")
schools$school <- str_replace(schools$school, "Collège ", "Collège\n")
schools$school <- str_replace(schools$school, ", pavillon ", ",\nPav. ")
schools$school <- str_replace(schools$school, ", Pavillon ", ",\nPav. ")
schools$school <- str_replace(schools$school, fixed(" (Pavillon "), "\n(Pav. ")
schools$school <- str_replace(schools$school, " Du ", " du ")
schools$school <- str_replace(schools$school, "Polyvalente Nicolas-Gatineau", "Polyvalente Nicolas Gatineau")
schools$school <- str_replace(schools$school, "Pierre Elliott Elementary S.", "Pierre Elliott Trudeau Elementary S.")
schools$school <- str_replace(schools$school, "C. L'Arrimage", "C. l'Arrimage")
schools$school <- str_replace(schools$school, "É. De l'Île", "É. secondaire de l'Île ")
schools$school <- str_replace(schools$school, "É. de l'Île", "É. secondaire de l'Île ")
schools$school <- str_replace(schools$school, "É. de la Rose-des-Vents", "É. de la Rose des Vents")
schools$school <- str_replace(schools$school, "É. du Petit Prince", "É. Le Petit Prince")
schools$school[schools$school == "D'Arcy McGee High S."] <- "É. D'Arcy McGee High S."
# table(schools$school)
# unique(schools$school[nchar(schools$school) > quantile(nchar(schools$school), probs = seq(0, 1, 0.05)[19])])
schools$school <- str_replace(schools$school, fixed(" ("), "\n(")
schools$school <- str_trim(schools$school)
schools <- schools %>% arrange(admin, school, date)
save(schools, file = "_data/schools.RData")
