# %%
import os
import dask.dataframe as dd
from dask.diagnostics import ProgressBar

# %%
main_path = 'C:\\Datasets\\AirOnTimeCSV'

# %%
ddf = dd.read_csv(
    os.path.join(main_path, 'airOT*.csv'),
    encoding='latin-1',
    usecols =['YEAR', 'MONTH', 'DAY_OF_MONTH', 'ORIGIN', 'DEP_DELAY']
)

# %%
flights_1999_2000_ddf = ddf.loc[(ddf['YEAR'].isin([1999, 2000]))]

max_dep_delay_by_day_1999_2000_ddf = flights_1999_2000_ddf.groupby(['YEAR', 'MONTH', 'DAY_OF_MONTH', 'ORIGIN'])[['DEP_DELAY']].max().reset_index()

# %%
with ProgressBar():
    max_dep_delay_by_day_df = max_dep_delay_by_day_1999_2000_ddf.compute()

# %%
max_dep_delay_by_day_df.head(10)

# %%
