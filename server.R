library(shiny)
require(readr)
require(dplyr)
require(quanteda)
require(readtext)
require(data.table)
require(sqldf)
require(stringr)

# Load ngrams
dt1 <- readRDS(file = "data/unigram.rds")
dt2 <- readRDS(file = "data/bigram.rds")
dt3 <- readRDS(file = "data/trigram.rds")

# Prediction function
source("predict_next_word.R")

shinyServer(function(input, output) {
        
        # Clean input text in similar way as training data
        inputText <- reactive({
                
                textInput <- input$input_text
                textInput <- gsub("\\@|\\#|\\_|\\.|\\,|\\!|\\?|\\'", 
                                  "", 
                                  textInput)
                textInput <- tolower(textInput)
        })
        
        # Output three predicted words in a data table
        output$predictionTable <- renderTable({      
                predict_next_word(inputText())
                        
                })
                  
})