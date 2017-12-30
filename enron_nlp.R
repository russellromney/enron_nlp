### enron_nlp.R
# This script contains functions helpful to working in R with the Enron emails
# dataset from Kaggle.

parse_enron <- function(readfile, fraction=1, write=FALSE, writefile='') {
  
  ### DESCRIPTION ###
  # Function to parse the Enron emails dataset from Kaggle as provided by 
  # William Cukierski. This data can be found at:
  # https://www.kaggle.com/wcukierski/enron-email-dataset/data
  
  # Function arguments:
    # required:
      # readfile - str - file path, including file name, of the emails data
    # optional:
      # fraction - number, 0 <= x <= 1 - the sample fraction of the data; default 1
      # write - boolean - whether to write a csv instead of returning it; default FALSE
      # writefile - the writepath of the file to be written; default ''
  
  # The function returns a tidy tibble of parsed emails with the following columns:
    # message.num - int -the unique numerical message ID 
    # message.id - str - the full message ID (which you may or may not want. Easy to delete)
    # person - str - the owner of the email
    # date - R date object - the email's timestamp
    # from - char list of from addresses or "None"; access by unlisting
    # to - char list of to addresses or "None"; access by unlisting
    # subject - str - the subject of the email
    # cc - char list of Cc'd emails; access by unlisting
    # bcc - char list of Bcc'd emails; access by unlisting
    # text - str - the full body of the message with email chain parts removed
  ### DESCRIPTION ### 
  
  library(tidyverse)
  library(tidytext)
  
  ##### import data
  data = read_csv(readfile, na = c("NA"))
  set.seed(101)
  
  # sample data according to input needs
  if (fraction < 1) {
    data = sample_frac(data, size = fraction)
  }
  
  
  
  ##### Parse emails
  
  # split email headers from email body, find person
  temp = tibble(
    message.num = 0:length(data$file),
    person = NA,
    header = NA,
    text = NA
  )
  i = 1
  while (i <= length(temp$message.num)) {
    this = str_split(
      data$message[i],
      pattern = "X-FileName.*",
      n = 2,
      simplify = TRUE
    )
    temp$person[i] = str_split(data$file[i],
                               pattern = '/',
                               n = 2,
                               simplify = T)[1]
    temp$header[i] <- this[1]
    temp$text[i] <- this[2]
    rm(this)
    i = i + 1
  }
  
  # clear memory
  remove(data)
  
  
  # drop NA from temp
  temp <- temp %>%
    drop_na()
  
  # define parsing function
  header.parse <- function(header) {
    # parse the header for data
    message.id <-
      str_sub(str_extract(header, "Message\\-ID.*"), start = 13)
    date <- str_sub(str_extract(header, "Date:.*"), start = 7)
    from <- str_sub(str_extract(header, "From:.*"), start = 7)
    to <- str_sub(str_extract(header, "To:.*"), start = 5)
    subject <-
      str_sub(str_extract(header, "Subject:.*"), start = 10)
    cc <- str_sub(str_extract(header, "X\\-cc:.*"), start = 7)
    bcc <- str_sub(str_extract(header, "X\\-bcc:.*"), start = 8)
    #create tibble from the parsed data
    parsed <- tibble(
      message.id = message.id,
      date = date,
      from = from,
      to = to,
      subject = subject,
      cc = cc,
      bcc = cc
    )
    
    return(parsed)
  }
  
  
  # parse the text data
  parsed = header.parse(temp$header)
  
  
  # define a text cleaning function
  cleanr <- function(text) {
    return(str_replace_all(
      str_replace_all(tolower(
        str_replace(text, "To:(.*\n)*Subject:.*", " ")
      ),
      "[^a-zA-Z\\s]", " "),
      "[\\s]+",
      " "
    ))
  }
  
  
  # define function to clean message.id
  just.numbers <- function(message.id) {
    return(str_replace_all(str_replace_all(message.id, "[^0-9]", " "),
                           "\\s", ""))
  }
  
  
  # implemeent the function to clean the data
  temp$text <- cleanr(temp$text) # clean all text data
  parsed$subject <-
    cleanr(parsed$subject) # clean the email subjects
  parsed$message.id <- just.numbers(parsed$message.id)
  
  
  # change date format to correct dplyr version to avoid error
  parsed$date <-
    as.POSIXct(strptime(parsed$date, format = "%a, %d %b %Y %H:%M:%S %z"),
               format = "%a, %d %b %Y %H:%M:%S %z")
  
  
  # create the final parsed tibble
  parsed <- tibble(
    message.num = temp$message.num,
    message.id = parsed$message.id,
    person = temp$person,
    date = parsed$date,
    from = parsed$from,
    to = parsed$to,
    subject = parsed$subject,
    cc = parsed$cc,
    bcc = parsed$bcc,
    text = temp$text
  )
  
  
  # clear memory
  remove(temp)
  
  
  # change NA values to "None"
  parsed[is.na(parsed)] <- "None" # replace NA values with "None" values
  
  
  
  ##### Finish up

  if(write==TRUE){
    # write file
    write_csv(enron, writefile)
    
    # clear memory
    remove(parsed)
  }
  else {
    return(parsed)
  }
}








parsed_enron_words <- function(data, remove_stopwords = TRUE) {
  
  ### DESCRIPTION ### 
  # Function that returns a tidy tibble of words in the enron dataset.
  # Data should be output from the parsed_enron() function.
  # Arguments:
    # data - tibble output
    # stop - boolean - whether to remove stopwords or not; default FALSE
  ### DESCRIPTION ###
  
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
