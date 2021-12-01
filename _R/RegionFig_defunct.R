RegionFig <- function(df,
                      second = NULL,
                      bars = NULL,
                      caption,
                      after = "2020-03-15",
                      pop = NULL,
                      dlabels = "%b %Y",
                      legend_cols = 3
){
  caption <- paste("Last day in dataset: ", format(max(df$time), "%b %d"), ". ", caption, sep = "")
  ggplot(data = df[df$time > after, ],
         mapping = aes(x = time, y = value, group = key, color = key)) +
    { if(!is.null(bars))
      geom_bar(data = bars[bars$time > after, ],
               mapping = aes(fill = unique(bars$key)),
               stat = "identity", color = "lightgray")
    } +
    scale_fill_manual(labels = unique(bars$key), values = "lightgray") +
    geom_line() +
    { if(!is.null(second))
      geom_line(data = second[second$time > after, ])
    } +
    scale_x_datetime(date_breaks = "1 month", date_minor_breaks = "2 weeks", date_labels = dlabels, expand = c(0, 5)) +
    { if(!is.null(pop)) {
      if(pop == "percent") {
        p <- list(denom = 100, label = "% of 2020 population")
      }
      if(pop == "per100k") {
        p <- list(denom = 100000, label = "per 100,000 population (2020)")
      }
      scale_y_continuous(limits = c(0, NA),
                         sec.axis = sec_axis(trans = ~ . /pop_outaouais_2020*p$denom, name = p$label))
    } else lims(y = c(0, NA))
    } +
    common_theme +
    theme(panel.grid.major.y = element_line(colour="lightgray", size = 0.25)) +
    guides(colour = guide_legend(ncol = legend_cols)) +
    labs(x = "", y = "", caption = caption)
}
