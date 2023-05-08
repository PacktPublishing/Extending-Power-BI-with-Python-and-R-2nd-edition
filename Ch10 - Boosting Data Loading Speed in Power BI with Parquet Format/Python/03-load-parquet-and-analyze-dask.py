# %%
import os
import dask.dataframe as dd
from dask.diagnostics import ProgressBar

# %%
main_path = os.path.join('C:\\', 'Datasets', 'AirOnTimeParquetDask')

ddf = dd.read_parquet(path=os.path.join(main_path, '*'))

# %%
max_dep_delay_ddf = ddf.groupby(['YEAR', 'MONTH', 'DAY_OF_MONTH', 'ORIGIN'])[['DEP_DELAY']].max().reset_index()

# %%
with ProgressBar():
    max_dep_delay_df = max_dep_delay_ddf.compute()

# %%
max_dep_delay_df.head(10)

# %%
filters = [
    ("YEAR", "in", [1999, 2000])
]

flights_1999_2000 = dd.read_parquet(path=os.path.join(main_path, '*'),
                                    filters=filters)

# %%
max_dep_delay_1999_2000_ddf = flights_1999_2000.groupby(['YEAR', 'MONTH', 'DAY_OF_MONTH', 'ORIGIN'])[['DEP_DELAY']].max().reset_index()


# %%
with ProgressBar():
    max_dep_delay_1999_2000_df = max_dep_delay_1999_2000_ddf.compute()

# %%
max_dep_delay_1999_2000_df.head(10)

# %%
main_path_partitioned = os.path.join('C:\\', 'Datasets', 'AirOnTimeParquetPartitionedDask')

filters = [
    ("YEAR", "in", [1999, 2000])
]

flights_1999_2000_partitioned_ddf = dd.read_parquet(path=os.path.join(main_path_partitioned, '**'),
                                                    index='YEAR',
                                                    filters=filters)

# %%
max_dep_delay_1999_2000_partitioned_ddf = flights_1999_2000_partitioned_ddf.groupby(['YEAR', 'MONTH', 'DAY_OF_MONTH', 'ORIGIN'])[['DEP_DELAY']].max().reset_index()

# %%
with ProgressBar():
    max_dep_delay_by_day_df = max_dep_delay_1999_2000_partitioned_ddf.compute()

# %%
