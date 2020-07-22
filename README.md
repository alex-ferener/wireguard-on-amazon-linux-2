# WireGuard on Amazon Linux 2 / VPN Gateway

Use:
- `wg genkey | tee privatekey | wg pubkey > publickey` to generate: `PublicKey` and `PrivateKey`.
- `wg genpsk > wgpsk.key` to generate `PresharedKey`

## Server Side

You can set in EC2 user data

```bash
#!/bin/bash

yum upgrade -y
amazon-linux-extras install -y epel

curl -Lo /etc/yum.repos.d/wireguard.repo \
  https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-7/jdoss-wireguard-epel-7.repo
yum clean all

yum install -y wireguard-dkms wireguard-tools
systemctl enable wg-quick@wg0.service

sysctl net.ipv4.conf.all.forwarding=1 | tee -a /etc/sysctl.d/forwarding.conf

mkdir /etc/wireguard/

echo "
[Interface]
Address = 172.30.30.1/32
ListenPort = 4343
PrivateKey = REPLACE_WITH_SERVER_PRIVATE_KEY
SaveConfig = true
PostUp = iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
PublicKey = REPLACE_WITH_CLIENT_PUBLIC_KEY
PresharedKey = REPLACE_WITH_PRE_SHARED_KEY
AllowedIPs = 172.30.30.2/32

" > /etc/wireguard/wg0.conf

reboot
```

## Client Side

1. Install WireGuard: https://www.wireguard.com/install/

2. Configure client configuration and replace `VPC_RESOLVER_IP` &amp; `EC2_PUBLIC_IP` with actual values. 

```bash
mkdir /etc/wireguard/
echo "
[Interface]
Address = 172.30.30.2/32
DNS = ${VPC_RESOLVER_IP}
PrivateKey = REPLACE_WITH_CLIENT_PRIVATE_KEY
SaveConfig = true

[Peer]
PublicKey = REPLACE_WITH_SERVER_PUBLIC_KEY
PresharedKey = REPLACE_WITH_PRE_SHARED_KEY
AllowedIPs = 0.0.0.0/0
Endpoint = ${EC2_PUBLIC_IP}:4343

" > /etc/wireguard/wg0.conf
```

Use:
- `wg-quick up wg0` to connect
- `wg-quick down wg0` to disconnect

At this point all traffic should be routed through EC2. 

If you want to split the traffic, replace `0.0.0.0/0` with specific CIDRs (eg: `172.30.0.0/16`) and only that range will be tunneled.
