require(shiny)
require(shinythemes)
require(ggtips)
library(plotly)

shinyServer(function(input, output, session) {

  lookup_new <- reactive({
    lookup %>%
      filter(source %in% input$source)
  })
  already <- reactiveValues(
    bars = list(NULL),
    series = c(
      "Active hospitalizations, ICU [MSSS]",
      "Active hospitalizations, non-ICU [MSSS]",
      "New hospitalizations, ICU [INSPQ]",
      "New hospitalizations, non-ICU [INSPQ]"
    )
  )
  observeEvent(input$series, {
    # already$series <- c(already$series[length(already$series)], input$series)
    already$series <- input$series
  })
  observeEvent(input$bars, {
    already$bars <- input$bars
  })

  observeEvent(lookup_new(), {
    freezeReactiveValue(input, "series")
    choices <- lookup_new() %>%
      pull(series)
    already_selected <- sort(unlist(already$series))
    already_selected <- already_selected[already_selected %in% choices]
    updateSelectizeInput(session,
      inputId = "series",
      choices = choices,
      selected = already_selected
    )
    choices <- lookup_new() %>%
      filter(!str_detect(str_to_lower(series), "average")) %>%
      pull(series)
    updateSelectizeInput(session,
      inputId = "bars",
      choices = c("optional: choose one data series to show as bars" = "", choices),
      selected = already$bars[already$bars %in% choices]
    )
  })

  df <- reactive({
    series <- req(input$series)
    outaouais %>%
      filter(.data$key %in% .env$series) %>%
      filter(as_date(.data$time) >= min(req(input$dates))) %>%
      filter(as_date(.data$time) <= max(req(input$dates)))
  })

  bars <- reactive({
    if (is.null(input$bars)) {
      NULL
    } else {
      bars <- input$bars
      outaouais %>%
        filter(key %in% .env$bars) %>%
        filter(as_date(.data$time) >= min(req(input$dates))) %>%
        filter(as_date(.data$time) <= max(req(input$dates)))
    }
  })

  observeEvent(df(), {
    new_dates <- as_date(range(df()$time))
    updateDateRangeInput(session,
      inputId = "dates",
      start = min(new_dates), end = max(new_dates)
    )
  })

  rugs <- reactive({
    ifelse(sum(str_detect(req(input$series), "CISSS")) > 0, TRUE, FALSE)
  })

  output$figure <- renderPlot({
    CovidFig(
      df = df() %>%
        filter(as_date(.data$time) >= min(req(input$dates))) %>%
        filter(as_date(.data$time) <= max(req(input$dates))),
      bars = bars() %>%
        filter(as_date(.data$time) >= min(req(input$dates))) %>%
        filter(as_date(.data$time) <= max(req(input$dates))),
      rug = rugs(),
      caption = paste("Data source:", lookup %>%
        filter(.data$series %in% input$series) %>%
        pull(source_link) %>%
        unique() %>%
        paste(collapse = "; "))
    )
  })

  output$download_button <- renderUI({
    if (!is.null(input$series)) {
      downloadButton("download_file", label = "Download displayed data series")
    }
  })

  output$download_file <- downloadHandler(
    filename = "covid19Outaouais_app_data.csv",
    content = function(file) {
      write_csv(rbind(df(), bars()) %>% select(key, time, value), file)
    }
  )

})
