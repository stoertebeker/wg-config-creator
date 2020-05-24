#!/bin/bash

### static vars
x=2

### edit this vars
num_clients=10
vpn_server=vpn.example.com
vpn_port=51820
server_local_if=eth0
### edit end

num_clients=$(( $num_clients + 1 ))

### initiate server config

sPRIV=$(wg genkey) && sPUB=$(echo $sPRIV | wg pubkey)


cat << EOF > server.conf
[Interface]
Address = 10.7.38.1/24
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o $server_local_if -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o $server_local_if -j MASQUERADE
ListenPort = $vpn_port
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
Endpoint = $vpn_server:$vpn_port
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
