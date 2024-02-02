# %%
import os
import pyarrow as pa
import pyarrow.dataset as ds

# %%
def getFilePathsFromFolder(directory_path):
    # Get a list of file paths in the directory with the .csv extension
    file_paths = [os.path.join(directory_path, file_name) for file_name in os.listdir(directory_path) if os.path.isfile(os.path.join(directory_path, file_name)) and file_name.endswith('.csv')]

    return file_paths

# %%
main_path = 'C:\\Datasets\\AirOnTimeCSV'
to_append_path = 'C:\\Datasets\\AirOnTimeCSVtoAppend'

file_paths = getFilePathsFromFolder(main_path)
to_append_file_paths = getFilePathsFromFolder(to_append_path)

file_paths.extend(to_append_file_paths)

myschema = pa.schema([
    ('YEAR', pa.int64()),
    ('MONTH', pa.int64()),
    ('DAY_OF_MONTH', pa.int64()),
    ('ORIGIN', pa.string()),
    ('DEP_DELAY', pa.float64())])

dataset = ds.dataset(file_paths, format='csv', schema=myschema)

# %%
output_path = r'C:\Datasets\AirOnTimeParquetPyArrow'

ds.write_dataset(dataset, format='parquet',
                 base_dir=output_path,
                 existing_data_behavior='overwrite_or_ignore')

# %%
output_partitioned_path = r'C:\Datasets\AirOnTimeParquetPartitionedPyArrow'

ds.write_dataset(dataset, format='parquet',
                 base_dir=output_partitioned_path,
                 partitioning=['YEAR'],
                 partitioning_flavor='hive',
                 existing_data_behavior='overwrite_or_ignore')

# %%
