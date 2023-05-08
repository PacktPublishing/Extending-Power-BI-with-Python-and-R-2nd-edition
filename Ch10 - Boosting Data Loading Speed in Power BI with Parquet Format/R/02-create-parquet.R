library(arrow)
library(dplyr)

getFilePathsFromFolder <- function(directory_path) {
  # Get a list of file paths in the directory with the .csv extension
  files <- list.files(directory_path, full.names = TRUE)
  file_paths <- files[grep("\\.csv$", files, ignore.case = TRUE)]
  
  return(file_paths)
}


main_path <- r"{C:\Datasets\AirOnTimeCSV}"
to_append_path <- r"{C:\Datasets\AirOnTimeCSVtoAppend}"

file_paths = getFilePathsFromFolder(main_path)
to_append_file_paths = getFilePathsFromFolder(to_append_path)

ds <- open_dataset(c(file_paths, to_append_file_paths), format = "csv")

output_path <- r'{C:\Datasets\AirOnTimeParquetArrowR\}'

start_time <- Sys.time()

ds %>% 
  select( YEAR, MONTH, DAY_OF_MONTH, ORIGIN, DEP_DELAY ) %>% 
  write_dataset( path = output_path, format = 'parquet' )

end_time <- Sys.time()

(create_ds_exec_time <- end_time - start_time)


output_partitioned_path <- r'{C:\Datasets\AirOnTimeParquetPartitionedArrowR\}'

start_time <- Sys.time()

ds %>% 
  select( YEAR, MONTH, DAY_OF_MONTH, ORIGIN, DEP_DELAY ) %>% 
  write_dataset( path = output_partitioned_path, format = 'parquet',
                 partitioning = 'YEAR')

end_time <- Sys.time()

(create_ds_exec_time <- end_time - start_time)
