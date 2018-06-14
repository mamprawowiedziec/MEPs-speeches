

vars_hide <- reactiveValues(counter = 0)

output$hide_show_button <- renderUI({
  actionButton('hide_show_all',label(),style = 'padding:5px')
})
observeEvent(input$hide_show_all,{
  
  if(!is.null(input$hide_show_all)){
    input$hide_show_all
    isolate({
      if(vars_hide$counter == 0) {
        vars_hide$counter <- 1
      }
      else{
        vars_hide$counter <- 0
      }
    })
  }
})
label <- reactive({
  if(!is.null(input$hide_show_all)){
    if(vars_hide$counter == 0) label <- "Show full statements"
    else label <- "Hide full statements"
  }
})