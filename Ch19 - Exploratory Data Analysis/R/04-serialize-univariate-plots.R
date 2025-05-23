
library(ggpubr)
library(cowplot)
library(recipes)


# Load the dataset with proper column data types
folder <- r'{C:\<your-path>\Ch19 - Exploratory Data Analysis}'

init_path <- file.path(folder, r'{R\00-init-dataset.R}', fsep = '\\')

# If tha tibble is already in memory, don't load it sourcing an external script
if(!exists('tbl', mode='list')) {
  print('Loading data sourcing external script.')
  source(init_path)
}


yeo_johnson_transf <- function(data) {
  
  rec <- recipe(data, as.formula(' ~ .'))
  
  rec <- rec %>%
    step_center( all_numeric() ) %>%
    step_scale( all_numeric() ) %>%
    step_YeoJohnson( all_numeric() )
  
  prep_rec <- prep( rec, training = data )
  
  res_list <- list( df_yeojohnson = bake( prep_rec, data ),
                    lambdas = prep_rec$steps[[3]][["lambdas"]] )
}


histdensity <- function(data, col_name, col_transf_type = 'standard', bins = 30) {
  
  # Transform all numeric columns according to Yeo-Johnson
  yeo_johnson_list <- data %>% 
    yeo_johnson_transf()
  
  transf_data <- yeo_johnson_list$df_yeojohnson
  
  
  if (col_transf_type == 'yeo-johnson') {
    
    col_vec <- transf_data[[col_name]]
    col_label <- paste0('YeoJohnson(', col_name, ')')
    
  } else {
    
    col_vec <- data[[col_name]]
    col_label <- col_name
    
  }
  
  data[[col_name]] <- col_vec
  
  
  phist <- data %>% gghistogram(
    x = col_name, bins = bins, color = '#377EB8', fill = '#377EB8', alpha = .4,
    rug = TRUE, xlab = col_label
  )
  
  pdensity <- data %>% ggdensity(
    x = col_name, color = '#E41A1C', size = 1.2, alpha = 0
  ) +
    scale_y_continuous(expand = expansion(mult = c(0, 0.05)), position = 'right')  +
    theme_half_open(11, rel_small = 1) +
    rremove('x.axis')+
    rremove('xlab') +
    rremove('x.text') +
    rremove('x.ticks') +
    rremove('legend')
  
  aligned_plots <- align_plots(phist, pdensity, align = 'hv', axis = 'tblr')
  
  ggdraw(aligned_plots[[1]]) + draw_plot(aligned_plots[[2]])
  
}


raincloud <- function(data, col_name, col_transf_type = 'standard') {
  
  # Transform all numeric columns according to Yeo-Johnson
  yeo_johnson_list <- data %>% 
    yeo_johnson_transf()
  
  transf_data <- yeo_johnson_list$df_yeojohnson
  
  
  if (col_transf_type == 'yeo-johnson') {
    
    col_vec <- transf_data[[col_name]]
    col_label <- paste0('YeoJohnson(', col_name, ')')
    
  } else {
    
    col_vec <- data[[col_name]]
    col_label <- col_name
    
  }
  
  data[[col_name]] <- col_vec
  
  
  pbox <- ggboxplot(
    data = data,
    y = col_name,
    width = .5, 
    outlier.shape = NA
  ) +
    geom_point(
      size = 1.3,
      alpha = .2,
      position = position_jitter(
        seed = 1, width = .2
      ),
      color = '#377EB8'
    ) +
    theme_minimal_vgrid(11, rel_small = 1) +
    theme(axis.title.y=element_blank(),
          axis.text.y=element_blank(),
          axis.ticks.y=element_blank(),
          axis.line.y = element_blank()) +
    labs(
      x = col_label
    ) +
    coord_flip(xlim = c(1.5, NA))
  
  
  pdensity <- ggplot(data, aes_string(x = NA, y = col_name)) + 
    ggdist::stat_halfeye(
      adjust = 0.5, 
      width = 0.5, 
      .width = 0, 
      justification = -.7, 
      point_colour = NA,
      fill = '#377EB8',
      alpha = .5) +
    theme_half_open(11, rel_small = 1) +
    rremove('x.axis')+
    rremove('xlab') +
    rremove('x.text') +
    rremove('x.ticks') +
    rremove('y.axis')+
    rremove('ylab') +
    rremove('y.text') +
    rremove('y.ticks') +
    rremove('legend') +
    coord_flip()
  
  
  aligned_plots <- align_plots(pbox, pdensity, align = 'hv', axis = 'tblr')
  
  ggdraw(aligned_plots[[1]]) + draw_plot(aligned_plots[[2]])
}


