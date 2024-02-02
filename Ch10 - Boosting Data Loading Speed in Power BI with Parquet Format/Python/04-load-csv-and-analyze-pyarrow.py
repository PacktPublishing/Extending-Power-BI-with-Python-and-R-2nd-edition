# %%
import os
import pyarrow as pa
import pyarrow.dataset as ds
import pyarrow.compute as pc 

# %%
main_path = 'C:\\Datasets\\AirOnTimeCSV'

dataset = ds.dataset(source=main_path, format='csv')

# %%
flights_1999_2000_tbl = dataset.to_table(columns=['YEAR', 'MONTH', 'DAY_OF_MONTH', 'ORIGIN', 'DEP_DELAY'],
                                         filter=ds.field('YEAR').isin([1999, 2000]))

max_dep_delay_1999_2000_tbl = flights_1999_2000_tbl.group_by(['YEAR', 'MONTH', 'DAY_OF_MONTH', 'ORIGIN']).aggregate([('DEP_DELAY', "max")])

# %%
max_dep_delay_1999_2000_df = max_dep_delay_1999_2000_tbl.to_pandas()
max_dep_delay_1999_2000_df.head(10)

# %%
