library(tidyverse)
library(lubridate)
knitr::knit_hooks$set(optipng = knitr::hook_optipng)
knitr::knit_hooks$set(pngquant = knitr::hook_pngquant)
knitr::opts_chunk$set(echo = FALSE,
                      cache = FALSE,
                      results = 'hide',
                      warning = FALSE,
                      message = FALSE)
knitr::opts_chunk$set(dpi = 120,
                      fig.width = 7,
                      fig.height = 5,
                      out.width = "100%",
                      out.height = "100%")
if(params$optimize) knitr::opts_chunk$set(optipng = '-o7')
Sys.setlocale(category = "LC_ALL", locale = "en_CA.UTF-8")
options(scipen = 100000)