barchart <- function(data, col_name, col_transf_type = 'standard', max_factors = 15) {
  
  # Transform all numeric columns according to Yeo-Johnson
  yeo_johnson_list <- data %>% 
    yeo_johnson_transf()
  
  transf_data <- yeo_johnson_list$df_yeojohnson
  
  
  if (col_transf_type == 'yeo-johnson') {
    
    col_vec <- transf_data[[col_name]]
    col_label <- paste0('YeoJohnson(', col_name, ')')
    
  } else {
    
    col_vec <- data[[col_name]]
    col_label <- col_name
    
  }
  
  data[[col_name]] <- col_vec
  
  
  aggr_tbl <- data %>%
    group_by(across(all_of(col_name))) %>% 
    summarise(Freq = n()) %>%
    mutate(Perc = Freq/sum(Freq))
  
  num_max_rows_to_show <- max_factors
  
  if (dim(aggr_tbl)[1] > num_max_rows_to_show) {
    
    aggr_to_show_tbl <- aggr_tbl %>% 
      arrange(desc(Freq), {{col_name}}) %>% 
      head(num_max_rows_to_show) %>% 
      bind_rows(
        (aggr_tbl %>% arrange(desc(Freq), {{col_name}}))[(num_max_rows_to_show + 1):dim(aggr_tbl)[1],] %>% 
          summarise(
            !!quo_name(col_name) := 'others',
            Freq = sum(Freq, na.rm = TRUE),
            Perc = sum(Perc, na.rm = TRUE)
          )
      )
  } else {
    
    aggr_to_show_tbl <- aggr_tbl
    
  }
  
  # Reorder factor levels so that the bars will be also ordered based on Freq
  aggr_to_show_tbl[[col_name]] <- factor(aggr_to_show_tbl[[col_name]])
  aggr_to_show_tbl[[col_name]] <- forcats::fct_reorder(aggr_to_show_tbl[[col_name]], aggr_to_show_tbl[['Freq']], .desc = FALSE)
  
  aggr_to_show_tbl %>%
    ggbarplot(x = col_name, y = 'Freq',
              color = '#377EB8', fill = '#377EB8', alpha = .5,
              label = with(aggr_to_show_tbl, paste(Freq, paste0('(', round(Perc * 100), '%)'))),
              lab.pos = 'out', lab.hjust = -0.2, xlab = col_label) +
    coord_flip( ylim = c(0, max(aggr_to_show_tbl[['Freq']]) * 12 / 11))
  
}



# Get data type of each column
col_types <- sapply(tbl, class)

# Define empty lists
histodensity_lst <- list()
barchart_lst <- list()
histodensity_transf_lst <- list()
barchart_transf_lst <- list()

# Populate lists with plots
for (col_name in names(col_types)) {
  
  if (col_types[col_name] %in% c('integer', 'numeric')) {
    p1 <- histdensity(data = tbl, col_name = col_name, bins = 30)
    p2 <- raincloud(data = tbl, col_name = col_name)
    
    histodensity_lst[[col_name]] <- plot_grid(p1, p2, ncol = 1, align = 'v')
    
    p1 <- histdensity(data = tbl, col_name = col_name, col_transf_type = 'yeo-johnson', bins = 30)
    p2 <- raincloud(data = tbl, col_name = col_name, col_transf_type = 'yeo-johnson')
    
    histodensity_transf_lst[[col_name]] <- plot_grid(p1, p2, ncol = 1, align = 'v')
  }
  
  if (col_types[col_name] %in% c('integer', 'character', 'factor')) {
    
    p <- barchart(data = tbl, col_name = col_name)
    
    barchart_lst[[col_name]] <- p
    
  }
  
}

# Serialize the lists of plots
saveRDS(histodensity_lst, file.path(folder, r'{Demo\histodensity_lst.rds}', fsep = '\\'))
saveRDS(histodensity_transf_lst, file.path(folder, r'{Demo\histodensity_transf_lst.rds}', fsep = '\\'))
saveRDS(barchart_lst, file.path(folder, r'{Demo\barchart_lst.rds}', fsep = '\\'))


# For each numeric column add two transformation types: standard and yeo-johnson.
# The result is a cross join dataframe.
numeric_df <- tidyr::crossing(
  numeric_col_name = names(histodensity_lst),
  transf_type = c('standard','yeo-johnson'))

categorical_df <- data.frame(categorical_col_name = names(barchart_lst))
