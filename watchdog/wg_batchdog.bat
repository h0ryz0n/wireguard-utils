::@echo off
::BATCHDOG: A WINDOWS (RAW) BATCH-WATCHDOG FOR A WIREGUARD BOUNCE SERVER/PEER WITH DDNS
::restarts the windows service to update the dns entry, when needed
::add to task scheduler with nt authority/system account (in case of error restart 999 times every 5 minutes)
setlocal

:init
net start "WireguardTunnel$wg0"
for /f "tokens=2" %%a IN ( 
'wg show wg0 transfer' 
) do (
set recv=%%a
)

:loop
timeout /T 200 /nobreak
for /f "tokens=2" %%a IN ( 
'wg show wg0 transfer' 
) do ( 
if %recv%==%%a (goto restartservice) else (set recv=%%a)
)
goto loop

:restartservice
net stop "WireguardTunnel$wg0"
net start "WireguardTunnel$wg0"
if errorlevel neq 0 goto restartservice
timeout /T 5 /nobreak
::sc query "WireguardTunnel$wg0"
goto loop
