@echo off
setlocal enabledelayedexpansion

echo ================================
echo Cloudbase-Init Full Setup Script
echo ================================

:: Cek admin
net session >nul 2>&1
if %errorlevel% neq 0 (
echo ERROR: Jalankan sebagai Administrator!
pause
exit /b
)

:: ================================
:: [1] DETECT ARCH
:: ================================
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
set URL=https://cloudbase.it/downloads/CloudbaseInitSetup_Stable_x64.msi
) else (
set URL=https://cloudbase.it/downloads/CloudbaseInitSetup_Stable_x86.msi
)

set FILE=%TEMP%\cloudbase-init.msi

echo.
echo Downloading Cloudbase-Init...
powershell -Command "Invoke-WebRequest -Uri '%URL%' -OutFile '%FILE%'"

:: ================================
:: [2] INSTALL
:: ================================
echo Installing Cloudbase-Init...

msiexec /i "%FILE%" ^
/qn ^
RUN_SERVICE_AS_LOCALSYSTEM=1 ^
SERIAL_PORT=COM1 ^
USERNAME=Administrator

:: ================================
:: [3] CONFIG
:: ================================
set CONF="C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\cloudbase-init.conf"

copy %CONF% %CONF%.bak >nul

(
echo.
echo first_logon_behaviour=no
echo.
echo config_drive=true
echo.
echo metadata_services=cloudbaseinit.metadata.services.configdrive.ConfigDriveService
echo.
echo plugins=cloudbaseinit.plugins.common.mtu.MTUPlugin^,
echo cloudbaseinit.plugins.common.sethostname.SetHostNamePlugin^,
echo cloudbaseinit.plugins.windows.extendvolumes.ExtendVolumesPlugin^,
echo cloudbaseinit.plugins.common.userdata.UserDataPlugin^,
echo cloudbaseinit.plugins.common.sshpublickeys.SetUserSSHPublicKeysPlugin
) >> %CONF%

:: ================================
:: [4] REMOVE EDGE
:: ================================
powershell -Command "Get-AppxPackage -Name Microsoft.MicrosoftEdge.Stable | Remove-AppxPackage"
powershell -Command "Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -like '*Edge*'} | Remove-AppxProvisionedPackage -Online"

:: ================================
:: [5] PIN SYSPREP
:: ================================
powershell -Command ^
"$s=(New-Object -ComObject Shell.Application); ^
$f=$s.Namespace('C:\Windows\System32\Sysprep'); ^
$item=$f.ParseName('sysprep.exe'); ^
$item.InvokeVerb('taskbarpin')"

:: ================================
:: [6] CONVERT EDITION
:: ================================
DISM /online /Get-CurrentEdition
DISM /online /Get-TargetEditions

DISM /online /Set-Edition:ServerDatacenter /ProductKey:WX4NM-KYWYW-QJJR4-XV3QB-6VM33 /AcceptEula

:: ================================
:: [7] SELF DELETE + RESTART
:: ================================
echo.
echo Script akan dihapus dan restart dalam 10 detik...

set SCRIPT=%~f0

start "" cmd /c "timeout /t 10 >nul & del /f /q "%SCRIPT%" & shutdown /r /t 0"

exit
