#!/bin/bash
cd ~/Documents/GitHub/covid19Outaouais/
/usr/local/bin/Rscript covid_downloads.R >> _ignore/downloads.log
sleep 10
/usr/local/bin/Rscript covid_processing.R >> _ignore/processing.log
sleep 10
/usr/local/bin/Rscript -e 'Sys.setenv(RSTUDIO_PANDOC="/Applications/RStudio.app/Contents/MacOS/pandoc", PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin"); rmarkdown::render_site(encoding = "UTF-8")' >> _ignore/render.log
git add _data/*.RData
git add _data/*.txt
git add _websites/last_download_time.txt
git add --force docs/\*
git commit --message "automatic update"
git push origin main >> _ignore/push.log 2>&1
