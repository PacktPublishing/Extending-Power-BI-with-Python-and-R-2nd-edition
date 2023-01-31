import pandas as pd

# Extract df1 from the merged dataset, selecting the
# first 4 columns, removing rows having all null values
# and removing duplicates
df1 = dataset[["CarType", "Mpg", "Cyl", "Disp"]].dropna(how='all').drop_duplicates()

# Extract df2 from the merged dataset, selecting the
# second 4 columns, removing rows having all null values,
# removing duplicates and renaming the columns like the df1 ones
df2 = dataset[["cars-02.CarType", "cars-02.Mpg", "cars-02.Cyl", "cars-02.Disp"]].dropna(how='all').drop_duplicates().\
    rename(columns={"cars-02.CarType": "CarType", "cars-02.Mpg": "Mpg", "cars-02.Cyl": "Cyl", "cars-02.Disp": "Disp"})

# Get the rows not in common between the two dataframes
df_diff = pd.concat([df1,df2]).drop_duplicates(keep=False)

