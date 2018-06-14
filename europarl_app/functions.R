


# functions
createLink <- function(url, name) {
  sprintf('<a href="%s" target="_blank" >%s</a>',url, name)
}

cleanLink <- function(text) {
  text <- gsub("</a.*","", text) 
  text <- gsub(".*>","",text)
  return(text)
}

read_config <- function(name = 'db_config.txt', delim = " ") {
  
  config <- read_delim(paste0('./', name), delim = delim,
                       col_names = FALSE)
  
  config <- config[,-2]
  colnames(config) <- c('name', 'value')
  return(config)
}


#===================


killDbConnections <- function () {

  all_cons <- dbListConnections(MySQL())

 # print(all_cons)

  for(con in all_cons)
    +  dbDisconnect(con)

  print(paste(length(all_cons), " connections killed."))

}

