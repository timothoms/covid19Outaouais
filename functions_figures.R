common_theme <- theme_classic() +
  theme(axis.text.x = element_text(angle = 15, vjust = 1.0, hjust = 1.0),
        axis.title = element_blank(),
        legend.position = "top",
        legend.title = element_blank(),
        # legend.text = element_text(size = rel(0.67)),
        legend.margin = margin(0, 0, 0, 0),
        # legend.box.margin = margin(-10, -10, -10, -10),
        panel.grid.minor.x = element_line(colour="lightgray", size = 0.25),
        # plot.margin = unit(c(5, 5, 5, 5), "pt"),
        plot.caption = element_text(size = rel(0.67)))

DailyFig <- function(keys,
                     tab = "rls",
                     rug = TRUE,
                     per_pop = FALSE,
                     caption = "Data source: cisss-outaouais.gouv.qc.ca/language/en/covid19-en/"
){
  df <- daily[daily$change_key %in% keys & daily$table == tab, ]
  caption <- paste("Last day in dataset: ", format(max(df$date), "%b %d"), ". ", caption, sep = "")
  ggplot(data = df) +
    geom_line(mapping = aes(x = date, y = daily_change_avg, group = change_key, color = change_key)) +
    { if(per_pop)
      scale_y_continuous(sec.axis = sec_axis(trans = ~ . / pop_outaouais_2020 * 100000,
                                             name = "per 100,000 population (2020)"),
                         limits = c(0, NA)) else lims(y = c(0, NA))
    } +
    { if(rug)
      geom_rug(mapping = aes(x = date), sides = "b", length = unit(0.02, "npc"))
    } +
    scale_x_date(date_breaks="1 month", date_minor_breaks = "2 weeks", date_labels = "%b %Y") +
    common_theme +
    guides(colour = guide_legend(ncol = 3)) +
    labs(x = "", y = "", caption = caption)
}

LayeredFig <- function(keys,
                       rug = TRUE,
                       per_pop = FALSE,
                       caption = "Data source: cisss-outaouais.gouv.qc.ca/language/en/covid19-en/"
){
  caption <- paste("Last day in dataset: ", format(max(covid$time), "%b %d"), ". ", caption, sep = "")
  ggplot(mapping = aes(x = time, y = value, group = key, color = key)) +
    geom_line(data = covid[covid$key %in% keys & covid$table == "cases", ]) +
    geom_line(data = covid[covid$key %in% keys & covid$table == "areas", ]) +
    # geom_line(data = covid[covid$key %in% keys & covid$table == "rls", ]) +
    { if(per_pop)
      scale_y_continuous(sec.axis = sec_axis(trans = ~ . / pop_outaouais_2020 * 100000,
                                             name = "per 100,000 population (2020)"),
                         limits = c(0, NA))
      else
        lims(y = c(0, NA))
    } +
    { if(rug)
      geom_rug(data = covid[covid$key %in% keys & covid$table %in% c("cases", "areas", "rls"), ],
               mapping = aes(x = time), sides = "b", colour = "black", length = unit(0.02, "npc"))
    } +
    scale_x_datetime(date_breaks="1 month", date_minor_breaks = "2 weeks", date_labels = "%b %Y") +
    common_theme +
    labs(x = "", y = "", caption = caption)
}

LocalFig <- function(keys,
                     tab = c("areas", "rls"),
                     rug = TRUE,
                     legend_cols = 4,
                     caption = "Data source: cisss-outaouais.gouv.qc.ca/language/en/covid19-en/"
){
  df <- covid[covid$key %in% keys & covid$table %in% tab, ]
  caption <- paste("Last day in dataset: ", format(max(df$time), "%b %d"), ". ", caption, sep = "")
  ggplot(data = df) +
    geom_line(mapping = aes(x = time, y = value, group = key, colour = key)) +
    { if(rug)
      geom_rug(mapping = aes(x = time), sides = "b", length = unit(0.02, "npc"))
    } +
    scale_x_datetime(date_breaks = "1 month", date_minor_breaks = "2 weeks", date_labels = "%b %Y") +
    # scale_colour_discrete(breaks = keys, labels = keys) +
    lims(y = c(0, NA)) +
    common_theme +
    guides(colour = guide_legend(ncol = legend_cols)) +
    labs(x = "", y = "", caption = caption)
}

RegionFig <- function(df,
                      second = NULL,
                      bars = NULL,
                      caption,
                      pop = NULL,
                      dlabels = "%b %Y",
                      legend_cols = 3)
{
  caption <- paste("Last day in dataset: ", format(max(df$date), "%b %d"), ". ", caption, sep = "")
  ggplot(data = df[df$date > "2020-03-15", ],
         mapping = aes(x = date, y = value, group = key, color = key)) +
    { if(!is.null(bars))
      geom_bar(data = bars[bars$date > "2020-03-15", ],
               mapping = aes(fill = unique(bars$key)),
               stat = "identity", color = "lightgray")
    } +
    scale_fill_manual(labels = unique(bars$key), values = "lightgray") +
    geom_line() +
    { if(!is.null(second))
      geom_line(data = second[second$date > "2020-03-15", ])
    } +
    scale_x_date(date_breaks = "1 month", date_minor_breaks = "2 weeks", date_labels = dlabels) +
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
    guides(colour = guide_legend(ncol = legend_cols)) +
    labs(x = "", y = "", caption = caption)
}

RLSFig <- function(df, caption, legend_cols = 2) {
  # caption <- paste("Last day in dataset: ", format(max(df$time), "%b %d"), ". ", caption, sep = "")
  ggplot(data = df) +
    geom_line(mapping = aes(x = time, y = value, group = key, color = key)) +
    scale_x_datetime(date_breaks = "1 month", date_minor_breaks = "2 weeks", date_labels = "%b %Y") +
    common_theme +
    guides(colour = guide_legend(ncol = legend_cols)) +
    labs(x = "", y = "", caption = caption)
}

SchoolsFig <- function(admin) {
  ggplot(data = schools[schools$admin %in% admin, ],
         aes(x = date, y = school)) +
    geom_point(mapping = aes(x = date, y = school, group = note, colour = note), size = 0.75) +
    # geom_segment(mapping = aes(x = date, xend = lead(date), y = school, yend = school, group = note, colour = note)) +
    scale_color_manual(values = c("newly listed" = "darkgreen",
                                  "previously listed" = "darkgray",
                                  "reaffected previously listed" = "red",
                                  "relisted newly affected" = "green"),
                       breaks = c("newly listed", "previously listed", "reaffected previously listed", "relisted newly affected")
    ) +
    scale_x_date(date_breaks = "2 weeks", date_labels = "%d %b %Y") +
    guides(colour = guide_legend(ncol = 4)) +
    labs(x = "", y = "", caption = "Data source: www.quebec.ca/sante/problemes-de-sante/a-z/coronavirus-2019/liste-des-cas-de-covid-19-dans-les-ecoles/") +
    common_theme +
    theme(legend.text = element_text(size = rel(0.67)))
}
