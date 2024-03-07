
CREATE EXTERNAL LANGUAGE [py310]
FROM (CONTENT = N'C:\LanguageExtensions\python-lang-extension-windows-release.zip', 
    FILE_NAME = 'pythonextension.dll', 
    ENVIRONMENT_VARIABLES = N'{"PYTHONHOME": "C:\\Program Files\\Python310"}');
GO

CREATE EXTERNAL LANGUAGE [r422]
FROM (CONTENT = N'C:\LanguageExtensions\R-lang-extension-windows-release.zip', 
    FILE_NAME = 'libRExtension.dll',
    ENVIRONMENT_VARIABLES = N'{"R_HOME": "C:\\Program Files\\R\\R-4.2.2"}');
GO

sp_configure 'external scripts enabled', 1;
RECONFIGURE WITH OVERRIDE;

SELECT * FROM sys.external_languages;


EXEC sp_execute_external_script
@language =N'py310',
@script=N'
import sys
print(sys.path)
print(sys.version)
print(sys.executable)';


EXEC sp_execute_external_script
    @language =N'r422',
    @script=N'
print(R.home());
print(file.path(R.home("bin"), "R"));
print(R.version);
print("Hello RExtension!");'

