#!/bin/bash

cd ~/Documents/GitHub/covid19Outaouais/

/usr/local/bin/Rscript covid_downloads.R
sleep 20

/usr/local/bin/Rscript covid_processing.R
rm Rplots.pdf
sleep 20

/usr/local/bin/Rscript -e 'Sys.setenv(RSTUDIO_PANDOC="/Applications/RStudio.app/Contents/MacOS/pandoc"); rmarkdown::render("README.Rmd")' >> ignore/render.log 2>&1
sleep 20

git add README.md data/covid_local.RData data/data_update_time.txt README_files/figure-gfm websites/last_download_time.txt

git commit --message "automatic data update"

git push origin main >> ignore/push.log 2>&1
