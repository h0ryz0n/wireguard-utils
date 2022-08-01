#!/bin/bash

######## TUNNEL + QR GENERATOR HELPER #########

###### SERVER CONF EXAMPLE #######
#[Interface]
#Address = 172.0.0.1/24
#ListenPort = 51820
#PrivateKey = $privatekey......

#PEERNAME...
#[Peer]
#PublicKey = $publickey....
#AllowedIPs = 172.20.0.0/24
###################################


#VARS
#machine parameters
CONFIGFILE="/etc/wireguard/wg0.conf"
#client parameters
PEERNAME=${2}
#IP_PEER="172.X.X.XXX"
IP_PEER=${1}
PORT="51820"                        ## CLIENT PORT
ALLOWED_IPS="WIREGUARD_SUBNET/24"   ## VPN SUBNET
KEEPALIVE="120"
PEERFILE=peer_${PEERNAME}.conf
#server parameters
SERVER_PUBKEY="<server public key>"
ENDPOINT="SERVERIP:51820"           ## SERVER ENDPOINT


##### START ######
#
mkdir -p ./confs && cd $_
if [ -z "${1}" ] | [ -z "${2}" ] ; then
    echo "@USAGE: <peer ip address> <peer name>"
    exit 1
fi

echo
echo ++ generating peer keys ++
##generate private + public key
PRIVATEKEY=`wg genkey`
echo privatekey = $PRIVATEKEY
#PUBLICKEY=`wg pubkey < $PRIVATEKEY`
PUBLICKEY=`echo $PRIVATEKEY | wg pubkey`
echo publickey = $PUBLICKEY
##or generate to file
#wg genkey > privatekey
#wg pubkey < privatekey > publickey

##create configuration file for peer
#
echo
echo ++ generating output files ++
cat << EOF > ${PEERFILE}
[Interface]
PrivateKey = ${PRIVATEKEY}
ListenPort = ${PORT}
Address = ${IP_PEER}/32

[Peer]
PublicKey = ${SERVER_PUBKEY}
Endpoint = ${ENDPOINT}
AllowedIPs = ${ALLOWED_IPS}
PersistentKeepAlive = ${KEEPALIVE}
EOF
#
#client conf
echo
echo ++ peer configuration ++
cat ${PEERFILE}
echo \#\#options
echo \#\#
#server conf
echo
echo ++ add to server conf ++
echo \#$PEERNAME
echo [Peer]
echo PublicKey = $PUBLICKEY
echo AllowedIPs = ${IP_PEER}/32
##generate qr code and png file
echo
cat ${PEERFILE} | qrencode -t ansiutf8i
qrencode -t png -o ${PEERFILE}.png -r ${PEERFILE}
## prompt: add to server.conf? [y/n]
# cat << EOF > $CONFIGFILE
# .......
# EOF
