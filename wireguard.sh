#!/bin/bash
sudo apt update -y
sudo apt install wireguard iptables ip6tables ufw -y

sudo cp ./bin/wstunnel /bin/wstunnel
sudo chmod +x /bin/wstunnel
sudo cp ./scripts/wstunnel.sh /etc/wireguard/wstunnel.sh

sudo mkdir /etc/wireguard/keys

# 创建私钥
wg genkey | sudo tee /etc/wireguard/keys/private.key
sudo chmod go= /etc/wireguard/keys/private.key

# 创建公钥
sudo cat /etc/wireguard/keys/private.key | wg pubkey | sudo tee /etc/wireguard/keys/public.key

# 创建配置信息

# 执行 ip route list default 查看接口

gateway="eth0"


wg_config="
[Interface]
Address = 10.0.0.1/24, fd24:609a:6c18::1/64
ListenPort = 51820
PostUp = ufw route allow in on wg0 out on $
PostUp = iptables -t nat -I POSTROUTING -o $gateway -j MASQUERADE
PostUp = ip6tables -t nat -I POSTROUTING -o $gateway -j MASQUERADE
PreDown = ufw route delete allow in on wg0 out on $gateway
PreDown = iptables -t nat -D POSTROUTING -o $gateway -j MASQUERADE
PreDown = ip6tables -t nat -D POSTROUTING -o $gateway -j MASQUERADE
" 

echo "$wg_config" | sudo tee /etc/wireguard/wg0.conf


# 配置转发
sudo sh -c 'echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf'
sudo sh -c 'echo "net.ipv6.conf.all.forwarding=1" >> /etc/sysctl.conf'

sudo sysctl -p