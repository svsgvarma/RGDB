
ui_readtables <- function() {
  fluidPage(
    # Application title
    h4("RGCap search"),
    hr(),
    mainPanel(
    tabsetPanel(
    tabPanel("Search Table1_Putative_TF", fluidRow(column(5), DT::dataTableOutput('tbl1'))),
    tabPanel("Search Table2_DE_TF", fluidRow(column(5), DT::dataTableOutput('tbl2'))),
    tabPanel("Search Table3_NCBI_GeneID", fluidRow(column(5), DT::dataTableOutput('tbl3')))
    )
    ))
  #)
}

ui_downloadtables <- function() {
  fluidPage(
  # App title ----
  titlePanel("Downloading Data"),
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    # Sidebar panel for inputs ----
    sidebarPanel(
      # Input: Choose dataset ----
      selectInput("dataset", "Choose a dataset:",
                  choices = c("Table1_PutativeTF_all","Table2_DETF_all","Table3_NCBIGeneID_all")),
      radioButtons("type", "File type:",
                   choices = c("Excel(csv)", "Text(tsv)")),
      # Button
      #helpText("Click on the download button to download the datasets"),
      downloadButton("downloadData", "Download")
    ),
    # Main panel for displaying outputs ----
    mainPanel(
      tableOutput("table")
    )
  )
)
}
