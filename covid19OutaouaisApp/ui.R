require(shiny)
require(shinythemes)
# reactlog::reactlog_enable()

shinyUI(
  fluidPage(
    theme = bslib::bs_theme(version = 5, bootswatch = "darkly"),
    # theme = shinytheme("darkly"),
    titlePanel("Covid19 Situation in the Outaouais region of Quebec"),
    checkboxGroupInput("source",
      label = "Data sources to choose from below: ",
      inline = TRUE,
      choices = sort(unique(lookup$source)),
      selected = sort(unique(lookup$source))
    ),
    selectizeInput("series",
      label = "Select data series to display: ",
      multiple = TRUE, choices = NULL, width = "500px",
      options = list(
        maxItems = 10,
        placeholder = "select one or more data series to display (up to 10)"
      )
    ),
    tags$head(
      tags$style(
        HTML("#div_id .selectize-control.single .selectize-input:after{content: none;}")
      )
    ),
    tags$div(
      id = "div_id",
      selectizeInput("bars",
        label = NULL, choices = NULL, width = "500px",
        options = list(placeholder = "optional: choose one data series to show as bars")
      )
    ),
    dateRangeInput("dates",
      label = NULL, width = "500px",
      start = as_date(min(outaouais$time)),
      end = as_date(max(outaouais$time)),
      min = as_date(min(outaouais$time)),
      max = as_date(max(outaouais$time))
    ),
    # checkboxInput("perpop", value = FALSE,
    #               label = "show results per population size"),
    plotOutput("figure", hover = NULL),
    uiOutput("download_button"),
    verbatimTextOutput("text"),
    tableOutput("table")
  )
)
