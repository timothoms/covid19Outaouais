api_link <- "https://api.github.com/repos/timothoms/covid19Outaouais"
jsonlite::fromJSON(api_link)$size /1000
