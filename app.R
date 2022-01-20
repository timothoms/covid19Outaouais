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
                      # filter(source != "OpenCovid") %>%
                      select(outaouais_table, source) %>%
                      rename(table = outaouais_table) %>%
                      unique(),
                    by = "table") %>%
  mutate(series = paste(key, " [", table, "]", sep = ""))
outaouais <- left_join(outaouais, lookup, by = c("key", "table")) %>%
  select(series, table, time, value) %>%
  rename(key = series)

# lookup %>% select(key, table) %>% filter(key %in% names(table(lookup$key)[table(lookup$key) > 1])) %>% print(n = Inf)

ui <- fluidPage(
  h2("Covid19 Situation in Outaouais"),
  # selectizeInput("source",
  #                label = "", # "Data aggregation to display:"
  #                choices = sort(unique(lookup$source)),
  #                multiple = TRUE,
  #                width = "400px",
  #                options = list(placeholder = "optional: choose data sources first to limit choices below")),
  checkboxGroupInput("source",
                     label = NULL, # "Data sources included:",
                     choices = sort(unique(lookup$source)),
                     selected = sort(unique(lookup$source)),
                     inline = TRUE),
  selectizeInput("series",
                 label = NULL,
                 choices = NULL,
                 multiple = TRUE,
                 width = "400px",
                 options = list(placeholder = "select one or more data series to display (up to 10)",
                                maxItems = 10)),
  selectizeInput("bars",
                 label = NULL,
                 choices = NULL,
                 width = "400px",
                 options = list(placeholder = "optional: choose one data series to show as bars")),
  dateRangeInput("dates",
                 start = as_date(min(outaouais$time)),
                 end = as_date(max(outaouais$time)),
                 label = NULL,
                 width = "400px"),
  checkboxInput("perpop",
                label = "show results per population size",
                value = FALSE),
  tableOutput("table"),
  plotOutput("figure"),
  downloadLink("download",
               label = "Download displayed data series")
)

server <- function(input, output, session) {
  lookup_new <- reactive({
    if(is.null(input$source)) lookup
      else lookup %>% filter(source %in% input$source)
  })
  observeEvent(lookup_new(), {
    freezeReactiveValue(input, "series")
    choices <- lookup_new() %>% pull(series)
    updateSelectizeInput(session, inputId = "series", choices = choices)
    updateSelectizeInput(session, inputId = "bars",
                         choices = c("optional: choose one data series to show as bars" = "", choices))
  })
  output$table <- renderTable({
    # series <- req(input$series)
    # lookup %>%
    #   filter(.data$series %in% .env$series)
    tibble(as_date(input$dates))
  })
  df <- reactive({
    series <- input$series
    outaouais %>% filter(.data$key %in% .env$series)
  })
  rugs <- reactive({
    ifelse(sum(str_detect(req(input$series), "CISSS")) > 0, TRUE, FALSE)
  })
  # bars <- reactive({
  #   series <- req(input$bars)
  #   if(is.null(input$bars)) NULL
  #   else outaouais %>% filter(.data$key %in% .env$series)
  # })
  output$figure <- renderPlot({
    df() %>% CovidFig(caption = "", rug = rugs())
  })
  output$download <- downloadHandler(
    filename = "covid19Outaouais_app_data.csv",
    content = function(file) {
      write_csv(df() %>%
                  select(key, time, value),
                file)
    }
  )
}
shinyApp(ui, server)
