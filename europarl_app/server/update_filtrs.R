
choices_update <- reactiveValues()
# choices created in server.R 


update_filtres <- function() {
  
   choices_update$country <- input$filtr_country
   choices_update$eu_group <- input$filtr_eu_group
   choices_update$lang <- input$filtr_language
   choices_update$national_party <- input$filtr_national_party
   choices_update$mep <- input$filtr_mep
   choices_update$titles <- input$filtr_debate_title
   choices_update$date_start <- input$filtr_date[1]
   choices_update$date_end <- input$filtr_date[2]
  #cat('asd: ',input$filtr_date)
  #req(nrow(input$stm_table) > 0)
  
   if(is.null(choices_update$country) & 
      is.null(choices_update$eu_group) &
      is.null(choices_update$lang)) {
     
     cat('null all\n')
     avaliable_choices <- sort(starts$df$national_party)
     selected_chocies <- choices$national_party
     choices_update$national_party <- list(avaliable_choices, selected_chocies)
       
     avaliable_choices <- sort(starts$df$mep)
     selected_chocies <- choices$mep
     choices_update$mep <- list(avaliable_choices, selected_chocies)
     
     choices_update$date_start <- starts$df$date$date_min
     choices_update$date_end <- starts$df$date$date_max
   } else {
       
    #========================== 
    # country
    
    if(is.null(choices_update$country))  {
      country <- seq(1:length(filtr_data$df))
    }
    else {
      choices_update$country <- paste0(choices_update$country, collapse = '|')
      country <- str_which(names(filtr_data$df), 
                           choices_update$country)  
    }
    
    # languages
     
  
    if(is.null(choices_update$lang))  {
      lang <- seq(1:length(filtr_data$df))
    }
    else {
      choices_update$lang <- as.data.frame(choices_update$lang) 
      colnames(choices_update$lang) <- 'name'
      #cat('lang str:', str(choices_update$lang, '\n'))
      choices_update$lang <- left_join(choices_update$lang, lang,by = c('name' = 'full_name')) %>% 
        select('id')
      
      choices_update$lang <- paste0(choices_update$lang, collapse = '|')
      lang <- str_which(names(filtr_data$df), 
                           choices_update$lang)  
      cat('\tlang:', choices_update$lang,'\n')
    }
    
    #eu group
    if(is.null(choices_update$eu_group))  {
      eu_group <- seq(1:length(filtr_data$df))
    }
    else {
      choices_update$eu_group <- paste0(choices_update$eu_group, collapse = '|')
      eu_group <- str_which(names(filtr_data$df), 
                        choices_update$eu_group)  
    }
    
    index_filtr_data <- Reduce(intersect, list(country, lang, eu_group ))
   
    
    #==========================
    
    # National party
    avaliable_choices <- NULL
    for( i in index_filtr_data) {
      
      avaliable_choices <- c(avaliable_choices, unique(unlist(filtr_data$df[[i]]$national_party)))
      
    }
    avaliable_choices <- unique(avaliable_choices)
    #cat('aval chocies:', avaliable_choices, '\n')
    if(!is.null(choices_update$national_party)) {
      index <- unlist(lapply(choices_update$national_party, function(x) {
        str_which(x, avaliable_choices )
      }))
      
      if(is.null(index)) {
        selected_chocies <- NULL
      } else {
        selected_chocies <- avaliable_choices[index]
      }
    }
    else {
      selected_chocies <- NULL
    }
    #isolate(updateSelectizeInput(session, 'filtr_national_party', choices = avaliable_choices, selected = selected_chocies))
    #cat('aval: ', avaliable_choices, '\n')
    choices_update$national_party <- list(avaliable_choices, selected_chocies)
    
    # MEP
    avaliable_choices <- NULL
    for( i in index_filtr_data) {
      avaliable_choices <- c(avaliable_choices, unique(unlist(filtr_data$df[[i]]$name)))
    }
    avaliable_choices <- unique(avaliable_choices)
    
    if(!is.null(choices_update$mep)) {
      index <- unlist(lapply(choices_update$mep, function(x) {
        str_which(x, avaliable_choices )
      }))
      
      if(is.null(index)) {
        selected_chocies <- NULL
      } else {
        selected_chocies <- avaliable_choices[index]
      }
    }
    else {
      selected_chocies <- NULL
    }
    choices_update$mep <- list(avaliable_choices, selected_chocies)
    
  
    # Title    
    avaliable_choices <- NULL
    for( i in index_filtr_data) {
      avaliable_choices <- c(avaliable_choices, unique(unlist(filtr_data$df[[i]]$title)))
    }
    avaliable_choices <- unique(avaliable_choices)
    #cat('aval: ', length(avaliable_choices))
    if(!is.null(choices_update$titles)) {
      index <- unlist(lapply(choices_update$titles, function(x) {
        str_which(x, avaliable_choices )
      }))
      
      if(is.null(index)) {
        selected_chocies <- NULL
      } else {
        selected_chocies <- avaliable_choices[index]
      }
 
    }
    else {
      selected_chocies <- NULL
    }
    
    choices_update$titles <- list(avaliable_choices, selected_chocies)
    
    
    # date
    # 
    avaliable_choices <- NULL
    #index_filtr_data <- c(1:2)
    for( i in index_filtr_data) {

      if(i == 1) {
        
        avaliable_choices <- do.call(c,filtr_data$df[[i]]$date)
      }
      else {
        avaliable_choices <- c(avaliable_choices, do.call(c,filtr_data$df[[i]]$date))
      }

    }

    choices_update$date_start <- ymd(range(avaliable_choices)[1])
    choices_update$date_end <- ymd(range(avaliable_choices)[2])
    #cat("dates: ", str(choices_update$date_start), ymd(choices_update$date_start),'\n')
   
    
    # if (ymd(choices_update$date_min) < date_start ) {
    #   date_start <- choices_update$date_start
    # }
    # if(ymd(choices_update$date_max) > date_end) {
    #   date_end <- choices_update$date_end
    # }
    # choices_update$date_min <-  date_start
    # choices_update$date_max <- date_end
    # 
    #print(choices_update)
    }
  cat('\n\tend update\t\n')
}

observeEvent(c(input$filtr_country, input$filtr_eu_group, input$filtr_language),{
 
  cat('update:\n', 
      '\tcountry: ', input$filtr_country, '\n',
      '\teu_group: ', input$filtr_eu_group, '\n',
      '\tlanguage: ', input$filtr_language, '\n')
  
  update_filtres()
}, ignoreNULL = FALSE)

# lista filtrów
# filtr_country
# filtr_eu_group
# filtr_language
# filtr_national_party
# filtr_mep
# filtr_date
# filtr_debate_title