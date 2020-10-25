
##### FAQ function ######
ui_FAQ <- function() {
  mainPanel(h3("FAQ"),
  helpText("1. What is the average length of RGenes?"),
  helpText("A. Average lengths other stats can be seen in the stats page (About -> Stats)"),
  helpText("2. How many RG classes are included in the ResCap-db?"),
  helpText("A. There are 4 classes included in the DB such as CNL, RLK, RLP and TNL")
  )
}

##### Contact form function ######
ui_contact <- function() {
  pageWithSidebar(
    headerPanel("Contact"),
    sidebarPanel(
      textInput("from", "Email:", value="from@gmail.com"),
      #textInput("to", "To:", value="to@gmail.com"),
      textInput("subject", "Subject:", value=""),
      actionButton("send", "Send mail"),
      width = 3),
      mainPanel(
      aceEditor("message", value="write message here")
      )
  )
}