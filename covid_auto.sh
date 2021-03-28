#!/bin/bash
cd ~/Documents/GitHub/covid19Outaouais/

/usr/local/bin/Rscript covid_downloads.R
sleep 20

/usr/local/bin/Rscript covid_processing.R
rm Rplots.pdf
sleep 20

/usr/local/bin/Rscript -e 'Sys.setenv(RSTUDIO_PANDOC="/Applications/RStudio.app/Contents/MacOS/pandoc"); rmarkdown::render("README.Rmd", encoding = "UTF-8", output_format = "all")' >> ignore/render.log 2>&1
mv README.html index.html
sleep 20

git add README.md data/covid_local.RData data/covid_local_daily.RData data/data_update_time.txt README_files/figure-gfm websites/last_download_time.txt
git add --force index.html
git commit --message "automatic data update"
git push origin main >> ignore/push.log 2>&1
