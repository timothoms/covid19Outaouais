### standardizing tables
FormatTable <- function(table_id, tables) {
  tab <- tables[[table_id]]
  names(tab) <- str_to_lower(names(tab))
  names(tab)[1] <- "key"
  names(tab)[names(tab) %in% c("x2", "number", "nombre", "total")] <- "value"
  names(tab)[names(tab) %in% c("actifs", "actives")] <- "active"
  tab$time <- table_id
  if(!"active" %in% names(tab)) tab$active <- NA
  return(tab[, c("time", "key", "value", "active")])
}
