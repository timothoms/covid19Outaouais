### reading HTML source files
ParseHTMLtables <- function(path) {
  ids <- files <- dir(path)
  ids <- str_replace(ids, ".snapshot", "")
  ids <- str_replace(ids, ".html", "")
  files <- paste(path, files, sep = "")
  names(files) <- ids
  tables <- parallel::mclapply(files, function(page) {
    webpage <- rvest::read_html(page, encoding = "UTF-8")
    tab <- tryCatch(webpage %>%
                      rvest::html_nodes(css = "table") %>%
                      rvest::html_table(fill = TRUE), error = function(x) return(NULL) )
    return(tab)
  })
  return(tables)
}
