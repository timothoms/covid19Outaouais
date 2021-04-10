#!/bin/bash
cd ~/Documents/GitHub/covid19Outaouais/

/usr/local/bin/Rscript covid_downloads.R
sleep 10

/usr/local/bin/Rscript covid_processing.R
/usr/local/bin/Rscript covid_processing_csvs.R
rm Rplots.pdf
sleep 10

/usr/local/bin/Rscript -e 'Sys.setenv(RSTUDIO_PANDOC="/Applications/RStudio.app/Contents/MacOS/pandoc", PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin"); rmarkdown::render("index.Rmd", encoding = "UTF-8", params = list(optimize = TRUE))' >> logs/render.log 2>&1
/usr/local/bin/Rscript -e 'Sys.setenv(RSTUDIO_PANDOC="/Applications/RStudio.app/Contents/MacOS/pandoc", PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin"); rmarkdown::render("toronto.Rmd", encoding = "UTF-8", params = list(optimize = TRUE))'
sleep 10

git add data/covid_local.RData
git add data/covid_local_daily.RData
git add data/vaccination.RData
git add data/hospitalization.RData
git add data/inspq.RData
git add data/rls.RData
git add data/schools.RData
git add data/data_update_time.txt
git add data/opencovid_update_time.txt
git add websites/last_download_time.txt
git add --force index.html toronto.html
git commit --message "automatic update"
git push origin main >> logs/push.log 2>&1
