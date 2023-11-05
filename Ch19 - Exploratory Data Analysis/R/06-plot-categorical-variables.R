
library(dplyr)
library(ggpubr)
library(cowplot)

folder <- r'{C:\Users\lucazav\OneDrive\MVP\PacktBook\Code\Extending-Power-BI-with-Python-and-R-2nd-edition\Ch19 - Exploratory Data Analysis}'

barchart_lst <- readRDS(file.path(folder, 'Demo\\barchart_lst.rds'))

# Uncomment if the script is not run in Power BI
#dataset <- data.frame(categorical_col_name = names(barchart_lst))

col_name <- (dataset %>% pull(1))[1]

barchart_lst[[col_name]]
