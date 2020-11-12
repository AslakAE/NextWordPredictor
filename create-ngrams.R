library(readr)
library(dplyr)
library(quanteda)
library(readtext)
library(data.table)
options(gsubfn.engine = "R")
library(sqldf)
library(stringr)

# CAPSTONE DATASET
## url: https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip

# READ FILES
## Read the English text files
blogs <- readLines("data/final/en_US/en_US.blogs.txt", skipNul=TRUE, warn=FALSE)
twitter <- readLines("data/final/en_US/en_US.twitter.txt", skipNul=TRUE, warn=FALSE)
news <- readLines("data/final/en_US/en_US.news.txt", skipNul=TRUE, warn=FALSE)

# Sample text files, in line with recommendation for 8GB RAM Macbook Pro: https://github.com/lgreski/datasciencectacontent/blob/master/markdown/capstone-ngramComputerCapacity.md
set.seed(1337)
sampleblogs <- sample(blogs, size = length(blogs) * 0.3)
sampletwitter <- sample(twitter, size = length(twitter) * 0.3 )
samplenews <- sample(news, size = length(news) * 0.3)

sampletexts <- c(sampleblogs, sampletwitter, samplenews)

# Clean texts for symbols that quanteda won't remove
sampletexts <- gsub("\\@|\\#|\\_|\\.|\\,|\\!|\\?|\\'", "", sampletexts)

## CREATE CORPUS
# Create a corpus for every text file
corpus <- corpus(sampletexts)

## Clear memory
rm(blogs, twitter, news, sampleblogs, sampletwitter, samplenews, sampletexts)

## PREPARATION: CREATE NGRAMS AND DATA.TABLES

# Tokenize
sample <- tokens(corpus,
                 remove_punct = TRUE,
                 remove_numbers = TRUE,
                 remove_symbols = TRUE,
                 remove_separators = TRUE) 

# Clear memory
rm(corpus)

# Lowercase
sample <- tokens_tolower(sample)

# Create ngrams
unigram <- sample
bigram <- tokens_ngrams(sample, n = 2)
trigram <- tokens_ngrams(sample, n = 3)

# Clear memory and data
rm(sample)

# Create dfm
dfm_unigram <- dfm(unigram)
dfm_bigram <- dfm(bigram)
dfm_trigram <- dfm(trigram)

# Trim dfm, only keep phrases with counts higher than 5
uni <- dfm_trim(dfm_unigram, min_termfreq = 5)
bi <- dfm_trim(dfm_bigram, min_termfreq = 5)
tri <- dfm_trim(dfm_trigram, min_termfreq = 5)

# Clear memory and data
rm(unigram, bigram, trigram, dfm_unigram, dfm_bigram, dfm_trigram)

# Format as datatables and add frequency. Index included.
dtUni <- data.table(ngram = featnames(uni),
                    count = colSums(uni),
                    key = "ngram")

dtBi <- data.table(ngram = featnames(bi),
                   count = colSums(bi),
                   key = "ngram")

dtTri <- data.table(ngram = featnames(tri),
                    count = colSums(tri),
                    key = "ngram")

# Clear memory
rm(uni, bi, tri)

# Create columns:
## https://github.com/lgreski/datasciencectacontent/blob/master/markdown/capstone-simplifiedApproach.md
## given a set of n-grams that are aggregated into three columns, a base consisting of n-1 words in the n-gram, and a prediction that is the last word, and a count variable for the frequency of occurrence of this n-gram, it's easy to write an SQL statement to extract the most frequently occurring prediction and save these into an output data.table for your shiny app

# Split ngram divided by "_" into the first word and the next (predicted word)
dtBi <- dtBi[, c("base", "prediction") := tstrsplit(ngram, "_", 
                                                    fixed = TRUE)]
# Delete the old column
dtBi <- dtBi[, ngram := NULL] 

# Split ngram divided by "_" into the two first words and the third word (predicted word)
dtTri <- dtTri[, c("base1", "base2", "prediction") := tstrsplit(ngram, "_",
                                                                fixed = TRUE)]
# Set the two first words in the same column
dtTri <- dtTri[, base := do.call(paste, c(.SD, sep = " ")), 
               .SDcols = c("base1", "base2")]
# Delete old columns
dtTri <- dtTri[, c("ngram", "base1", "base2") := NULL] 

#______________________________
# Save ngrams to disk

## unigram data.table
saveRDS(dtUni, file = "data/unigram.rds")
## bigram data.table
saveRDS(dtBi, file = "data/bigram.rds")
## trigram data.table
saveRDS(dtTri, file = "data/trigram.rds")
