



ui <- fluidPage(
    h2("MEPs' Speeches in Plenary"),
    HTML("<h4><i>Find out what your MEP says in the European Parliament</i></h4>"),
    br(),
    
    div(
      bsButton("showpanel", "Filters", type = "toggle", value = TRUE,
               style = 'info', size = 'small'), 
      style="float:right"),

    uiOutput('ui'),
    
    p('Created by', HTML(createLink('https://www.linkedin.com/in/szymon-g%C3%B3rka-44768a14b/','Szymon Górka')),
      'in collaboration with', HTML(createLink('http://mi2.mini.pw.edu.pl/','MI^2 Group' )),'and',
      HTML(createLink('https://mamprawowiedziec.pl/','MamPrawoWiedziec.pl. ' ) )) 
    
 
  
)
