predict_next_word <- function(input_text){
        
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
        
        if( input_text == "" ){
                # If nothing entered, show 3 frequent words from unigram
                sqldf("
                      SELECT ngram AS Prediction
                      FROM dt1
                      ORDER BY count DESC
                      LIMIT 3")
                
        }     
        
        # Prepare text transformation of input text
        
        input1 <- word(input_text, -1)
        input2 <- paste(
                word(input_text, -2), 
                word(input_text, -1), 
                sep = " ")
        
        # Prediction
        
        if( input_text == "" ){
                # If nothing entered, show 3 frequent words from unigram
                sqldf("
                      SELECT ngram AS Prediction
                      FROM dt1
                      ORDER BY count DESC
                      LIMIT 3")
                
        }     
        
        else if( any(dt3$base == input2) ){
                
                # if input2 is found in dtTri.base then..
                # Show 3 suggested third words, ordered
                fn$sqldf("
                      SELECT prediction AS Prediction
                      FROM dt3
                      WHERE base = '$input2'
                      ORDER BY count DESC
                      LIMIT 3
                      ")    
                
        }
        else if( any(dt2$base == input1) ){
                
                # else if input1 is found in dtBi.base then..
                # If no match in trigram, show 3 suggested second words
                fn$sqldf("
                      SELECT prediction AS Prediction
                      FROM dt2
                      WHERE base = '$input1'
                      ORDER BY count DESC
                      LIMIT 3
                      ")   
                
        }
        
        else{
                # else
                # If no matches for word, show 3 frequent words from unigram
                sqldf("
                      SELECT ngram AS Prediction
                      FROM dt1
                      ORDER BY count DESC
                      LIMIT 3")
                
        }
        
        
        
}