library(arrow)
library(dplyr)

main_path <- r"{C:\<your-source-path>\AirOnTimeCSV}"

ds <- open_dataset(main_path, format = "csv")

mean_dep_delay_df <- ds %>% 
  select( YEAR, MONTH, DAY_OF_MONTH, ORIGIN, DEP_DELAY ) %>% 
  group_by( YEAR, MONTH, DAY_OF_MONTH, ORIGIN ) %>% 
  summarise( DEP_DELAY = mean(DEP_DELAY, na.rm = T) ) %>% 
  collect() %>% 
  ungroup()

readr::write_csv(mean_dep_delay_df, file = r'{C:\<your-destination-path>\mean_dep_delay_df.csv}', eol = '\r\n')
