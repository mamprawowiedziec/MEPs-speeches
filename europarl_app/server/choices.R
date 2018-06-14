
national_party_cs <- reactiveValues()
mep_cs <- reactiveValues()
date_start <- reactiveValues(value = NULL)
date_end <- reactiveValues(value = NULL)
title_cs <- reactiveValues()
term_cs <- reactiveValues()

observe({
  
  #cat('chocies ', head(choices_update$national_party[[1]]), '\n')
  if(is.null(choices_update$national_party)) {
    national_party_cs$selected <- sort(starts$df$national_party)
    national_party_cs$choices  <- choices$national_party
  } else {
    national_party_cs$selected <- choices_update$national_party[[2]]
    national_party_cs$choices <- choices_update$national_party[[1]]
  }
  
  # mep
  if(FALSE) {
    cat('mep start\n')
    cat('mep:', head(choices_update$mep[[1]]), '\n' )
    mep_cs$selected <- sort(starts$df$mep)
    mep_cs$choices  <- choices$mep
  } else {
    mep_cs$selected <- choices_update$mep[[2]]
    mep_cs$choices <- choices_update$mep[[1]]
  }

    # title
    if(is.null(choices_update$titles)) {
      title_cs$selected <- sort(starts$df$title)
      title_cs$choices  <- choices$title
    } else {
      title_cs$selected <- choices_update$titles[[2]]
      title_cs$choices <- choices_update$titles[[1]]
    }
    # date

    if(is.null(choices_update$date_start)) {
      date_start$value <- starts$df$date$date_min
    } else {
      date_start$value <- ymd(choices_update$date_start)
    }
    if(is.null(choices_update$date_end)) {
      date_end$value <- starts$df$date$date_max
    } else {
      date_end$value <- ymd(choices_update$date_end)
      
    }
  #cat('\t\n data end:', glimpse(date_end$value), '\n')
})

