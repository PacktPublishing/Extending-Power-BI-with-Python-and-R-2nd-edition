
library(ggplot2)
library(naniar)

# Load the dataset with proper column data types
init_path <- r'{C:\Users\lucazav\OneDrive\MVP\PacktBook\Code\Extending-Power-BI-with-Python-and-R-2nd-edition\Ch19 - Exploratory Data Analysis\R\00-init-dataset.R}'

# If tha tibble is already in memory, don't load it sourcing an external script
if(!exists('tbl', mode='list')) {
  print('Loading data sourcing external script.')
  source(init_path)
}

gg_miss_upset(tbl, text.scale = 2)
