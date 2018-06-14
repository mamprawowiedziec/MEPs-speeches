observeEvent(input$download,{

  table <- data_table()
  
  colnames(table) <- c('Deputy id','Date', 'Debate', 'Statement', 'MEP', 'Country','European political group',
                                  'EU group full name', 'National party',
                                  'Reference','Link to statement', "Link to MEP", 
                       "Duration", "Start time", "End time",
                       'Language code', 'Language full name',  'Statements id')
                     
  showModal(modalDialog(
    checkboxGroupInput("download_columns", 
                       "Columns in statements database to download:",
                       names(table), selected = names(table[,c("MEP","Date","Statement", "Language code")])
    ),
    downloadButton('download_file_stm_table', 'Download Filtered Data')
  ))
})

output$download_file_stm_table <- downloadHandler('statements_table.csv',
                                                  content = function(file) {
                                                    temp <- vars_hide$counter
                                                    vars_hide$counter <- 1
                                                    table <- data_table()
                                                    
                                                    vars_hide$counter <- temp
                                                    columns <- input$download_columns
                                                 
                                                    table$Debate <- cleanLink(table$Debate)
                                                    table$MEP <- cleanLink(table$MEP)
                                                    colnames(table) <- c('Deputy id','Date', 'Debate', 'Statement', 'MEP', 'Country','European political group',
                                                                                    'EU group full name', 'National party',
                                                                                    'Reference','Link to statement', "Link to MEP", "Duration", "Start time", "End time",
                                                                                    'Language code', 'Language full name', 'Statements id')
                                                    
                                                   
                                                    write_csv(table[, columns], file)
                                                    #write.csv(table_stm[rows,columns,drop = FALSE], file, fileEncoding = "UTF-8")
                                                    #vars_hide$counter <-  tmp
                                                  })