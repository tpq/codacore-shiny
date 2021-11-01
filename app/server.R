server <- function(input, output) {
  
  # This REACTIVE will prepare INPUT data for codacore to run
  ready_x <- reactive({
    
    if(input$data == "Crohn"){
      
      dat <- codacore::Crohn
      x <- dat[,-ncol(dat)]
      
    }else if(input$data == "HIV"){
      
      stop("Sorry, this is not yet implemented!")
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
      
      stop("Sorry, this is not yet implemented!")
    }
    
    return(y)
  })
  
  # This REACTIVE runs codacore when the ACTION button is clicked
  run_codacore <- eventReactive(input$goButton, {
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
  
  # NOTE: I am not yet sure how to run this only when model is training...
  output$alert <- renderText({
    "(Please be patient while model runs...)"
  })
}
