#!/bin/bash

### static vars
x=2

### edit this vars
num_clients=10
vpn_server=vpn.example.com:51820
### edit end

num_clients=$(( $num_clients + 1 ))

### initiate server config

sPRIV=$(wg genkey) && sPUB=$(echo $sPRIV | wg pubkey)


cat << EOF > server.conf
[Interface]
Address = 10.7.38.1/24
ListenPort = 51820
PrivateKey = $sPRIV

EOF

## generating client config

while [ $x -le $num_clients ]
  do
 
  echo "Generating config for user No $x"
  PRIV=$(wg genkey) && PUB=$(echo $PRIV | wg pubkey)
  cat << EOF > client$x.conf
[Interface]
Address = 10.7.38.$x/32
PrivateKey = $PRIV

[Peer]
PublicKey = $sPUB
Endpoint = $vpn_server
AllowedIPs = 10.7.38.0/24

PersistentKeepalive = 25
EOF

  # append client key to server config
cat <<EOF >> server.conf
#client$x
[Peer]
PublicKey = $PUB
AllowedIPs = 10.7.38.$x/32

EOF
  # increment
  x=$(( $x + 1 ))

done
