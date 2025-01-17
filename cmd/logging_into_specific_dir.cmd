REM #############################################################################
REM #####							1st part								#####
REM #############################################################################

REM Získání aktuálního adresáře skriptu a odstranění posledního zpětného lomítka
set scriptDir=%~dp0
set scriptDir=%scriptDir:~0,-1%

REM Získání nadřazeného adresáře a odstranění posledního zpětného lomítka
for %%I in ("%scriptDir%") do set parentDir=%%~dpI
set parentDir=%parentDir:~0,-1%

REM Nastavení proměnné LOGS_DIR, která se skládá z parentDir a logovacího adresáře deployment_logs
set LOGS_DIR=%parentDir%\deployment_logs

REM Nastavení cesty k adresáři logů a jeho vytvoření, pokud neexistuje, používám promměnou %BANK% pro specifické logování
set logDirFullPath=%LOGS_DIR%\%BANK%
if not exist "%logDirFullPath%" (
    mkdir "%logDirFullPath%"
    echo Vytvoren adresar "%logDirFullPath%"
) else (
    echo Adresar jiz existuje: "%logDirFullPath%"
)


REM #############################################################################
REM #####							2nd part								#####
REM #############################################################################

REM Získá aktuální datum a čas pomocí PowerShell a formátuje je do požadovaného formátu
for /f %%i in ('powershell -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set TIMESTAMP=%%i

rem Pokud je proměnná logDirFullPath prázdná, logujeme do aktuálního adresáře
if "%logDirFullPath%"=="" (
    set logDirFullPath=%cd%
)

set OUTPUT=%logDirFullPath%\output_%DBSCHEMA%_%ENVIRONMENTNAME%_%TIMESTAMP%.log
set OUTPUTFILTERED=%logDirFullPath%\output_%DBSCHEMA%_%ENVIRONMENTNAME%_%TIMESTAMP%_filtered.log
set OUTPUTREP=%logDirFullPath%\output_%DBSCHEMA%_%ENVIRONMENTNAME%_%TIMESTAMP%_reports.log