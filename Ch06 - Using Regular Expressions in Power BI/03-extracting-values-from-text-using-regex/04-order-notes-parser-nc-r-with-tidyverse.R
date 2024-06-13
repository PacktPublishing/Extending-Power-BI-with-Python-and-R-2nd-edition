library(dplyr)
library(lubridate)
library(nc)
library(readxl)

path      <- "<your-path>/Extending-Power-BI-with-Python-and-R-2nd-edition/Ch06 - Using Regular Expressions in Power BI/OrderNotes.xlsx"
dataset   <- read_xlsx(path)
notes_vec <- dataset %>% pull(Notes)
glue      <- function(x, y, ...){
    
    if(missing(y)){
        list("^", x, "$")
    }else{
        glue(list(x, list(" - | |"), y), ...)
    }
}

pattern <- alternatives_with_shared_groups(
    
    # Define a regex for each entity to be matched in the notes
    currency       = "EUR|\u20ac", # \u20ac is the unicode representation of '€'
    RefundAmount   = list(r'(\d{1,}\.?\d{0,2})', as.numeric),
    RefundReason   = "[A-Za-z ]+?",
    RefundDate     = list("[0-9]{2}/[0-9]{2}/[0-9]{4}", function(d) dmy(d)),
    
    # Define each occurrence of the template to match
    glue(currency,     RefundAmount, RefundReason, RefundDate),
    glue(RefundAmount, currency,     RefundReason, RefundDate),
    glue(RefundDate,   currency,     RefundAmount, RefundReason),
    glue(RefundDate,   RefundAmount, currency,     RefundReason)
)

matches <- capture_first_vec(notes_vec, pattern) %>% as_tibble()
df      <- bind_cols(dataset, matches) %>%
    select(
        OrderNumber,
        Notes,
        RefundAmount,
        RefundReason,
        RefundDate
    )
