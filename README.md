# enron_nlp
A collection of things helpful to working with the Enron Emails data set from Kaggle made available by William Cukierski. This data can be accessed at https://www.kaggle.com/wcukierski/enron-email-dataset/data.  

## How to use
Option 1: copy and paste the functions directly (more complicated)

Option 2: download the file into your target directory and import the functions with the `source()` function.
  Example:
  `source("enron_nlp.R")`
  Then you would be able to use the functions just like any other function from a library.
  
---

### Functions:

#### parse_enron 
`parse_enron(readfile, fraction=1, write=FALSE, writefile='')`

Function to parse the raw emails into email text and associated characteristics. 

Arguments:
  * required:
    * readfile - str - file path, including file name, of the emails data
  * optional:
    * fraction - number, 0 <= x <= 1 - the sample fraction of the data; default 1
    * write - boolean - whether to write a csv instead of returning it; default FALSE
    * writefile - the writepath of the file to be written; default ''
    
Columns are:

  * message.num - int -the unique numerical message ID
  * message.id - str - the full message ID (...which you may or may not want. Easy to delete)
  * person - str - the owner of the email
  * date - R date object - the email's timestamp
  * from - char list of from addresses or "None"; access by unlisting
  * to - char list of to addresses or "None"; access by unlisting
  * subject - str - the subject of the email
  * cc - char list of Cc'd emails; access by unlisting
  * bcc - char list of Bcc'd emails; access by unlisting
  * text - str - the full body of the message with email chain parts removed
  
 #### parsed_enron_words

`parsed_enron_words(data,remove_stopwords=TRUE)`

Function that returns a tidy tibble of words in the enron dataset along with associated metadata for each word.

Arguments:
  * required:
    * data - tibble 
  * optional:
    * stop - boolean - whether to remove stopwords or not; default FALSE
    
Columns include all original columns from parsed dataset, new columns are:

  * word - str - individual word
  
