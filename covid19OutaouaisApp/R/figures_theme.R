common_theme <- theme_classic() +
  theme(axis.text.x = element_text(angle = 15, vjust = 1.0, hjust = 1.0),
        axis.title.x = element_blank(),
        axis.title.y.left = element_blank(),
        legend.position = "top",
        legend.title = element_blank(),
        # legend.text = element_text(size = rel(0.67)),
        legend.margin = margin(0, 0, 0, 0),
        panel.grid.minor.x = element_line(colour = "lightgray", size = 0.25),
        # plot.margin = unit(c(5, 5, 5, 5), "pt"),
        plot.caption = element_text(size = rel(0.67)))
