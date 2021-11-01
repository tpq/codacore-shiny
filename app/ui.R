ui <- fluidPage(
  
  # Application title
  titlePanel("CodaCore GUI"),
  
  sidebarPanel(
    
    helpText("Adjust these inputs to train the CodaCore model"),
    radioButtons("data",
                 label = "Select data set (TO REPLACE WITH UPLOAD BUTTON)",
                 choices = c("Crohn", "HIV")),
    
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
    
    actionButton("goButton", "Train model"),
    textOutput("alert")
  ),
  
  mainPanel(
    
    verbatimTextOutput("codacore_summary"),
    
    # Only collects input once model has been trained a first time
    conditionalPanel(condition = "output.codacore_summary",
                     numericInput("ratio_select",
                                  "Which log-ratio would you like to view?",
                                  min = 1,
                                  value = 1)
    ),
    
    plotOutput("codacore_boxplot")
  )
)
