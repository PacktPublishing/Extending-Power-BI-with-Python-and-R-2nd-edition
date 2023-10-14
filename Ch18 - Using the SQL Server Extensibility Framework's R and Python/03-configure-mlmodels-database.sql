CREATE DATABASE [MLModels];
GO

USE [MLModels];
GO

CREATE TABLE models (
	model_name		VARCHAR(100)	NOT NULL,
	model_version	INT				NOT NULL DEFAULT 1,
	model			VARBINARY(MAX)	NOT NULL
);


CREATE EXTERNAL LANGUAGE [py310]
FROM (CONTENT = N'C:\LanguageExtensions\python-lang-extension-windows-release.zip', 
    FILE_NAME = 'pythonextension.dll', 
    ENVIRONMENT_VARIABLES = N'{"PYTHONHOME": "C:\\Program Files\\Python310"}');
GO



CREATE PROCEDURE dbo.stp_generate_binary_model
	@model_file_name NVARCHAR(200) = N'titanic-best-model-flaml.pkl',
	@model_bin VARBINARY(MAX) OUTPUT
AS
BEGIN

	DECLARE @python_script AS NVARCHAR(MAX) = N'
import pickle
import os

main_path = r''C:\MLModels''

with open(os.path.join(main_path, r''' + @model_file_name + '''), ''rb'') as f:
    model = pickle.load(f)

model_bin = pickle.dumps(model)
'

	EXECUTE sp_execute_external_script @language = N'py310'
			, @script = @python_script 
	, @params = N'@model_bin varbinary(max) OUTPUT'
	, @model_bin = @model_bin OUTPUT;

END
GO



DECLARE @model varbinary(max);

DELETE FROM dbo.models
WHERE
	model_name = 'titanic_flaml'
	AND model_version = 1;

EXECUTE stp_generate_binary_model @model_bin = @model OUTPUT;

INSERT INTO dbo.models (model_name, model_version, model)
VALUES (
	  'titanic_flaml'
	, 1
	, @model
);
GO

SELECT *
FROM dbo.models;
GO



CREATE PROCEDURE stp_predict_titanic_survivors
	  @ModelName	AS VARCHAR(100)
	, @ModelVersion	AS INT
	, @Age			AS INT
	, @Embarked		AS FLOAT
	, @Fare			AS FLOAT
	, @Parch		AS FLOAT
	, @Pclass		AS INT
	, @Sex			AS INT
	, @SibSp		AS FLOAT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@binary_model VARBINARY(MAX),
		@input_query NVARCHAR(MAX);

	SET @input_query = CONCAT(N'
			SELECT
			  Age		= ', @Age, N'
			, Embarked	= CAST(', @Embarked, N' AS FLOAT)
			, Fare		= CAST(', @Fare, N' AS FLOAT)
			, Parch		= CAST(', @Parch, N' AS FLOAT)
			, Pclass	= ', @Pclass, N'
			, Sex		= ', @Sex, N'
			, SibSp		= CAST(', @SibSp, N' AS FLOAT)')

	SELECT TOP 1
		@binary_model = model
	FROM dbo.models
	WHERE
		model_name = @ModelName
		AND model_version = @ModelVersion;

	EXECUTE sp_execute_external_script @language = N'py310'
			, @script = N'
import pandas as pd
import pickle

model = pickle.loads(binary_model)

prediction_label = model.predict(input_tuple_df)[0]
prediction_score = model.predict_proba(input_tuple_df)[:,1][0]

print(f''Prediction label: {prediction_label}'')
print(f''Prediction score: {prediction_score}'')

output_data = {
	''prediction_label'': [prediction_label],
	''prediction_score'': [prediction_score]
}

output_df = pd.DataFrame(output_data)'

		, @input_data_1 = @input_query
		, @input_data_1_name = N'input_tuple_df'
		, @output_data_1_name = N'output_df'
		, @params = N'@binary_model VARBINARY(MAX)'
		, @binary_model = @binary_model
	WITH RESULT SETS ((
		  prediction_label INT
		, prediction_score DECIMAL(5,4)
	));

END
GO


EXEC stp_predict_titanic_survivors
	  @ModelName	= 'titanic_flaml'
	, @ModelVersion	= 1
	, @Age			= 74
	, @Embarked		= 2.0
	, @Fare			= 7.775
	, @Parch		= 0.0
	, @Pclass		= 1
	, @Sex			= 1
	, @SibSp		= 0.0
