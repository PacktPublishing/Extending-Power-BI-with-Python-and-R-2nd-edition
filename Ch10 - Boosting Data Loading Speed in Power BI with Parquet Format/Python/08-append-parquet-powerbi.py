# %%
import os
import pandas as pd
import dask.dataframe as dd

# %%
to_append_main_path = 'C:\\Datasets\\AirOnTimeCSVtoAppend'
csv_destination_path = 'C:\\Datasets\\AirOnTimeCSV'
partitioned_data_path = 'C:\\Datasets\\AirOnTimePowerBI'

# Check if there are any csv files in the folder
files = os.listdir(to_append_main_path)
csv_files = [file for file in files if file.lower().endswith(".csv")]

if len(csv_files) > 0:

    # Append new CSV files to the Parquet
    to_append_ddf = dd.read_csv(
        os.path.join(to_append_main_path, 'airOT*.csv'),
        encoding='latin-1',
        usecols =['YEAR', 'MONTH', 'DAY_OF_MONTH', 'ORIGIN', 'DEP_DELAY'],
        dtype={'YEAR': 'int64', 'MONTH': 'int64', 'DAY_OF_MONTH': 'int64', 'ORIGIN': 'string', 'DEP_DELAY': 'float64'}
    )

    to_append_ddf.to_parquet(path=partitioned_data_path,
                            partition_on=['YEAR'],
                            append=True)

    # Move appended CSV file to the historical data folder
    for file in csv_files:
        
        # Construct the full path to the file
        file_path = os.path.join(to_append_main_path, file)

        # Construct the full path to the destination file
        destination_path = os.path.join(csv_destination_path, file)
        
        # Rename the file to include the full path to the destination
        os.rename(file_path, destination_path)

# %%
dummy_df = pd.DataFrame()
