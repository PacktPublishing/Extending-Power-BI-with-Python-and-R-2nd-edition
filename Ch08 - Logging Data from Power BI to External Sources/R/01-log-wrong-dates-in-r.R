library(readr)
library(dplyr)

dataset %>%
  filter( isDateValidFromRegex == 0 ) %>%
  write_csv( r'{D:\<your-path>\Ch08 - Logging Data from Power BI to External Sources\R\wrong-dates.csv}', eol = '\r\n' )
  

df <- dataset %>%
  filter( isDateValidFromRegex == 1 )
