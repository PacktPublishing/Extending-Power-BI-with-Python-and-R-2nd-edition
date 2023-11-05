
library(dplyr)
library(ggpubr)
library(cowplot)

folder <- r'{C:\Users\lucazav\OneDrive\MVP\PacktBook\Code\Extending-Power-BI-with-Python-and-R-2nd-edition\Ch19 - Exploratory Data Analysis}'

histodensity_lst <- readRDS(file.path(folder, 'Demo\\histodensity_lst.rds', fsep = '\\'))
histodensity_transf_lst <- readRDS(file.path(folder, 'Demo\\histodensity_transf_lst.rds', fsep = '\\'))

# # Uncomment if the script is not run in Power BI
# dataset <- tidyr::crossing(
#   numeric_col_name = names(histodensity_lst),
#   transf_type = c('standard','yeo-johnson'))

col_name <- (dataset %>% pull(1))[1]
dataset_type <- (dataset %>% pull(2))[1]

if (dataset_type == 'standard') {
  histodensity_lst[[col_name]]
} else {
  histodensity_transf_lst[[col_name]]
}

