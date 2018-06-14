

data_table <- reactive({


  validate({
    need(!((is.null(input$filtr_eu_group)) & (is.null(input$filtr_country)) &
            (is.null(input$filtr_language))), 
          'Please select at least one filtr of Country, EU group or language.')
  })
  
  
  term <- input$filtr_term_of_office
  cat('\tterm:', term, '\n')
  if(!is.null(input$filtr_country)) {
    
    country <- input$filtr_country
  } else {
    country <- start_options$country
  }
  cat('\tcountry choose:', country, '\n')
  
  if(!is.null(input$filtr_eu_group)) {
    cat('eu_group: ', input$filtr_eu_group, '\n')
    
    eu_group <- input$filtr_eu_group
  } else {
    eu_group <- sort(dbGetQuery(pool, "SELECT id FROM eu_party_code;")$id)
  }
  
  if(!is.null(input$filtr_mep)) {
    
    cat('MEP: ', input$filtr_mep, '\n')
    mep_names <- input$filtr_mep
  } else {
    mep_names <- sort(dbGetQuery(pool, "SELECT name FROM deputies  LEFT JOIN term_of_office 
                                 ON deputies.id = term_of_office.deputies_id 
                                 WHERE term_of_office.term = 8")$name)
    
  }
  mep_names <- str_replace_all(mep_names, "'", "''")
  
  if(!is.null(input$filtr_national_party)) {
    
    cat('national party: ', input$filtr_national_party, '\n')
    
    national_party <- input$filtr_national_party
    
  } else {
    national_party <- start_options$national_party
  }
  national_party <- str_replace_all(national_party, "'", "''")
  
  if(!is.null(input$filtr_debate_title)) {
    
    cat('MEP: ', input$filtr_debate_title, '\n')
    
    titles <- input$filtr_debate_title
  } else {
    titles <- start_options$stm_title
  }
  
  titles <- str_replace_all(titles, "'", "''")
  
  if(!is.null(input$filtr_language)) {
    
    cat('lang: ', input$filtr_language, '\n')
    
    df_lang <- lang %>% 
      filter(full_name %in% input$filtr_language) %>% 
      select(id)
    cat('\n', str(df_lang), nrow(df_lang), '\n')
    language_code <- as.character(df_lang$id)
    
  } else {
    language_code <- lang$id
  }
  cat('lang code:', language_code, '\n')
  
  validate(
    need((!is.null(input$filtr_date[2])) & (!is.null(input$filtr_date[1])),
         'No data to show2')
  )
  
  #DATE
  
  validate(
    need(input$filtr_date[2] > input$filtr_date[1],
         'End date is earlier than start date')
  )

  date_start <-ymd(input$filtr_date[1])
  date_end <- ymd(input$filtr_date[2])
  #cat('date end:', str(ymd(date_end)), '\n')
  query_all_statements <- paste0("SELECT stm.*, national_party.full_name as national_party_full_name FROM (
                                 SELECT stm_dep.*, eu_group.full_name as eu_group_full_name,  eu_group.id as eu_group_id FROM
                                 (SELECT statements.*, mep.name, mep.nationality, mep.link as mep_link  FROM 
                                 (SELECT id , name, nationality, link FROM deputies
                                 LEFT JOIN term_of_office 
                                 ON deputies.id = term_of_office.deputies_id 
                                 WHERE term_of_office.term = ", term , "
                                 AND (deputies.nationality IN ('", paste(country, collapse = "','") , "'))
                                 AND (deputies.name IN ('", paste(mep_names, collapse = "','") , "')) ) mep
                                 INNER JOIN statements 
                                 ON statements.deputies_id = mep.id) stm_dep
                                 LEFT JOIN 
                                 (SELECT `date_beginning`, IF(`date_end` IS NULL, '2100-01-01', `date_end`) as date_end, 
                                 `deputies_id`, eu_party_code.*
                                 FROM `eu_party` 
                                 LEFT JOIN eu_party_code
                                 ON eu_party.full_name = eu_party_code.full_name 
                                 WHERE eu_party_code.id IN ('", paste(eu_group, collapse = "','") , " ')) eu_group 
                                 ON eu_group.deputies_id = stm_dep.deputies_id 
                                 WHERE eu_group.date_beginning <= stm_dep.date AND eu_group.date_end >= stm_dep.date) stm
                                 LEFT JOIN 
                                 (SELECT `date_beginning`,  IF(`date_end` IS NULL, '2100-01-01', `date_end`) as data_end, 
                                 `deputies_id`, `full_name`
                                 FROM `national_party` 
                                 WHERE national_party.full_name IN ('", paste(national_party, collapse = "','") , " ') ) national_party 
                                 ON national_party.deputies_id = stm.deputies_id 
                                 WHERE national_party.date_beginning <= stm.date AND national_party.data_end >= stm.date 
                                 AND stm.title IN ('", paste(titles, collapse = "','") , " ')
                                 AND stm.language_code IN ('", paste(language_code, collapse = "','") , " ') 
                                 AND stm.date >='", date_start, "' AND stm.date <= '", date_end, "' 
                                 AND stm.term = ", term, ";")
  
  
  data <- dbGetQuery(pool, query_all_statements)
  
  cat('nrow data:', nrow(data),  '\n')
  data <- left_join(data, lang, by = c('language_code' = "id"))
  colnames(data)[length(data)] <- 'lang_full_name'
  
  data$date <- ymd(data$date)
  
  #cat('colnames: ', colnames(data))
 
  data <- data.frame(
    mep_id = data$deputies_id,
    Date = data$date,
    Debate = createLink(data$link, data$title),
    Statement = data$text,
    MEP = createLink(data$mep_link,data$name),
    Country = data$nationality,
    eu_group = data$eu_group_id,
    eu_group_full_name = data$eu_group_full_name,
    national_party = data$national_party,
    reference = data$reference,
    stm_link = data$link, 
    mep_link = data$mep_link,
    duration = data$duration,
    start_time = data$start_time,
    end_time = data$end_time,
    language_code = data$language_code,
    language_full_name = data$lang_full_name,
    stm_id = data$id
    
  )

  
  keywords <- input$search
  if(!is.null(keywords)) {
    
    keywords <-  gsub(",","|",gsub("","",keywords))
    
    cat("keywords: ", keywords,"\n")
    
    data$key_grepl <- grepl(keywords, data$Statement)
    
    data <- data[data$key_grepl==TRUE,]
    
    data <- data %>% select(-length(data))
  }
  #cat('colnames: ', colnames(data))
  
  
  if(vars_hide$counter == 0 & nrow(data)!=0 ) {
    data$Statement <- paste0(substr(data$Statement,1,50),"...")
  }
  
  validate(
    need(nrow(data) != 0, "No data to show.")
  )


  
  return(data)
})

output$stm_table <- renderDataTable({
 
  data <- data_table()
  
  return(data)
}, escape = FALSE,  extensions = 'Buttons', rownames = FALSE,
colnames = c('Deputy id','Date', 'Debate', 'Statement', 'MEP', 'Country','European political group',
             'EU group full name', 'National party',
             'Reference','Link to statement', "Link to MEP", "Duration", "Start time", "End time",
             'Language code', 'Language full name', 'Statements id'),
options = list(columnDefs = list(list(visible = FALSE, targets = c(0,7, 9:17 ))),
               pageLength = 10, dom = 'lrtip', scrollX = TRUE)
)