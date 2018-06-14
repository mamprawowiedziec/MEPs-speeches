


server <- function(input, output, session) {
  
  output$urlText <- renderText({
    paste(sep = "",
          "protocol: ", session$clientData$url_protocol, "\n",
          "hostname: ", session$clientData$url_hostname, "\n",
          "pathname: ", session$clientData$url_pathname, "\n",
          "port: ",     session$clientData$url_port,     "\n",
          "search: ",   session$clientData$url_search,   "\n"
    )
  })
  source(file.path("server","hide_show_button.R"), local = TRUE)$value
  
  source(file.path("server","datatable.R"), local = TRUE)$value
  source(file.path("server","update_filtrs.R"), local = TRUE)$value
  source(file.path("server","graph_top20.R"), local = TRUE)$value
  
  output$tabs <- renderUI({
    
    tabsetPanel(id = 'tabs', #selected =  input$tabs,
                #tabPanel('Countries', ),
                tabPanel('Graphs', plotOutput('plot_nstm_countries') ,
                         plotOutput('top_20'),
                         plotOutput('plot_nstm_lang'), 
                         icon = icon('chart')),
                tabPanel('Data', 
                         HTML('<br>Note: Displaying all data takes some time (~5 min) consider
                           choosing filters first.<br>',
                              'Filtr country, EU group and language determine the remaining filters'),
                        uiOutput("hide_show_button"),
                        dataTableOutput('stm_table'),
                        br(),
                        fluidRow(
                          p(class = 'text-center', actionButton('download',
                                                                'Download Filtered Data', icon('download')))
                        ),
                         icon = icon('table')),
                tabPanel('About', HTML(text_about) )
    , selected 	= 'Data')
  })
  
  
  
  choices <- reactiveValues()
  
  observeEvent(c(input$filtr_country, input$filtr_eu_group, input$filtr_language  ), {
    cat('c2:', choices$country, '\n')
    cat('\ncoutnry:', input$filtr_country, '\n') 
    choices$country <- input$filtr_country
    cat('eu_group:', input$filtr_eu_group, '\n')
    choices$eu_group <- input$filtr_eu_group
    cat('language:', input$filtr_language, '\n')
    choices$lang <- input$filtr_language
    
  }, ignoreNULL = FALSE, ignoreInit = FALSE)
  
  observeEvent(input$filtr_country, {
    choices$country <- 'Poland'
  }, once = TRUE,  ignoreNULL = FALSE)
  
  term_chocies <- reactiveValues(term = 8)

  
  starts <- reactiveValues(df = start_options)
  filtr_data <- reactiveValues(df = filtered_data)
  
  observeEvent(input$filtr_term_of_office, {
    
    if(is.null(input$filtr_term_of_office)) {
      term_chocies$term <- 8
    } else {
      term_chocies$term <- input$filtr_term_of_office
    }
    cat('\n\t term:',  term_chocies$term, '\n')
    
    load(paste0("./data/filter_options_", term_chocies$term,".Rda"), .GlobalEnv)
    load(paste0("./data/start_options_", term_chocies$term,".Rda"), .GlobalEnv)
    starts$df <- start_options   
    cat('\n term of office date', starts$df$date$date_min, '\n')
    
    date_start$value <- starts$df$date$date_min
    date_end$value <- starts$df$date$date_max
    
  }, ignoreNULL = FALSE, ignoreInit = TRUE)
  
  # observe({
  #   choices$country <- input$filtr_country
  #   choices$eu_group <- input$filtr_eu_group
  #   choices$lang <- input$filtr_language
  #   isolate({
  #   choices$national_party <- input$filtr_national_party
  #   choices$mep <- input$filtr_mep
  #   choices$titles <- input$filtr_debate_title
  #   choices$date_start <- input$filtr_date[1]
  #   choices$date_end <- input$filtr_date[2]})
  # 
  #   if(is.null(input$filtr_date[1])) {
  #     choices$date_start <- start_options$date$date_min
  #   }
  #   if(is.null(input$filtr_date[2])) {
  #     choices$date_end <- start_options$date$date_max
  #   }
  # 
  # 
  #   if(is.null(input$country)) {
  # 
  #     cat('country: null \n')
  #   }
  #   else {
  #     #req(input$country)
  #     cat('country: ',input$country, '\n')
  #   }
  #   #cat(unique(data_table()$nationality))
  # })
  
  
  # mozna to poprawic
  source(file.path("server","choices.R"), local = TRUE)$value
    
  
  output$filters <- renderUI({
    cat('c:', starts$df$date$date_min, '\n')
    sidebarPanel(
      textInput(inputId = 'search', label = 'Search'),
      selectizeInput(inputId = 'filtr_country', label = 'Country',
                     choices =  sort(unique(starts$df$country)), multiple = TRUE,
                     selected = choices$country),
      selectizeInput(inputId = 'filtr_eu_group', label = 'European political group',
                     choices= sort(as.character(starts$df$eu_group)), multiple = TRUE,
                     selected = choices$eu_group),
      selectizeInput(inputId = 'filtr_language', label = 'Language of statements',
                     choices=sort(as.character(starts$df$lang$full_name)), multiple = TRUE,
                     selected = choices$lang),
      #==========================================
      selectizeInput(inputId = 'filtr_national_party', label = 'National political party',
                     choices= national_party_cs$choices, multiple = TRUE,
                     selected = national_party_cs$selected ),
      selectizeInput(inputId = 'filtr_mep', label = "MEPs' filter",
                     choices = mep_cs$choices, multiple = TRUE,
                     selected = mep_cs$selected),
      dateRangeInput(inputId = 'filtr_date', label = 'Date range',
                      min = starts$df$date$date_min,
                      max = starts$df$date$date_max,
                      start = starts$df$date$date_min, #date_start$value,
                      end = starts$df$date$date_max #date_end$value
                       ),
      selectizeInput(inputId = 'filtr_debate_title', label = "Debate' filter",
                     choices = title_cs$choices, multiple = TRUE,
                     selected = title_cs$selected),
      selectInput(inputId = 'filtr_term_of_office', label = 'Term of office',
                  choices = terms$term,
                  selected = term_chocies$term)
    )
  })
  
  output$ui <- renderUI({
    
    if (input$showpanel) {
      sidebarLayout(
        mainPanel(uiOutput('tabs')),
        uiOutput('filters')
      )
    } else {
      uiOutput('tabs')
    }
  })
  

  
  source(file.path("server","download_button.R"), local = TRUE)$value
}
