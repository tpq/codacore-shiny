server <- function(input, output) {
  
  # This REACTIVE will prepare INPUT data for codacore to run
  ready_x <- reactive({
    
    if(input$data == "Crohn"){
      
      dat <- codacore::Crohn
      x <- dat[,-ncol(dat)]
      
    }else if(input$data == "HIV"){
      
      dat <- codacore::HIV
      x <- dat[,1:(ncol(dat)-2)]
    }
    
    if(input$zerostrat == "Offset"){
      
      x[x==0] <- min(x[x!=0])
    }
    
    return(x)
  })
  
  # This REACTIVE will prepare TARGET data for codacore to run
  ready_y <- reactive({
    
    if(input$data == "Crohn"){
      
      dat <- codacore::Crohn
      y <- dat[,ncol(dat)]
      
    }else if(input$data == "HIV"){
      
      dat <- codacore::HIV
      y <- dat[,ncol(dat)]
    }
    
    return(y)
  })
  
  # This REACTIVE runs codacore when the ACTION button is clicked
  run_codacore <- eventReactive(input$goButton, {
    
    notify_patience <-
      showNotification("Please be patient while the model is training...",
                       type = "message", duration = NULL, closeButton = FALSE)
    on.exit(removeNotification(notify_patience), add = TRUE)
    
    
    codacore::codacore(
      ready_x(), ready_y(),
      logRatioType = input$logRatioType, lambda = input$lambda
    )
  })
  
  # This REACTIVE will print a summary of the model
  output$codacore_summary <- renderPrint({
    res <- run_codacore()
    print("Overview of CodaCore fit")
    print(res)
  })
  
  output$codacore_boxplot <- renderPlot({
    res <- run_codacore()
    plot(res, input$ratio_select)
  })
}
