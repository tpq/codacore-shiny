server <- function(input, output) {
  
  # This REACTIVE will prepare INPUT data for codacore to run
  ready_x <- reactive({
    
    if(input$data == "Crohn"){
      
      dat <- codacore::Crohn
      x <- dat[,-ncol(dat),drop=FALSE]
      
    }else if(input$data == "HIV"){
      
      dat <- codacore::HIV
      x <- dat[,1:(ncol(dat)-2),drop=FALSE]
      
    }else if(input$data == "Use your own"){
      
      req(input$user_x) # req() makes server wait until upload is complete
      x <- read.csv(input$user_x$datapath, row.names = 1, header = TRUE)
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
      y <- dat[,ncol(dat),drop=TRUE]
      
    }else if(input$data == "HIV"){
      
      dat <- codacore::HIV
      y <- dat[,ncol(dat),drop=TRUE]
      
    }else if(input$data == "Use your own"){
      
      req(input$user_y) # req() makes server wait until upload is complete
      y <- read.csv(input$user_y$datapath, row.names = 1, header = TRUE)
      y <- y[,1,drop=TRUE]
    }
    
    return(y)
  })
  
  # This REACTIVE will prepare COVARIATE data for codacore to run
  ready_z <- reactive({
    
    if(input$data == "Use your own"){
      
      req(input$user_y) # req() makes server wait until upload is complete
      y <- read.csv(input$user_y$datapath, row.names = 1, header = TRUE)
      z <- y[,-1,drop=FALSE]
      
    }else{
      
      z <- data.frame()
    }
    
    return(z)
  })
  
  # This REACTIVE shows user the size of the INPUT data they uploaded
  output$xdim <- renderText({
    
    x <- ready_x()
    paste0("X data loaded. We see ", nrow(x), " observations and ",
           ncol(x), " variable(s).")
  })
  
  # This REACTIVE shows user the size of the TARGET data they uploaded
  output$ydim <- renderText({
    
    y <- ready_y()
    paste0("Y data loaded. We see ", length(y), " observations and ",
           1, " variable(s).")
  })
  
  # This REACTIVE shows user the size of the COVARIATE data they uploaded
  output$zdim <- renderText({
    
    z <- ready_z()
    if(ncol(z) > 0){
      paste0("Z data loaded. We see ", nrow(z), " observations and ",
             ncol(z), " variable(s).")
    }else{
      "Z data loaded. No covariates found."
    }
  })
  
  # This REACTIVE splits data {x, y, z} into training and test sets
  train_test_split <- reactive({
    
    # Load in data to split into train and test sets
    x <- ready_x()
    y <- ready_y()
    z <- ready_z()
    test_ratio <- as.numeric(gsub("%", "", input$testset))/100
    
    # Return NULL test set when test set % set to 0
    if(test_ratio == 0){
      
      return(
        list(
          "train_x" = x,
          "train_y" = y,
          "train_z" = z,
          "test_x" = NULL,
          "test_y" = NULL,
          "test_z" = NULL
        )
      )
      
    }else{
      
      test_index <- sample(1:nrow(x), size = floor(test_ratio * nrow(x)))
      return(
        list(
          "train_x" = x[-test_index,],
          "train_y" = y[-test_index],
          "train_z" = z[-test_index,],
          "test_x" = x[test_index,],
          "test_y" = y[test_index],
          "test_z" = z[test_index,]
        )
      )
    }
  })
  
  # This REACTIVE runs codacore when the ACTION button is clicked
  run_codacore <- eventReactive(input$goButton, {
    
    data <- train_test_split()
    
    notify_patience <-
      showNotification("Please be patient while the model is training...",
                       type = "message", duration = NULL, closeButton = FALSE)
    on.exit(removeNotification(notify_patience), add = TRUE)
    
    res <- codacore::codacore(
      x = data$train_x, y = data$train_y,
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
