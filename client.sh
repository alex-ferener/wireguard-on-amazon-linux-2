#!/bin/bash

mkdir /etc/wireguard/

echo "
[Interface]
Address = 172.30.30.2/32
DNS = ${VPC_RESOLVER_IP}
PrivateKey = 0PRbe7sseN3Y6cDiNmzR07b/eYV5ZnppfkLhmfcYRH0=
SaveConfig = true

[Peer]
PublicKey = U7sMaPKGIb+lkkSHiQbO3AcsCamXeWWKWOpLequfkh8=
PresharedKey = VWFnSjNLp0a2ol4iPSFcl3lrGpGbyoPQJS7mJQKwlJk=
AllowedIPs = 0.0.0.0/0
Endpoint = ${EC2_PUBLIC_IP}:4343

" > /etc/wireguard/wg0.conf

wg-quick up wg0
