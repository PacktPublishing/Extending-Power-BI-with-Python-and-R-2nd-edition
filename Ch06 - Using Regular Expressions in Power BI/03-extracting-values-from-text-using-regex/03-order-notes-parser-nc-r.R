

library(nc)

library(readxl)
dataset <- read_xlsx(r"{C:\Users\lucazav\OneDrive\MVP\PacktBook\Code\Extending-Power-BI-with-Python-and-R-2nd-edition\Ch06 - Using Regular Expressions in Power BI\OrderNotes.xlsx}")

notes_vec <- dataset$Notes

glue <- function(x, y, ...){
  
  if(missing(y)){
    list("^", x, "$")
  }else{
    glue(list(x, list(" - | |"), y), ...)
  }
}

pattern <- nc::alternatives_with_shared_groups(
  
  # Define a regex for each entity to be matched in the notes
  currency="EUR|\u20ac",              # \u20ac is the unicode representation of '€'
  amount=list(r"{\d{1,}\.?\d{0,2}}", as.numeric),
  reason="[A-Za-z ]+?",
  date=list(
    "[0-9]{2}/[0-9]{2}/[0-9]{4}",
    function(d) data.table::as.IDate(d, format="%d/%m/%Y")),
  
  # Define each occurrence of the template to match
  glue(currency, amount, reason, date),
  glue(amount, currency, reason, date),
  glue(date, currency, amount, reason),
  glue(date, amount, currency, reason)
)

match.dt <- nc::capture_first_vec(notes_vec, pattern)
print(match.dt, class=TRUE)
