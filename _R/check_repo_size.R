api_link <- "https://api.github.com/repos/timothoms/covid19Outaouais"
jsonlite::fromJSON(api_link)$size /1000

### cleaning repo
# bfg --delete-folders docs
# bfg --delete-folders _data
# git reflog expire --expire=now --all && git gc --prune=now --aggressive
# git push --force
