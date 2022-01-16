library(shiny)
library(tidyverse)
library(feather)

# load(url("https://github.com/timothoms/covid19Outaouais/raw/main/_data/covid19Outaouais.RData"))

outaouais <- read_feather(path = "_data/covid19Outaouais.feather")
info <- read_feather(path = "_data/info.feather") %>%
  filter(aggregation != "schools")

ui <- fluidPage(
  selectInput("level", "Data aggregation to display:",
              choices = c("choose aggregation first" = "", unique(info$aggregation)),
              width = "350px"),
  selectizeInput("series", "Data series to display (up to 5):",
                 choices = NULL,
                 multiple = TRUE,
                 width = "350px",
                 options = list(placeholder = "select one or more series", maxItems = 5)),
  ### output for testing
  tableOutput("data"),
  verbatimTextOutput("text")
)

server <- function(input, output, session) {
  new <- reactive({
    info %>% filter(aggregation == input$level)
  })
  observeEvent(new(), {
    freezeReactiveValue(input, "series")
    choices <- outaouais %>%
      filter(table %in% unique(new()$outaouais_table)) %>%
      pull(key) %>%
      unique() %>%
      sort()
    updateSelectizeInput(inputId = "series",
                         choices = choices)

  })
  output$text <- renderText({input$series})
  output$data <- renderTable(new())
}

shinyApp(ui, server)
