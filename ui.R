library(shiny)
require(readr)
require(dplyr)
require(quanteda)
require(readtext)
require(data.table)
require(sqldf)
require(stringr)


# Define UI for application that predicts next word
shinyUI(fluidPage(
        
        # Application title
        titlePanel("FastBoard: Next Word Prediction"),
        
        # Sidebar with a text input
        sidebarLayout(
                
                # Input: text
                sidebarPanel(
                        
                        textInput("input_text", "Start the sentence.."),
                        submitButton("Submit")
                ),
                
                # Main panel for displaying output
                mainPanel(
                        
                        # Show tabs with next word prediction and user guide
                        tabsetPanel(type = "tabs",
                                    tabPanel("Top 3 Predicted Next Words",
                                             tableOutput("predictionTable")),
                                    tabPanel("FastBoard: User Guide",
                                             h4("Predict the next word"),
                                             h5("How to use"),
                                             "Enter some words in the text field in the left pane and press the Submit button.",
                                             br(),
                                             br(),
                                             "The table will take a second to load.",
                                             br(),
                                             br(),
                                             h5("About the application"),
                                             "The prediction shows the three most likely next words. The model has been developed through the use of a large corpus (texts) from Twitter, blogs and news sources.",
                                             br(),
                                             br(),
                                             "The application is a deliverable in the course Data Science Capstone from Johns Hopkins University from Coursera. The FastBoard application is a completely fictional product."
                                             
                                    ))
                )
        )
))
