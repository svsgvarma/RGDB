library(shiny)
library(dplyr)
library(DT)
require(data.table)
library(readxl)
library(shinyAce)
library(sendmailR)

require(XML)
library(plyr)



#source("server-help.R")
#source("server-downloads.R")

# Define server logic to access data ----
shinyServer(
  server_table <-  function(input, output, session) {
  ############################################
  #### about - Quick search
  ############################################
  search_baseInput <- reactive({
    switch(input$search_base,
             "ClassID" = NULL, 
             "SpeciesName" = NULL, 
             "GeneIDs" = NULL,
             "GeneName" = NULL
           )
    })
  # selected dataset input ----
  # search_textInput <- reactive({
  #   print(input$TextAreaData)
  # })
  # output$text <- renderText({
  #   print(input$a)
  # })
  ############################################
  ###### readtables
  ############################################
  # Reactive value for selected dataset ----
  readflpath ="/Volumes/Mac_HD2/proj_Sandeep-Therese/Input_datasets/"
  
  readfile1 <-  read_excel(paste(readflpath,"Additional_file2.xlsx",sep=""),1)
  readfile2 <-  read_excel(paste(readflpath,"Additional_file2.xlsx",sep=""),2)
  readfile3 <-  read_excel(paste(readflpath,"Additional_file2.xlsx",sep=""),3)
  
  #output$tbl = DT::renderDataTable(readfile, filter = "top")
  output$tbl1 = DT::renderDataTable(readfile1, options = list(autoWidth = TRUE), filter = list( position = 'top', clear = FALSE ))
  output$tbl2 = DT::renderDataTable(readfile2, options = list(autoWidth = TRUE), filter = list( position = 'top', clear = FALSE ))
  output$tbl3 = DT::renderDataTable(readfile3, options = list(autoWidth = TRUE), filter = list( position = 'top', clear = FALSE ))

  ############################################
  #### downloadtables
  ############################################
  # Reactive value for selected dataset ----
  datasetInput <- reactive({
  switch(input$dataset,
           "Table1_PutativeTF_all" = head(readfile1), 
           "Table2_DETF_all" = head(readfile2), 
           "Table3_NCBIGeneID_all" = head(readfile3))
  })
  
  fileext <- reactive({
    switch(input$type,"Excel(csv)" = "csv", "Text(tsv)" = "tsv") 
  })
  
  # Table of selected dataset ----
  output$table <- renderTable({
    datasetInput()
  })
  # Downloadable tsv/csv of selected dataset ----
  output$downloadData <- downloadHandler(
    filename = function() {
      paste(input$dataset, fileext(), sep = ".")
      #paste(input$dataset, ".csv", sep = "")
    },
    content = function(file) {
      sep <- switch(input$type,"Excel(csv)"=",", "Text(tsv)"="\t")
      write.csv(datasetInput(), file, row.names = FALSE)
      #write.table(datasetInput(), file, sep = sep, row.names = FALSE)
    }
  )
  
  

  #### tools
  ############################################
  #### NCBI-BLAST
  ############################################
  custom_db <- c("blast_db.fa")
  custom_db_path <- c("/Volumes/Mac_HD2/proj_Sandeep-Therese/Input_datasets/BLASTDB/blast_db.fa")
  
  blastresults <- eventReactive(input$blast, {
    #gather input and set up temp file
    query <- input$query
    tmp <- tempfile(fileext = ".fa",tmpdir = "/Volumes/Mac_HD2/proj_Sandeep-Therese/Input_datasets/BLASTDB")
    #if else chooses the right database
    if (input$db == custom_db){
      db <- custom_db_path
      remote <- c("")
    } else {
      db <- c("nr")
      #add remote option for nr since we don't have a local copy
      remote <- c("-remote")
    }
    
    #this makes sure the fasta is formatted properly
    if (startsWith(query, ">")){
      writeLines(query, tmp)
    } else {
      writeLines(paste0(">Query\n",query), tmp)
    }
    #print(input$program)
    #calls the blast
    #print(input$program)
    #print(tmp)
    #print(db)
    #print(input$eval)
    data <- system(paste0("/Users/varma/softwares/ncbi-blast-2.2.26+/bin/",input$program," -query ",tmp," -db ",db," -evalue ",input$eval," -outfmt 5 -max_hsps_per_subject 1 -max_target_seqs 10 ",remote), intern = T)
    # remove tmp file
    file.remove(tmp)
    xmlParse(data)
  }, ignoreNULL= T)
  
  ###### pars output data ######
  #Now to parse the results...
  parsedresults <- reactive({
    if (is.null(blastresults())){}
    else {
      xmltop = xmlRoot(blastresults())
      
      #the first chunk is for multi-fastas
      results <- xpathApply(blastresults(), '//Iteration',function(row){
        query_ID <- getNodeSet(row, 'Iteration_query-def') %>% sapply(., xmlValue)
        hit_IDs <- getNodeSet(row, 'Iteration_hits//Hit//Hit_id') %>% sapply(., xmlValue)
        hit_length <- getNodeSet(row, 'Iteration_hits//Hit//Hit_len') %>% sapply(., xmlValue)
        bitscore <- getNodeSet(row, 'Iteration_hits//Hit//Hit_hsps//Hsp//Hsp_bit-score') %>% sapply(., xmlValue)
        eval <- getNodeSet(row, 'Iteration_hits//Hit//Hit_hsps//Hsp//Hsp_evalue') %>% sapply(., xmlValue)
        cbind(query_ID,hit_IDs,hit_length,bitscore,eval)
      })
      #this ensures that NAs get added for no hits
      results <-  rbind.fill(lapply(results,function(y){as.data.frame((y),stringsAsFactors=FALSE)}))
    }
  })
  
  #makes the datatable
  output$blastResults <- renderDataTable({
    if (is.null(blastresults())){
    } else {
      parsedresults()
    }
  }, selection="single")
  
  #this chunk gets the alignemnt information from a clicked row
  output$clicked <- renderTable({
    if(is.null(input$blastResults_rows_selected)){}
    else{
      xmltop = xmlRoot(blastresults())
      clicked = input$blastResults_rows_selected
      tableout<- data.frame(parsedresults()[clicked,])
      
      tableout <- t(tableout)
      names(tableout) <- c("")
      rownames(tableout) <- c("Query ID","Hit ID", "Length", "Bit Score", "e-value")
      colnames(tableout) <- NULL
      data.frame(tableout)
    }
  },rownames =T,colnames =F)
  
  #this chunk makes the alignments for clicked rows
  output$alignment <- renderText({
    if(is.null(input$blastResults_rows_selected)){}
    else{
      xmltop = xmlRoot(blastresults())
      
      clicked = input$blastResults_rows_selected
      
      #loop over the xml to get the alignments
      align <- xpathApply(blastresults(), '//Iteration',function(row){
        top <- getNodeSet(row, 'Iteration_hits//Hit//Hit_hsps//Hsp//Hsp_qseq') %>% sapply(., xmlValue)
        mid <- getNodeSet(row, 'Iteration_hits//Hit//Hit_hsps//Hsp//Hsp_midline') %>% sapply(., xmlValue)
        bottom <- getNodeSet(row, 'Iteration_hits//Hit//Hit_hsps//Hsp//Hsp_hseq') %>% sapply(., xmlValue)
        rbind(top,mid,bottom)
      })
      
      #split the alignments every 40 carachters to get a "wrapped look"
      alignx <- do.call("cbind", align)
      splits <- strsplit(gsub("(.{40})", "\\1,", alignx[1:3,clicked]),",")
      
      #paste them together with returns '\n' on the breaks
      split_out <- lapply(1:length(splits[[1]]),function(i){
        rbind(paste0("Q-",splits[[1]][i],"\n"),paste0("M-",splits[[2]][i],"\n"),paste0("H-",splits[[3]][i],"\n"))
      })
      unlist(split_out)
    }
  })
  
  ##############################################
  #### NCBI-BLAST.2.2.6 ---END
  ##############################################
  
  # tools
  ##############################################
  #### NCBI-BLAST-2.9.0 ---START
  ##############################################
  custom_db2 <- c("blast_db.fa")
  custom_db2_path <- c("/Volumes/Mac_HD2/proj_Sandeep-Therese/Input_datasets/BLASTDB/blast_db.fa")
  
  blastresults2 <- eventReactive(input$blastact2, {
    #gather input and set up temp file
    query <- input$Seqeunce2
    #query <- input$FastaFile2
    
    tmp <- tempfile(fileext = ".fa",tmpdir = "/Volumes/Mac_HD2/proj_Sandeep-Therese/Input_datasets/BLASTDB")
    #if else chooses the right database
    if (input$Searchdatabase2 == custom_db2){
      db <- custom_db2_path
      remote <- c("")
    } else {
      db <- c("nr")
      #add remote option for nr since we don't have a local copy
      remote <- c("-remote")
    }
    
    # take inputs sequnce either from raw seq or file format
    if (query!="" ) {
      print("raw sequence is not empty")
      #this makes sure the fasta is formatted properly
      if (startsWith(query, ">")){
        writeLines(query, tmp)
      } else {
        writeLines(paste0(">Query\n",query), tmp)
      }
    }else if (query=="")  {
      print("sequence file is given")
      file <- input$FastaFile2
      tmp <- file$datapath
    }
    
    #print(input$Searchbtype2)
    #calls the blast
    ##### 
    data <- system(paste0("/Users/varma/softwares/ncbi-blast-2.9.0+/bin/",input$Searchbtype2," -query ",tmp," -db ",db," -evalue ",input$Evaluesinsert2," -max_target_seqs ",input$Maxtargetseq," -max_hsps ",input$Maxhsps," -outfmt 5 ",remote), intern = T)
    # remove tmp file
    file.remove(tmp)
    xmlParse(data)
  }, ignoreNULL= T)
  
  ###### pars output data ######
  #Now to parse the results...
  parsedresults2 <- reactive({
    if (is.null(blastresults2())){}
    else {
      xmltop = xmlRoot(blastresults2())
      
      #the first chunk is for multi-fastas
      results <- xpathApply(blastresults2(), '//Iteration',function(row){
        query_ID <- getNodeSet(row, 'Iteration_query-def') %>% sapply(., xmlValue)
        hit_IDs <- getNodeSet(row, 'Iteration_hits//Hit//Hit_id') %>% sapply(., xmlValue)
        hit_length <- getNodeSet(row, 'Iteration_hits//Hit//Hit_len') %>% sapply(., xmlValue)
        bitscore <- getNodeSet(row, 'Iteration_hits//Hit//Hit_hsps//Hsp//Hsp_bit-score') %>% sapply(., xmlValue)
        eval <- getNodeSet(row, 'Iteration_hits//Hit//Hit_hsps//Hsp//Hsp_evalue') %>% sapply(., xmlValue)
        cbind(query_ID,hit_IDs,hit_length,bitscore,eval)
      })
      #this ensures that NAs get added for no hits
      results <-  rbind.fill(lapply(results,function(y){as.data.frame((y),stringsAsFactors=FALSE)}))
    }
  })
  
  #makes the datatable
  output$blastResults2 <- renderDataTable({
    if (is.null(blastresults2())){
    } else {
      parsedresults2()
    }
  }, selection="single")
  
  #this chunk gets the alignemnt information from a clicked row
  output$clicked2 <- renderTable({
    if(is.null(input$blastResults_rows_selected)){}
    else{
      xmltop = xmlRoot(blastresults2())
      clicked2 = input$blastResults_rows_selected
      tableout<- data.frame(parsedresults2()[clicked2,])
      
      tableout <- t(tableout)
      names(tableout) <- c("")
      rownames(tableout) <- c("Query ID","Hit ID", "Length", "Bit Score", "e-value")
      colnames(tableout) <- NULL
      data.frame(tableout)
    }
  },rownames =T,colnames =F)
  
  #this chunk makes the alignments for clicked rows
  output$alignment2 <- renderText({
    if(is.null(input$blastResults_rows_selected)){}
    else{
      xmltop = xmlRoot(blastresults2())
      
      clicked2 = input$blastResults_rows_selected
      
      #loop over the xml to get the alignments
      align <- xpathApply(blastresults2(), '//Iteration',function(row){
        top <- getNodeSet(row, 'Iteration_hits//Hit//Hit_hsps//Hsp//Hsp_qseq') %>% sapply(., xmlValue)
        mid <- getNodeSet(row, 'Iteration_hits//Hit//Hit_hsps//Hsp//Hsp_midline') %>% sapply(., xmlValue)
        bottom <- getNodeSet(row, 'Iteration_hits//Hit//Hit_hsps//Hsp//Hsp_hseq') %>% sapply(., xmlValue)
        rbind(top,mid,bottom)
      })
      
      #split the alignments every 40 carachters to get a "wrapped look"
      alignx <- do.call("cbind", align)
      splits <- strsplit(gsub("(.{40})", "\\1,", alignx[1:3,clicked2]),",")
      
      #paste them together with returns '\n' on the breaks
      split_out <- lapply(1:length(splits[[1]]),function(i){
        rbind(paste0("Q-",splits[[1]][i],"\n"),paste0("M-",splits[[2]][i],"\n"),paste0("H-",splits[[3]][i],"\n"))
      })
      unlist(split_out)
    }
  })
  
  ##############################################
  #### NCBI_BLAST-2.9.0 ---END
  ##############################################
  
  ##############################################
  #server_table()---end
  }
)

