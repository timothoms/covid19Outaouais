library(shiny)
library(tidyverse)
library(lubridate)
library(feather)
source("_R/figures_theme.R")
source("_R/CovidFig.R")

# load(url("https://github.com/timothoms/covid19Outaouais/raw/main/_data/covid19Outaouais.RData"))
# load(url("https://github.com/timothoms/covid19Outaouais/raw/main/_data/info.RData"))
outaouais <- read_feather(path = "_data/covid19Outaouais.feather")
info <- read_feather(path = "_data/info.feather")
lookup <- full_join(outaouais %>%
                      select(key, table) %>%
                      unique() %>%
                      arrange(key),
                    info %>%
                      select(outaouais_table, source) %>%
                      rename(table = outaouais_table) %>%
                      unique() ) %>%
  mutate(series = paste(key, " [", source, "]", sep = ""))

ui <- fluidPage(
  h2("Covid19 Situation in Outaouais"),
  selectizeInput("source", label = "", # "Data aggregation to display:"
                 choices = unique(info$source),
                 multiple = TRUE,
                 width = "400px",
                 options = list(placeholder = "optionally choose data sources first to limit choices")),
  selectizeInput("series", label = NULL, # "Data series to display (up to 6):"
                 choices = lookup %>%
                   select(series, key) %>%
                   deframe(),
                 multiple = TRUE,
                 width = "400px",
                 options = list(placeholder = "select one or more series (up to 6)",
                                maxItems = 6)),
  verbatimTextOutput("text"),
  tableOutput("table"),
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
  output$text <- renderText({input$series})
  # output$table <- renderTable({
  #   lookup %>% filter(key %in% input$series)
  # })
}
shinyApp(ui, server)
