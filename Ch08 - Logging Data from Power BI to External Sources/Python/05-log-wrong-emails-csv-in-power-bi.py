import pandas as pd

filter = (dataset['isEmailValidFromRegex'] == 0)

dataset[filter].to_csv(r'D:\<your-path>\Ch08 - Logging Data from Power BI to External Sources\Python\wrong-emails.csv', index=False)

df = dataset[~filter]
