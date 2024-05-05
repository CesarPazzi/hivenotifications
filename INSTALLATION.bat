powershell Install-Module -Name BurntToast -Confirm:$False -Force
pushd %~dp0
schtasks /create /tn "HiveNotifs" /tr "%~dp0hive-notifications.bat" /sc minute /mo 1 /RL HIGHEST /RU SYSTEM