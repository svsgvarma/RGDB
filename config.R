print("Run config.R")

#install relied packages
source("global.R")
#init input and library
rm(list=ls())
library(shiny)
library(dplyr)
library(data.table)
library(DT)
library(readr)

#change if necessary
dataDir="./InData/"
dataSuffix=".tsv"


#global variables if any
#maxRect=2500 