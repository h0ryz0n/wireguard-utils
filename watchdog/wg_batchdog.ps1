#WG_BATCHDOG: A WINDOWS BATCH-WATCHDOG FOR A WIREGUARD BOUNCE SERVER/PEER WITH DDNS (POWERSHELL FLAVOUR)
#restarts the windows service to update the dns entry, when needed
#add "powershell -executionpolicy bypass -File C:\bin\wg_batchdog.ps1" action to task scheduler at system boot
#nt authority/system account, repeat every 5min+unlimited, enqueue if execution in progress

$SVC = 'WireguardTunnel$wg0'
$CMD = wg show wg0 transfer

#wait for first handshake, restart if stopped for some reason
while($recv1 -eq $null) {
    net start $SVC
    sleep(5)
    $recv1 = ($CMD).Split()[1]
    sleep(5)
}
#wait next handshake
sleep(200)
#check bytes received
$recv2 = ($CMD).Split()[1]
if($recv1 -eq $recv2) {
    #tunnel is not handshaking, restarting service
    do {
        net stop $SVC
        net start $SVC
        #try again if failed
        if ($LASTEXITCODE -ne 0) {$restart=$true} else {$restart=$false}
        sleep(5)
        }
    while($restart)
 }


