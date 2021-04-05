#!/bin/bash
cd ~/Documents/GitHub/covid19Outaouais/

/usr/local/bin/Rscript covid_downloads.R
sleep 20

/usr/local/bin/Rscript covid_processing.R
rm Rplots.pdf
sleep 20

/usr/local/bin/Rscript -e 'Sys.setenv(RSTUDIO_PANDOC="/Applications/RStudio.app/Contents/MacOS/pandoc", PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin"); rmarkdown::render("index.Rmd", encoding = "UTF-8", params = list(optimize = TRUE))' >> ignore/render.log 2>&1
/usr/local/bin/Rscript -e 'Sys.setenv(RSTUDIO_PANDOC="/Applications/RStudio.app/Contents/MacOS/pandoc", PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin"); rmarkdown::render("toronto.Rmd", encoding = "UTF-8", params = list(optimize = TRUE))'
sleep 20

git add data/covid_local.RData
git add data/covid_local_daily.RData
git add data/hospitals.RData
git add data/vaccination.RData
git add data/data_update_time.txt
git add data/opencovid_update_time.txt
git add websites/last_download_time.txt
git add --force index.html toronto.html
git commit --message "automatic site update"
git push origin main >> ignore/push.log 2>&1

/usr/local/bin/Rscript covid_new.R
