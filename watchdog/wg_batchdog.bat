::@echo off
::BATCHDOG: A WINDOWS BATCH-WATCHDOG TO FOR A WIREGUARD BOUNCE SERVER/PEER WITH DDNS
::restarts the windows service to update the dns entry, when needed
::add to task scheduler with nt authority/system account
setlocal

:init
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
if %recv%==%%a (
goto restartservice
)
set wgrcv=%%a
)
goto loop

:restartservice
net stop "WireguardTunnel$wg0"
net start "WireguardTunnel$wg0"
if not errorlevel 0 goto restartservice
timeout /T 5 /nobreak
sc query "WireguardTunnel$wg0"
goto loop
