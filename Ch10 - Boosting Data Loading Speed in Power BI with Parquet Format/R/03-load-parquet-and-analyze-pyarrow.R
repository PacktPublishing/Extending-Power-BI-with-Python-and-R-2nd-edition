library(arrow)
library(dplyr)

main_path <- r'{C:\Datasets\AirOnTimeParquetArrowR\}'

ds <- open_dataset(main_path, format = "parquet")


start_time <- Sys.time()

mean_dep_delay_df <- ds %>% 
  select( YEAR, MONTH, DAY_OF_MONTH, ORIGIN, DEP_DELAY ) %>% 
  group_by( YEAR, MONTH, DAY_OF_MONTH, ORIGIN ) %>% 
  summarise( DEP_DELAY = max(DEP_DELAY, na.rm = T) ) %>% 
  collect() %>% 
  ungroup()

end_time <- Sys.time()

(create_ds_exec_time <- end_time - start_time)

head(mean_dep_delay_df, 10)



start_time <- Sys.time()

mean_dep_delay_1999_2000_df <- ds %>% 
  select( YEAR, MONTH, DAY_OF_MONTH, ORIGIN, DEP_DELAY ) %>% 
  filter( YEAR %in% c(1999, 2000) ) %>%
  group_by( YEAR, MONTH, DAY_OF_MONTH, ORIGIN ) %>% 
  summarise( DEP_DELAY = max(DEP_DELAY, na.rm = T) ) %>% 
  collect() %>% 
  ungroup()

end_time <- Sys.time()

(create_ds_exec_time <- end_time - start_time)

head(mean_dep_delay_1999_2000_df, 10)


main_partitioned_path <- r'{C:\Datasets\AirOnTimeParquetPartitionedArrowR\}'

partitioned_ds <- open_dataset(main_partitioned_path, format = "parquet", partitioning = hive_partition())


start_time <- Sys.time()

mean_dep_delay_1999_2000_partitioned_df <- partitioned_ds %>% 
  select( YEAR, MONTH, DAY_OF_MONTH, ORIGIN, DEP_DELAY ) %>% 
  filter( YEAR %in% c(1999, 2000) ) %>% 
  group_by( YEAR, MONTH, DAY_OF_MONTH, ORIGIN ) %>% 
  summarise( DEP_DELAY = max(DEP_DELAY, na.rm = T) ) %>% 
  collect() %>% 
  ungroup()

end_time <- Sys.time()

(create_ds_exec_time <- end_time - start_time)

head(mean_dep_delay_1999_2000_partitioned_df, 10)
