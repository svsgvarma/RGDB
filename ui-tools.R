
custom_db <- c("blast_db.fa")
ui_blast <- function() { fluidPage(#theme = shinytheme("spacelab"),
                                   tagList(
                                     tags$head(
                                       tags$link(rel="stylesheet", type="text/css",href="style.css"),
                                       tags$script(type="text/javascript", src = "busy.js")
                                     )
                                   ),
                                   
                                   #This block gives us all the inputs:
                                   mainPanel(
                                     headerPanel('BLAST!'),
                                     textAreaInput('query', 'Input sequence:', value = "", placeholder = "", width = "600px", height="200px"),
                                     selectInput("db", "Databse:", choices=c(custom_db,"nr"), width="120px"),
                                     div(style="display:inline-block",
                                         selectInput("program", "Program:", choices=c("blastn","tblastn"), width="100px")),
                                     div(style="display:inline-block",
                                         selectInput("eval", "e-value:", choices=c(1,0.001,1e-4,1e-5,1e-10), width="120px")),
                                     actionButton("blast", "BLAST!")
                                   ),
                                   
                                   #this snippet generates a progress indicator for long BLASTs
                                   #div(class = "busy",  
                                    #   p("Calculation in progress.."), 
                                    #   img(src="https://i.stack.imgur.com/8puiO.gif", height = 50, width = 50,align = "left")
                                   #),
                                   
                                   #Basic results output
                                   mainPanel(
                                     h4("Results"),
                                     DT::dataTableOutput("blastResults"),
                                     p("Alignment:", tableOutput("clicked") ),
                                     verbatimTextOutput("alignment")
                                   )
)
}

custom_db2 <- c("blast_db.fa")
ui_blast2 <- function() {
  fluidPage(
    # Application title
    # Sidebar
    sidebarPanel(
      h3('Search Parameters'), #top-left title
      selectInput("Searchdatabase2", "Select database type:", c(custom_db2,"All-database", "Reference", 'Selected'), selected = "blast_db.fa", width="300px"),
      selectInput("Searchbtype2", "Blast type:", c('blastn', "tblastn"), selected = "blastn", width="300px"),
      number_EV <- numericInput(
        "Evaluesinsert2",
        "Evalues",
        min = 1e-10, max = 0.1, step = 0.001, value = 0.01, width = "300px" # default is answer = 0.01
      ),
      number_Maxtarget <- numericInput(
        "Maxtargetseq", 
        "Max Target sequences",min = 10, max = 1000, step = 10, value = 10, width = "300px" # default is answer = 10
      ),
      number_Maxhsps <- numericInput(
        "Maxhsps", 
        "Max hsps",min = 1, max = 5, step = 1, value = 1, width = "300px" # default is answer = 1
      ),
      
      width = 3),
    mainPanel(
      tabsetPanel(
        ############
        ## TOOLS TAB1
        ############
        tabPanel("BLAST", 
                 textarea_demo <- textAreaInput("Seqeunce2", "Enter FASTA format seqeunce(s)",height = "200px",width = "600px"),
                 fileInput("FastaFile2", "Or upload FASTA sequence file", accept = c('fast/fa') ), # upload file
                 #verbatimTextOutput("FastaFile2"),
                 submit_demo <- actionButton("blastact2", "BLAST")
        )
      )
    ),
    #Basic results output
    mainPanel(
      h4("Results"),
      DT::dataTableOutput("blastResults2"),
      p("Alignment:", tableOutput("clicked2") ),
      verbatimTextOutput("alignment2")
    )
    )
}