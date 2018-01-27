parsed_enron_words <- function(data, remove_stopwords = TRUE) {
  
  ### DESCRIPTION ### 
  # Function that returns a tidy tibble of words in the enron dataset.
  # Data should be output from the parsed_enron() function.
  # Arguments:
    # data - tibble output
    # stop - boolean - whether to remove stopwords or not; default FALSE
  ### DESCRIPTION ###
  
  library(tidytext)
  library(tidyverse)
  
  # create tidy tibble of words
  data <- data %>%
    unnest_tokens(word, text)
  
  
  # remove stop words
  if (remove_stopwords == TRUE) {
    data("stop_words") # stop words data from tidytext package
    data <- data %>%
      anti_join(stop_words)
  }
  
  return(data)
}
