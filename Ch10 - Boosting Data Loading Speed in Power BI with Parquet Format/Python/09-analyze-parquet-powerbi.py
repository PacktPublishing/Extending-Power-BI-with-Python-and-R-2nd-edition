# %%
import os
import datetime
import pyarrow.dataset as ds

# %%
partitioned_data_path = 'C:\\Datasets\\AirOnTimePowerBI'

dataset_partitioned = ds.dataset(source=partitioned_data_path, format='parquet',
                                 partitioning='hive')

# %%
# today = datetime.date.today()
# first_day_of_this_month = datetime.date(today.year, today.month, 1)
# last_day_of_previous_month = first_day_of_this_month - datetime.timedelta(days=1)
# last_day_of_2_months_ago = (last_day_of_previous_month - datetime.timedelta(days=last_day_of_previous_month.day)) - datetime.timedelta(days=1)
# selected_year = last_day_of_2_months_ago.year
# selected_month = last_day_of_2_months_ago.month

selected_year = 2012
selected_month = 11

#print(f'{year} - {month}')

# %%
filters = (ds.field('YEAR') >= selected_year) & (ds.field('MONTH') >= selected_month)
partitioned_latest_2_months_tbl = dataset_partitioned.to_table(filter=filters)

max_dep_delay_latest_2_months_tbl = partitioned_latest_2_months_tbl.group_by(['YEAR', 'MONTH', 'DAY_OF_MONTH', 'ORIGIN']).aggregate([('DEP_DELAY', "max")])

# %%
max_dep_delay_latest_2_months_df = max_dep_delay_latest_2_months_tbl.to_pandas()