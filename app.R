library(shiny)
library(tidyverse)
library(lubridate)
library(feather)
source("_R/figures_theme.R")
source("_R/CovidFig.R")

# load(url("https://github.com/timothoms/covid19Outaouais/raw/main/_data/covid19Outaouais.RData"))
# load(url("https://github.com/timothoms/covid19Outaouais/raw/main/_data/info.RData"))
outaouais <- read_feather(path = "_data/covid19Outaouais.feather")
# outaouais %>% select(key, table) %>% arrange(key) %>% unique() %>% print(n = Inf)
info <- read_feather(path = "_data/info.feather")
lookup <- left_join(outaouais %>%
                      select(key, table) %>%
                      unique() %>%
                      arrange(key),
                    info %>%
                      filter(source != "OpenCovid") %>%
                      select(outaouais_table, source) %>%
                      rename(table = outaouais_table) %>%
                      unique() ) %>%
  mutate(series = paste(key, " [", source, "]", sep = ""))

# lookup %>% select(key, table) %>% filter(key %in% names(table(lookup$key)[table(lookup$key) > 1])) %>% print(n = Inf)

ui <- fluidPage(
  h2("Covid19 Situation in Outaouais"),
  selectizeInput("source", label = "", # "Data aggregation to display:"
                 choices = sort(unique(lookup$source)),
                 multiple = TRUE,
                 width = "400px",
                 options = list(placeholder = "optional: choose data sources first to limit choices below")),
  selectizeInput("series", label = NULL, # "Data series to display (up to 6):"
                 choices = NULL,
                 multiple = TRUE,
                 width = "400px",
                 options = list(placeholder = "select one or more data series to display (up to 6)",
                                maxItems = 6)),
  # selectizeInput("bars", label = NULL,
  #                choices = NULL,
  #                width = "400px",
  #                options = list(placeholder = "optional: choose one data series to show as bars")),
  plotOutput("figure")
)

server <- function(input, output, session) {
  new <- reactive({
    if(is.null(input$source)) lookup
      else lookup %>% filter(source %in% input$source)
  })
  observeEvent(new(), {
    freezeReactiveValue(input, "series")
    choices <- new() %>%
      select(series, key) %>%
      deframe()
    updateSelectizeInput(session,
                         inputId = "series",
                         choices = choices)
  })
  output$figure <- renderPlot({
    series <- req(input$series)
    outaouais %>%
      filter(.data$key %in% .env$series) %>%
      CovidFig(caption = "")
  })
}
shinyApp(ui, server)
