library(arrow)
library(dplyr)

main_path <- r"{C:\Datasets\AirOnTimeCSV}"

ds <- open_dataset(main_path, format = "csv")


start_time <- Sys.time()

mean_dep_delay_df <- ds %>% 
  select( YEAR, MONTH, DAY_OF_MONTH, ORIGIN, DEP_DELAY ) %>% 
  group_by( YEAR, MONTH, DAY_OF_MONTH, ORIGIN ) %>% 
  summarise( DEP_DELAY = mean(DEP_DELAY, na.rm = T) ) %>% 
  collect() %>% 
  ungroup()

end_time <- Sys.time()

dim(mean_dep_delay_df)

(create_dkf_exec_time <- end_time - start_time)

head(mean_dep_delay_df, 10)
