# WireGuard on Amazon Linux 2 / VPN Gateway

Use `wg genkey | tee privatekey | wg pubkey > publickey` to generate the keys.

## Server Side

You can put in EC2 user data

```bash
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
AllowedIPs = 172.30.30.2/32

" > /etc/wireguard/wg0.conf

wg-quick up wg0
```

## Client Side

1. Install WireGuard: https://www.wireguard.com/install/

2. Configure client configuration

```bash
echo "
[Interface]
Address = 172.30.30.2/32
DNS = ${VPC_RESOLVER_IP}
PrivateKey = 0PRbe7sseN3Y6cDiNmzR07b/eYV5ZnppfkLhmfcYRH0=
SaveConfig = true

[Peer]
PublicKey = U7sMaPKGIb+lkkSHiQbO3AcsCamXeWWKWOpLequfkh8=
AllowedIPs = 0.0.0.0/0
Endpoint = ${EC2_PUBLIC_IP}:4343

" > /etc/wireguard/wg0.conf
```

Use:
- `wg-quick up wg0` for connecting
- `wg-quick down wg0` to disconnect

At this point all the traffic should be routed through EC2
