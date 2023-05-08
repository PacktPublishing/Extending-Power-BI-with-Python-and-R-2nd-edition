# %%
import os
import dask.dataframe as dd
from dask.diagnostics import ProgressBar

# %%
# Get the path to the folder containing all the CSV files
# (update it according to your folders structure)
main_path = os.path.join('C:\\', 'Datasets', 'AirOnTimeCSV')

# %%
ddf = dd.read_csv(
    os.path.join(main_path, 'airOT*.csv'),
    encoding='latin-1',
    usecols =['YEAR', 'MONTH', 'DAY_OF_MONTH', 'ORIGIN', 'DEP_DELAY']
)

# %%
with ProgressBar():
    ddf.to_parquet(path=r'C:\Datasets\AirOnTimePowerBI',
                   partition_on=['YEAR'],
                   overwrite=True)

# %%
