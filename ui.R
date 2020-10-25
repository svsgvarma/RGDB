library(shiny)
library("DT")
library(shinythemes)
library(shinyAce)

source("ui-about.R")
source("ui-readdata.R")
source("ui-tools.R")
source("ui-help.R")


# Define UI for dataset viewer app ----
#ui <- pageWithSidebar(
shinyUI(
  navbarPage(
  img(
    src = "RESCAP.gif",
    height = 35,
    width = 100,
    style = "margin:0.1px 1px"
   ),

    tabPanel("Home",
             #verbatimTextOutput("inputfl")
             ui_about()
             ),
   tabPanel("Table Search",
            ui_readtables()),
   tabPanel("Downloads",
           #verbatimTextOutput("inputfl"))
           ui_downloadtables()
             ),
  navbarMenu(
    "Tools",
    tabPanel("NCBI-BLAST_2.2.26",
             ui_blast()),
    tabPanel("NCBI-BLAST_2.9.0",
            ui_blast2())
  ),
navbarMenu(
  "Help",
  tabPanel("FAQ",
           ui_FAQ()),
  tabPanel("Contact",
           #verbatimTextOutput("inputfl")
           ui_contact()
 )
)
)

)