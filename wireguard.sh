#!/bin/bash
sudo apt update -y
sudo apt install wireguard -y

sudo cp ./bin/wstunnel /bin/wstunnel
sudo chmod +x /bin/wstunnel
sudo cp ./scripts/wstunnel.sh /etc/wireguard/wstunnel.sh

# 创建私钥
wg genkey | sudo tee /etc/wireguard/keys/private.key
sudo chmod go= /etc/wireguard/keys/private.key

# 创建公钥
sudo cat /etc/wireguard/keys/private.key | wg pubkey | sudo tee /etc/wireguard/keys/public.key

# 创建配置信息
sudo echo "[Interface]" > /etc/wireguard/wg0.conf
sudo echo "Address = 10.0.0.1/24, fd24:609a:6c18::1/64" > /etc/wireguard/wg0.conf
sudo echo "ListenPort = 51820" > /etc/wireguard/wg0.conf
sudo echo "Table = off" > /etc/wireguard/wg0.conf
sudo echo "PreUp = source /etc/wireguard/wstunnel.sh && pre_up %I" > /etc/wireguard/wg0.conf
sudo echo "PostUp = source /etc/wireguard/wstunnel.sh && post_up %i %I" > /etc/wireguard/wg0.conf
sudo echo "PostDown = source /etc/wireguard/wstunnel.sh && post_down %i %I" > /etc/wireguard/wg0.conf
sudo echo "SaveConfig = true" > /etc/wireguard/wg0.conf

# 创建 wstunnel 的配置文件
sudo echo "REMOTE_HOST=family.lif.ink" > /etc/wireguard/wg0.wstunnel
sudo echo "REMOTE_PORT=51820" > /etc/wireguard/wg0.wstunnel
sudo echo "UPDATE_HOSTS='/etc/hosts'" > /etc/wireguard/wg0.wstunnel


# 配置转发
sudo echo "net.ipv4.ip_forward=1" > /etc/sysctl.conf
sudo echo "net.ipv6.conf.all.forwarding=1" > /etc/sysctl.conf

sudo sysctl -p