library(arrow)
library(dplyr)

partitioned_data_path <- r'{C:\Datasets\AirOnTimePowerBI\}'

partitioned_ds <- open_dataset(partitioned_data_path,
                               format = "parquet",
                               partitioning = hive_partition())

# today <- Sys.Date()
# last_day_of_previous_month <- as.Date(format(today, "%Y-%m-01")) - 1
# last_day_of_2_months_ago <- as.Date(format(last_day_of_previous_month, "%Y-%m-01")) - 1
# selected_year <- as.numeric( format(last_day_of_2_months_ago, "%Y") )
# selected_month <- as.integer( format(last_day_of_2_months_ago, "%m") )

selected_year <- 2012
selected_month <- 11

max_dep_delay_latest_2_months_tbl <- partitioned_ds %>% 
  select( YEAR, MONTH, DAY_OF_MONTH, ORIGIN, DEP_DELAY ) %>% 
  filter( YEAR >= selected_year & MONTH >= selected_month ) %>% 
  group_by( YEAR, MONTH, DAY_OF_MONTH, ORIGIN ) %>% 
  summarise( DEP_DELAY_MAX = max(DEP_DELAY, na.rm = T) ) %>% 
  collect() %>% 
  ungroup()
