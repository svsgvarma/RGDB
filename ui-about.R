

ui_about <- function() {
  fluidPage( theme = shinytheme("spacelab"),
    h3("ResCap DataBase"),
    helpText("Resistance Gene Capture data base (ResCap) contains predicted R-Gene family data-sets, These were generated using Support Vector Machine (SVM) classifier"),
    h4("Quick Search"),
    # Application title
    sidebarPanel(
      #selectInput("search_base", "Select search type:", c('ClassID', "SpeciesName", 'GeneIDs','GeneName'), selected = "GeneIDs", width="300px"),
      selectInput("search_base", "Select search type:", c('ClassID', "SpeciesName", 'GeneIDs','GeneName'), selected = "GeneIDs", width="300px"),
      width = 3),
    mainPanel(
      tabsetPanel(
        ############
        ## SEARCH geneID TAB1
        ############
        tabPanel("Annotation Search",
                 textAreaInput("TextAreaData", "Enter your ID(s) with comma separated list",height = "60px",width = "600px"),
                 actionButton("submit1","Submit")
        )
      )
    )
  )
}


