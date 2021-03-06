#!/bin/bash
cd ~/Documents/GitHub/covid19Outaouais/

/usr/local/bin/Rscript covid_downloads.R
sleep 10
/usr/local/bin/Rscript covid_processing.R
/usr/local/bin/Rscript covid_processing_csvs.R
sleep 10
/usr/local/bin/Rscript -e 'Sys.setenv(RSTUDIO_PANDOC="/Applications/RStudio.app/Contents/MacOS/pandoc", PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin"); rmarkdown::render_site(encoding = "UTF-8")' >> _ignore/render.log 2>&1
sleep 10

git add _data/*.RData
git add _data/*.txt
git add _websites/last_download_time.txt
git add --force docs/\*
git commit --message "automatic update"
git push origin main >> _ignore/push.log 2>&1
