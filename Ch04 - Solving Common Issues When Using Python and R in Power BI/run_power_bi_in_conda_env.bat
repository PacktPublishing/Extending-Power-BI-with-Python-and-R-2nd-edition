@echo OFF
rem How to run Power BI Desktop in a given conda environment from a batch file.

rem It doesn't require:
rem - conda to be in the PATH
rem - cmd.exe to be initialized with conda init

rem Define here the path to your conda installation
rem If you installed [Anaconda/Miniconda] just for your user, you'll find the installation folder in C:\Users\your-username\[AnacondaX/MinicondaX]
rem If you installed [Anaconda/Miniconda] for all the users, you'll find the installation folder in C:\ProgramData\[AnacondaX/MinicondaX]
set CONDAPATH=C:\ProgramData\Miniconda3
rem Define here the name of the environment. Use "base" for the base environment
set ENVNAME=pbi_powerquery_env

rem The following command activates the base environment.
rem call C:\ProgramData\Miniconda3\Scripts\activate.bat C:\ProgramData\Miniconda3
if %ENVNAME%==base (set ENVPATH=%CONDAPATH%) else (set ENVPATH=%CONDAPATH%\envs\%ENVNAME%)

rem Activate the conda environment
rem Using call is required here, see: https://stackoverflow.com/questions/24678144/conda-environments-and-bat-files
call %CONDAPATH%\Scripts\activate.bat %ENVPATH%

rem Run a python script in that environment
"C:\Program Files\Microsoft Power BI Desktop\bin\PBIDesktop.exe"

rem Deactivate the environment
call conda deactivate

rem One could also use the conda run command
rem conda run -n your-environment-name "C:\Program Files\Microsoft Power BI Desktop\bin\PBIDesktop.exe"