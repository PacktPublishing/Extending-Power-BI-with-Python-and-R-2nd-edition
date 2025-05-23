# THIS SCRIPT IS SUPPOSED TO RUN IN A JUPYTER NOTEBOOK (WE USED VS CODE)

# %%
import pyodbc
import pandas as pd 

# %%
# Connect to your Azure SQL Database
conn = pyodbc.connect(
    'Driver={ODBC Driver 17 for SQL Server};'
    'Server=<your-server-name>.database.windows.net;'
    'Database=SystemsLogging;'
    'Uid=<your-username>;'
    'Pwd=<your-password>')

# %%
# Read and show some information about databases on the Azure SQL server using a system view
data = pd.read_sql("SELECT database_id, name FROM sys.databases", conn)
data

# %%
# Disconnect from your SQLExpress instance
conn.close()

# %%
# Connect to your SQLExpress instance using the Windows Authentication
conn = pyodbc.connect(
    'Driver={ODBC Driver 17 for SQL Server};'
    r'Server=.;'
    'Database=master;'
    'Trusted_Connection=yes;')

# %%
# You can also connect to it using the SQL Authentication for the 'sa' user or any other user if you prefer
# conn = pyodbc.connect(
#     'Driver={ODBC Driver 17 for SQL Server};'
#     r'Server=.;'
#     'Database=master;'
#     'Uid=<your-username>;'
#     'Pwd=<your-password>')

# %%
# Read and show some information about databases using a system view
data = pd.read_sql("SELECT database_id, name FROM sys.databases", conn)
data

# %%
# Disconnect from your SQLExpress instance
conn.close()

# %%
# Connect to your SQLExpress instance using the Windows Authentication
conn = pyodbc.connect(
    'Driver={ODBC Driver 17 for SQL Server};'
    r'Server=.;'
    'Database=SystemsLogging;'
    'Trusted_Connection=yes;')

# %%
# Create the WrongEmails table into your SystemsLogging local SQL database.
# The table will have the columns 'UserId' and 'Email'.
cursor = conn.cursor()
cursor.execute('''
               CREATE TABLE WrongEmails
               (
               UserId int,
               Email nvarchar(200)
               )
               ''')
conn.commit()

# %%
# Disconnect from your SQLExpress instance
conn.close()

# %%
# Connect to your Azure SQL Database
conn = pyodbc.connect(
    'Driver={ODBC Driver 17 for SQL Server};'
    'Server=<your-server-name>.database.windows.net;'
    'Database=SystemsLogging;'
    'Uid=<your-username>;'
    'Pwd=<your-password>')

# %%
# Create the WrongEmails table into your SystemsLogging Azure SQL database.
# The table will have the columns 'UserId' and 'Email'.
cursor = conn.cursor()
cursor.execute('''
               CREATE TABLE WrongEmails
               (
               UserId int,
               Email nvarchar(200)
               )
               ''')
conn.commit()

# %%
# Get data from sample SalesLT.Customers
data = pd.read_sql('SELECT TOP 10 CustomerID, EmailAddress FROM SalesLT.Customer', conn)
data

# %%
# Write Customers data into the WrongEmails table
cursor = conn.cursor()
# Write a dataframe into a (Azure) SQL Server database table row by row:
for index, row in data.iterrows():
    cursor.execute("INSERT INTO WrongEmails (UserId, Email) values(?,?)", row.CustomerID, row.EmailAddress)
conn.commit()
cursor.close()

# %%
# Get the data from the WrongEmails table and show it
df = pd.read_sql('SELECT TOP 10 UserId, Email FROM WrongEmails', conn)
df.head()

# %%
# Now let's empty the WrongEmails table
cursor = conn.cursor()
cursor.execute('TRUNCATE TABLE WrongEmails')
conn.commit()

# %%
# Close the connection
conn.close()
# %%
