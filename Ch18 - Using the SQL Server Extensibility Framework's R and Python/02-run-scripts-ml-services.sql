DECLARE @row_count INT;

EXEC sp_execute_external_script
@language = N'py310',
@script = N'
import pandas as pd
row_count = configs_df.shape[0]
print(row_count)',
@input_data_1 = N'SELECT configuration_id, name FROM sys.configurations',
@input_data_1_name = N'configs_df',
@params = N'@row_count INT OUTPUT',
@row_count = @row_count OUTPUT;

SELECT NumRows = @row_count;



EXEC sp_execute_external_script
@language = N'py310',
@script = N'
import pandas as pd
configs_df["id_name"] = configs_df["configuration_id"].astype(str) + configs_df["name"]
OutputDataSet = configs_df',
@input_data_1 = N'SELECT configuration_id, name FROM sys.configurations',
@input_data_1_name = N'configs_df';


EXEC sp_execute_external_script
@language = N'py310',
@script = N'
import pandas as pd
configs_df["id_name"] = configs_df["configuration_id"].astype(str) + configs_df["name"]
transformed_df = configs_df',
@input_data_1 = N'SELECT configuration_id, name FROM sys.configurations',
@input_data_1_name = N'configs_df',
@output_data_1_name = N'transformed_df'
WITH RESULT SETS(
	(
		configuration_id INT NOT NULL,
		name VARCHAR(150) NOT NULL,
		id_name VARCHAR(200) NOT NULL
	)
);



DROP TABLE IF EXISTS #InstanceConfigurations;

CREATE TABLE #InstanceConfigurations (
	configuration_id INT NOT NULL,
	name VARCHAR(150) NOT NULL,
	id_name VARCHAR(200) NOT NULL
);

INSERT INTO #InstanceConfigurations
EXEC sp_execute_external_script
@language = N'py310',
@script = N'
import pandas as pd
configs_df["id_name"] = configs_df["configuration_id"].astype(str) + configs_df["name"]
transformed_df = configs_df',
@input_data_1 = N'SELECT configuration_id, name FROM sys.configurations',
@input_data_1_name = N'configs_df',
@output_data_1_name = N'transformed_df';

SELECT * FROM #InstanceConfigurations;



EXEC sp_execute_external_script
@language = N'py310',
@script = N'
import pandas as pd
import pyodbc

conn = pyodbc.connect(
    "Driver={ODBC Driver 17 for SQL Server};"
    "Server=.;"
    "Database=master;"
    "Trusted_Connection=yes;")

configs_df = pd.read_sql("SELECT configuration_id, name FROM sys.configurations", conn) 
configs_df["id_name"] = configs_df["configuration_id"].astype(str) + configs_df["name"]
transformed_df = configs_df',
@output_data_1_name = N'transformed_df'
WITH RESULT SETS(
	(
		configuration_id INT NOT NULL,
		name VARCHAR(150) NOT NULL,
		id_name VARCHAR(200) NOT NULL
	)
);
