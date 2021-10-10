VisualCheck <- function(keys, tab, exclude = NULL) {
  keys <- keys[!keys %in% exclude]
  ggplot(data = cisss[cisss$key %in% keys & cisss$table == tab, ]) +
    geom_line(mapping = aes(x = time, y = value, group = key, color = key)) +
    geom_point(data = cisss[cisss$key == "" & cisss$table == tab, ],
               mapping = aes(x = time, y = value, group = key, color = key)) +
    theme_classic() +
    labs(x = "", y = "") +
    theme(legend.position = "bottom")
}
