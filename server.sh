#!/bin/bash
curl -L -o /etc/yum.repos.d/wireguard.repo \
  https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-7/jdoss-wireguard-epel-7.repo

yum install -y wireguard-dkms wireguard-tools
systemctl enable wg-quick@wg0.service

sysctl net.ipv4.conf.all.forwarding=1 | tee -a /etc/sysctl.d/forwarding.conf

mkdir /etc/wireguard/

echo "
[Interface]
Address = 172.30.30.1/32
ListenPort = 4343
PrivateKey = sCK+ns1GH0CxBnKgO5v14o+u51xfIrkiCTeT828dJVI=
SaveConfig = true
PostUp = iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
PublicKey = P5otm+/TX6Zs0DAJnWyG89gVzWAf/ESglEMMn3uhbg8=
PresharedKey = VWFnSjNLp0a2ol4iPSFcl3lrGpGbyoPQJS7mJQKwlJk=
AllowedIPs = 172.30.30.2/32

" > /etc/wireguard/wg0.conf

wg-quick up wg0
