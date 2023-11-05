
library(ggplot2)
library(naniar)

# Load the dataset with proper column data types
init_path <- r'{C:\Users\lucazav\OneDrive\MVP\PacktBook\Code\Extending-Power-BI-with-Python-and-R-2nd-edition\Ch19 - Exploratory Data Analysis\R\00-init-dataset.R}'

# If tha tibble is already in memory, don't load it sourcing an external script
if(!exists('tbl', mode='list')) {
  print('Loading data sourcing external script.')
  source(init_path)
}
 
# # Uncomment this code if not in Power BI
# dataset <- tbl

gg_miss_var(tbl, show_pct = T) + 
  theme(
    axis.text = element_text(size=14)
  )
