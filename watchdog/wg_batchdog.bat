@echo off
::BATCHDOG: A WINDOWS BATCH-WATCHDOG TO FOR A WIREGUARD BOUNCE SERVER/PEER WITH DDNS
::restarts the windows service to update the dns entry, when needed
setlocal

:init
for /f "tokens=2" %%a IN ( 
'wg show wg0 transfer' 
) do (
set recv=%%a
)

:loop
::handshake time is between 120/180 sec
timeout /T 200 /nobreak > nul
for /f "tokens=2" %%a IN ( 
'wg show wg0 transfer' 
) do ( 
echo before %recv%
echo now   %%a
if %recv%==%%a (
goto restartservice
)
set wgrcv=%%a
)
goto loop

:restartservice
sc stop "WireguardTunnel$wg0" > nul
timeout /T 5 /nobreak > nul
sc start "WireguardTunnel$wg0" > nul
::wait for first handshake and restart
timeout /T 5 /nobreak > nul
::sc query "WireguardTunnel$wg0"
goto loop
