list.of.packages = c("shiny", "scales", "dplyr","dbplyr", "data.table", "DT", "readr","RMySQL","DBI")
new.packages = list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages))
  install.packages(new.packages)
lapply(list.of.packages,function(x){library(x,character.only=TRUE)})


# get pool from GitHub, since it's not yet on CRAN
devtools::install_github("rstudio/pool")
