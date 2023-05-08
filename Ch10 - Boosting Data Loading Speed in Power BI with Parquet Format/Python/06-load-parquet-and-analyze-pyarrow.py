# %%
import os
import pyarrow.dataset as ds

# %%
main_path = os.path.join('C:\\', 'Datasets', 'AirOnTimeParquetPyArrow')

dataset = ds.dataset(source=main_path, format='parquet')

# %%
tbl = dataset.to_table()
max_dep_delay_tbl = tbl.group_by(['YEAR', 'MONTH', 'DAY_OF_MONTH', 'ORIGIN']).aggregate([('DEP_DELAY', 'max')])

# %%
max_dep_delay_df = max_dep_delay_tbl.to_pandas()
max_dep_delay_df.head(10)

# %%
flights_1999_2000 = ds.dataset(source=main_path)

filters = ds.field('YEAR').isin([1999, 2000])
tbl_filtered = flights_1999_2000.to_table(filter=filters)

max_dep_delay_1999_2000_tbl = tbl_filtered.group_by(['YEAR', 'MONTH', 'DAY_OF_MONTH', 'ORIGIN']).aggregate([('DEP_DELAY', "max")])

# %%
max_dep_delay_1999_2000_df = max_dep_delay_1999_2000_tbl.to_pandas()
max_dep_delay_1999_2000_df.head(10)

# %%
main_path_partitioned = os.path.join('C:\\', 'Datasets', 'AirOnTimeParquetPartitionedPyArrow')

flights_1999_2000_partitioned = ds.dataset(source=main_path_partitioned, format='parquet',
                                           partitioning='hive')

# %%
filters = ds.field('YEAR').isin([1999, 2000])
tbl_filtered_partitioned = flights_1999_2000_partitioned.to_table(filter=filters)

max_dep_delay_1999_2000_tbl = tbl_filtered_partitioned.group_by(['YEAR', 'MONTH', 'DAY_OF_MONTH', 'ORIGIN']).aggregate([('DEP_DELAY', "max")])

# %%
max_dep_delay_1999_2000_df = max_dep_delay_1999_2000_tbl.to_pandas()
max_dep_delay_1999_2000_df.head(10)

# %%
