common_theme <- theme_classic() +
  theme(axis.text.x = element_text(angle = 15, vjust = 1.0, hjust = 1.0),
        axis.title = element_blank(),
        legend.position = "top",
        legend.title = element_blank(),
        legend.margin = margin(0, 0, 0, 0),
        panel.grid.minor.x = element_line(colour="lightgray", size = 0.25),
        plot.caption = element_text(size = rel(0.67)))
DailyFig <- function(keys) {
  df <- daily[daily$change_key %in% keys & daily$table == "opencovid.ca", ]
  caption <- paste("Last day in dataset: ", format(max(df$date), "%b %d"), ". Data source: opencovid.ca/api/", sep = "")
  ggplot(mapping = aes(x = date, y = daily_change_avg, group = change_key, color = change_key)) +
    geom_line(data = df) +
    scale_x_date(date_breaks = "1 month", date_minor_breaks = "2 weeks", date_labels = "%b %Y") +
    lims(y = c(0, NA)) + common_theme +
    labs(x = "", y = "", caption = caption)
}
LocalFig <- function(keys) {
  df <- covid[covid$key %in% keys & covid$table == "opencovid.ca", ]
  caption <- paste("Last day in dataset: ", format(max(df$time), "%b %d"), ". Data source: opencovid.ca/api/", sep = "")
  ggplot(mapping = aes(x = time, y = value, group = key, color = key)) +
    geom_line(data = df) +
    scale_x_datetime(date_breaks = "1 month", date_minor_breaks = "2 weeks", date_labels = "%b %Y") +
    lims(y = c(0, NA)) + common_theme +
    labs(x = "", y = "", caption = caption)
}
