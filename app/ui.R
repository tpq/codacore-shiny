ui <- fluidPage(
  
  # Application title
  titlePanel("CodaCore GUI"),
  
  sidebarPanel(
    
    helpText("Adjust these inputs to train the CodaCore model"),
    radioButtons("data",
                 label = "Select data set to use",
                 choices = c("Crohn", "HIV", "Use your own")),
    
    conditionalPanel(
      condition = "input.data == 'Use your own'",
      helpText("Upload two CSV files. The first, called X,",
               "should contain compositional data with the",
               "columns as components (e.g., OTUs). The second, called Y,",
               "should contain covariates with the first column as the target label.",
               "Any additional columns within Y will be treated as potential",
               "confounders and used to adjust the model."),
      actionButton("user_x", "Upload X"),
      actionButton("user_y", "Upload Y")
    ),
    
    radioButtons("zerostrat",
                 label = "Select zero replacement",
                 choices = c("Offset", "None")),
    
    radioButtons("logRatioType",
                 label = "Select log-ratio type",
                 choices = c("balances", "amalgam")),
    
    sliderInput("lambda",
                label = "Select sparsity",
                value = 1,
                min = 0, max = 10, step = .1),
    
    sliderInput("maxBaseLearners",
                label = "Select maximum number of models",
                value = 10, min = 1, max = 10, step = 1),
    
    radioButtons("testset",
                 label = "Select size of test set",
                 choices = c("33%", "20%", "0%")),
    
    actionButton("goButton", "Train model")
  ),
  
  mainPanel(
    
    verbatimTextOutput("codacore_summary"),
    
    conditionalPanel(
      condition = "output.codacore_summary",
      tabsetPanel(
        tabPanel(
          "Training Set Performance",
          
          numericInput("ratio_select",
                       "Which log-ratio would you like to view?",
                       min = 1,
                       value = 1),
          plotOutput("codacore_boxplot")
        )
      )
    )
  )
)
