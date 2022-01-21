library(shiny)
library(tidyverse)
library(lubridate)
library(feather)
source("_R/figures_theme.R")
source("_R/CovidFig.R")

reactlog::reactlog_enable()

# load(url("https://github.com/timothoms/covid19Outaouais/raw/main/_data/covid19Outaouais.RData"), verbose = TRUE)
# load(url("https://github.com/timothoms/covid19Outaouais/raw/main/_data/info.RData"), verbose = TRUE)
outaouais <- read_feather(path = "_data/covid19Outaouais.feather")
info <- read_feather(path = "_data/info.feather")
# outaouais %>% select(key, table) %>% arrange(key) %>% unique() %>% print(n = Inf)
pop <- outaouais %>%
  filter(table == "INSPQ RLS pop")
lookup <- left_join(outaouais %>%
                      select(key, table) %>%
                      unique() %>%
                      arrange(key),
                    info %>%
                      select(outaouais_table, source) %>%
                      rename(table = outaouais_table) %>%
                      unique(),
                    by = "table") %>%
  mutate(series = paste(key, " [", table, "]", sep = ""))
outaouais <- outaouais %>%
  filter(table != "INSPQ RLS pop") %>%
  left_join(lookup, by = c("key", "table")) %>%
  select(series, table, time, value) %>%
  rename(key = series)
# lookup %>% select(key, table) %>% filter(key %in% names(table(lookup$key)[table(lookup$key) > 1])) %>% print(n = Inf)

ui <- fluidPage(
  h2("Covid19 Situation in Outaouais"),
  checkboxGroupInput("source", label = NULL, inline = TRUE,
                     choices = sort(unique(lookup$source)),
                     selected = sort(unique(lookup$source))),
  selectizeInput("series", label = NULL, multiple = TRUE, choices = NULL, width = "400px",
                 options = list(maxItems = 10,
                                placeholder = "select one or more data series to display (up to 10)")),
  tags$head(
    tags$style(
      HTML("#div_id .selectize-control.single .selectize-input:after{content: none;}")
    )
  ),
  tags$div(id = "div_id",
           selectizeInput("bars", label = NULL, choices = NULL, width = "400px",
                          options = list(placeholder = "optional: choose one data series to show as bars"))),
  dateRangeInput("dates", label = NULL, width = "400px",
                 start = as_date(min(outaouais$time)),
                 end = as_date(max(outaouais$time))),
  # checkboxInput("perpop", label = "show results per population size", value = FALSE),
  plotOutput("figure"),
  uiOutput("download_button"),
  tableOutput("table")
)

server <- function(input, output, session) {
  lookup_new <- reactive({
    if(is.null(input$source))
      lookup
    else
      lookup %>% filter(source %in% input$source)
  })
  already <- reactiveValues(series = list(NULL))
  observeEvent(input$series, {
    last <- already$series[length(already$series)]
    already$series <- c(last, input$series)
  })
  observeEvent(lookup_new(), {
    freezeReactiveValue(input, "series")
    choices <- lookup_new() %>%
      pull(series)
    already_selected <- sort(unlist(already$series))
    updateSelectizeInput(session, inputId = "series",
                         choices = choices,
                         selected = already_selected)
    choices <- lookup_new() %>%
      filter(!str_detect(str_to_lower(series), "average")) %>%
      pull(series)
    updateSelectizeInput(session, inputId = "bars",
                         choices = c("optional: choose one data series to show as bars" = "", choices))
  })
  df <- reactive({
    series <- req(input$series)
    outaouais %>%
      filter(.data$key %in% .env$series &
               as_date(.data$time) >= min(req(input$dates)) &
               as_date(.data$time) <= max(req(input$dates)) )
  })
  bars <- reactive({
    if(is.null(input$bars))
      NULL
    else
      outaouais %>%
        filter(key %in% input$bars &
                as_date(time) >= min(req(input$dates)) &
                as_date(time) <= max(req(input$dates)) )
  })
  rugs <- reactive({
    ifelse(sum(str_detect(req(input$series), "CISSS")) > 0, TRUE, FALSE)
  })
  output$figure <- renderPlot({
    CovidFig(df = df(),
             caption = "",
             bars = bars(),
             rug = rugs())
  })
  output$download_button <- renderUI({
    if(!is.null(input$series)) {
      downloadButton("download_file", label = "Download displayed data series")
    }
  })
  output$download_file <- downloadHandler(
    filename = "covid19Outaouais_app_data.csv",
    content = function(file) {
      write_csv(rbind(df(), bars()) %>% select(key, time, value), file)
    }
  )
}
shinyApp(ui, server)
