SchoolsFig <- function(admin) {
  ggplot(data = schools[schools$admin %in% admin, ],
         aes(x = date, y = school)) +
    geom_point(mapping = aes(x = date, y = school, group = note, colour = note), size = 0.75) +
    scale_color_manual(values = c("newly listed" = "darkgreen",
                                  "previously listed" = "darkgray",
                                  "reaffected previously listed" = "red",
                                  "relisted newly affected" = "green"),
                       breaks = c("newly listed", "previously listed", "reaffected previously listed", "relisted newly affected")
    ) +
    scale_x_date(date_breaks = "2 weeks", date_minor_breaks = "1 week", date_labels = "%d %b %Y", expand = c(0, 2)) +
    scale_y_discrete(limits = rev) +
    guides(colour = guide_legend(ncol = 4)) +
    labs(x = "", y = "", caption = "Data source: www.quebec.ca/sante/problemes-de-sante/a-z/coronavirus-2019/liste-des-cas-de-covid-19-dans-les-ecoles/") +
    common_theme +
    theme(legend.text = element_text(size = rel(0.67)),
          axis.title.y = element_blank())
}
