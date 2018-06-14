

output$top_20 <- renderPlot({
  
  data <- data_table() 
  
  top20 <- data %>% 
    select(MEP, Country) %>% 
    group_by(MEP) %>% 
    count(Country)%>% 
    arrange(desc(n))  %>% 
    head(20)
  top20$MEP <- cleanLink(top20$MEP)
  cat('\n', nrow(top20), '\n')
  lim <- c(0, max(top20$n) + 5)
  p <- ggplot(top20, aes(x=reorder(MEP, n), n)) + 
    geom_bar(stat = 'identity', fill = 'deepskyblue') +
    coord_flip() + ggtitle('Top 20 speakers') + 
    ylab('Number of statements') + xlab('MEP name')+
    scale_y_continuous(expand = c(0,0), limits=lim) +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          panel.background = element_blank(), axis.line = element_line(colour = "black"),
          axis.text.x = element_text(angle = 0, hjust = 1 ),
          axis.text.y = element_text(size=10)) + ggtitle('Top 20 speakers') 
  
  return(p)
})


output$plot_nstm_countries <- renderPlot({
  
  
  load('./data/stm_country.rda')

  
  lim <- c(0, max(temp$n) + 500)
  p <- ggplot(temp,aes(x =reorder(temp$Country, temp$n), y = temp$n)) +   geom_bar(stat = "identity", fill = 'deepskyblue') +
    geom_text(aes(Country, n + 150, label = n), data = temp) +
    scale_y_continuous(expand = c(0, 0),limits = lim) + 
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          panel.background = element_blank(), axis.line = element_line(colour = "black"),
          axis.text.x = element_text(angle = 0, hjust = 1 ),
          axis.text.y = element_text(size=10)) + 
    ylab("Number of statements") +
    xlab("Country") +
    coord_flip()  + ggtitle('Number of statements by countries')
  
  return(p)
})



output$plot_nstm_lang <- renderPlot({
  
  data <- data_table()

  temp <- data %>% 
    select(Country, language_full_name) %>% 
    group_by(language_full_name) %>% 
    count()
  
  lim <- c(0, max(temp$n) + 500)
  p <- ggplot(temp,aes(x =reorder(temp$language_full_name, temp$n), y = temp$n)) +   geom_bar(stat = "identity", fill = 'dodgerblue3') +
    geom_text(aes(language_full_name, n + 150, label = n), data = temp) +
    scale_y_continuous(expand = c(0, 0),limits = lim) + 
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
          panel.background = element_blank(), axis.line = element_line(colour = "black"),
          axis.text.x = element_text(angle = 0, hjust = 1 ),
          axis.text.y = element_text(size=10)) + 
    ylab("Number of statements") +
    xlab("Language") +
    coord_flip() + ggtitle(paste0('Number of statements by languages in ', paste(input$filtr_country, collapse = ', ')))
  
  return(p)
})
