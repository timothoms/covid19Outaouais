# cisss %>% filter(table %in% c("areas", "rls"))
# municipalities %>% filter(mrc == ?) %>% select(municipality) %>% unlist(use.names = FALSE)
c("Les Collines-de-l'Outaouais",
  "Papineau",
  "La Vallée-de-la-Gatineau",
  "Pontiac",
  "Gatineau",
  "Total cases (municipalities)")

# inspq %>%
c(main = "Average increase per day", bars = "New cases")
c(main = "Average testing per day", bars = "Persons tested")
c(main = "Average test positivity (%)", bars = "Test positivity (%)")

# inspq %>%
c("Active cases",
  "Total cases",
  "Total recovered cases",
  "Total hospitalizations, non-ICU",
  "Total hospitalizations, ICU",
  "Total hospitalizations",
  "New hospitalizations",
  "Vaccine doses administered",
  "Total vaccine doses administered",
  "Total deaths",
  "Total deaths (CHSLD)",
  "Total deaths (RPA)",
  "Total deaths (home & unknown)",
  "Total deaths (other)")

# hospitalization %>%
c("Active hospitalizations, non-ICU",
  "Active hospitalizations, ICU")

# inspq %>% filter(table == "opencovid.ca")
c("Average increase per day (Outaouais)",
  "Average increase per day (Ottawa)")

# RLS: rls %>% filter(table == "average" | table == "active") %>%
c("Average increase per day (Outaouais)",
  "Active cases (Outaouais)",
  "RLS de Grande-Rivière - Hull - Gatineau","RLS des Collines-de-l'Outaouais",
  "RLS du Pontiac",
  "RLS de la Vallée-de-la-Lièvre et de la Petite Nation",
  "RLS de la Vallée-de-la-Gatineau")

# school districts: schools %>%
c("Centre de services scolaire des Draveurs",
  "Centre de services scolaire des Portages-de-l'Outaouais",
  "Commission scolaire Western Québec",
  "Centre de services scolaire au Cœur-des-Vallées",
  "Centre de services scolaire des Hauts-Bois-de-l'Outaouais",
  "École privée")
