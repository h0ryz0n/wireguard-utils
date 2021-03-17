@echo off
::BATCHDOG: A WINDOWS BATCH-WATCHDOG TO FOR A WIREGUARD BOUNCE SERVER/PEER WITH DDNS
::restarts the windows service to update the dns entry, when needed
::put in task scheduler with elevated privileges (with NT_AUTHORITY/SYSTEM user)
setlocal

:init
set wglasthandshake=0

:loop
timeout /T 70 /nobreak > nul
for /f "tokens=2" %%a IN ( 
'wg show wg0 latest-handshakes' 
) do ( 
if %wglasthandshake% == %%a (goto restartservice)
)
set wglasthandshake=%%a
goto loop

:restartservice
sc stop "WireguardTunnel$wg0" > nul
timeout /T 15 /nobreak > nul
sc start "WireguardTunnel$wg0" > nul
::wait for first handshake and restart
timeout /T 15 /nobreak

endlocal
goto loop
