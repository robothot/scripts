#!/bin/bash
sudo apt update -y
sudo apt install wireguard -y

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
echo "[Interface]" | sudo tee /etc/wireguard/wg0.conf
echo "Address = 10.0.0.1/24, fd24:609a:6c18::1/64" | sudo tee /etc/wireguard/wg0.conf
echo "ListenPort = 51820" | sudo tee /etc/wireguard/wg0.conf
echo "Table = off" | sudo tee /etc/wireguard/wg0.conf
echo "PreUp = source /etc/wireguard/wstunnel.sh && pre_up %I" | sudo tee /etc/wireguard/wg0.conf
echo "PostUp = source /etc/wireguard/wstunnel.sh && post_up %i %I" | sudo tee /etc/wireguard/wg0.conf
echo "PostDown = source /etc/wireguard/wstunnel.sh && post_down %i %I" | sudo tee /etc/wireguard/wg0.conf
echo "SaveConfig = true" | sudo tee /etc/wireguard/wg0.conf

# 创建 wstunnel 的配置文件
echo "REMOTE_HOST=family.lif.ink" | sudo tee /etc/wireguard/wg0.wstunnel
echo "REMOTE_PORT=51820" | sudo tee /etc/wireguard/wg0.wstunnel
echo "UPDATE_HOSTS='/etc/hosts'"| sudo tee /etc/wireguard/wg0.wstunnel


# 配置转发
echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.conf
echo "net.ipv6.conf.all.forwarding=1" | sudo tee /etc/sysctl.conf

sudo sysctl -p