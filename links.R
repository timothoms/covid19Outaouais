links <- list(
  local_sit_en       = "https://cisss-outaouais.gouv.qc.ca/language/en/covid19-en/",
  local_sit_fr       = "https://cisss-outaouais.gouv.qc.ca/covid-19/",
  local_sit_defunct  = "https://cisss-outaouais.gouv.qc.ca/language/en/18907-2/",
  qc_sit_en          = "https://www.quebec.ca/en/health/health-issues/a-z/2019-coronavirus/situation-coronavirus-in-quebec/",
  qc_sit_fr          = "https://www.quebec.ca/sante/problemes-de-sante/a-z/coronavirus-2019/situation-coronavirus-quebec/",
  qc_public_health   = "https://www.inspq.qc.ca/covid-19/donnees",
  qc_variants_fr     = "https://www.inspq.qc.ca/covid-19/donnees/variants",
  qc_vaccinations_en = "https://www.quebec.ca/en/health/health-issues/a-z/2019-coronavirus/situation-coronavirus-in-quebec/covid-19-vaccination-data/",
  qc_vaccinations_fr = "https://www.quebec.ca/sante/problemes-de-sante/a-z/coronavirus-2019/situation-coronavirus-quebec/donnees-sur-la-vaccination-covid-19/",
  schools_sit_en     = "https://www.quebec.ca/en/health/health-issues/a-z/2019-coronavirus/highlights-public-private-school-systems/",
  schools_sit_fr     = "https://www.quebec.ca/sante/problemes-de-sante/a-z/coronavirus-2019/faits-saillants-covid-ecoles/",
  qc_schools_list_en = "https://www.quebec.ca/en/health/health-issues/a-z/2019-coronavirus/list-schools-reporting-covid-19-cases/",
  qc_schools_list_fr = "https://www.quebec.ca/sante/problemes-de-sante/a-z/coronavirus-2019/liste-des-cas-de-covid-19-dans-les-ecoles/",
  qc_alert           = "https://www.quebec.ca/en/health/health-issues/a-z/2019-coronavirus/progressive-regional-alert-and-intervention-system/map-of-covid-19-alert-levels-by-region/",
  can_visual         = "https://health-infobase.canada.ca/covid-19/",
  can_data           = "https://www.canada.ca/en/public-health/services/diseases/coronavirus-disease-covid-19/epidemiological-economic-research-data.html",
  can_vaccination    = "https://health-infobase.canada.ca/covid-19/vaccination-coverage/"
)
lapply(links, robotstxt::paths_allowed)

links_other <- list(
  qc_schools_pdf     = "https://cdn-contenu.quebec.ca/cdn-contenu/adm/min/education/publications-adm/covid-19/reseauScolaire_listeEcoles_ANG.pdf",
  municipal_pop      = "https://statistique.quebec.ca/en/document/population-and-age-and-sex-structure-municipalities",
  mrc_pop            = "https://statistique.quebec.ca/fr/document/population-et-structure-par-age-et-sexe-municipalites-regionales-de-comte-mrc/tableau/estimations-de-la-population-des-mrc",
  regions_pop        = "https://statistique.quebec.ca/en/produit/tableau/estimations-population-regions-administratives",
  pop_by_age         = "https://statistique.quebec.ca/fr/produit/tableau/estimations-population-regions-administratives-selon-age-sexe-age-median-age-moyen#tri_tertr=07&tri_pop=1"
)
