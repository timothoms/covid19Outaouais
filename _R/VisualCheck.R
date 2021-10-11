VisualCheck <- function(df = cisss, keys, tab, exclude = NULL) {
  keys <- keys[!keys %in% exclude]
  ggplot(data = df[df$key %in% keys & df$table == tab, ]) +
    geom_line(mapping = aes(x = time, y = value, group = key, color = key)) +
    geom_point(data = df[df$key == "" & df$table == tab, ],
               mapping = aes(x = time, y = value, group = key, color = key)) +
    theme_classic() +
    labs(x = "", y = "") +
    theme(legend.position = "bottom")
}
