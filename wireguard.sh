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

wg_config="
[Interface]
Address = 10.0.0.1/24, fd24:609a:6c18::1/64
ListenPort = 51820
Table = off
PreUp = source /etc/wireguard/wstunnel.sh && pre_up %I
PostUp = source /etc/wireguard/wstunnel.sh && post_up %i %I
PostDown = source /etc/wireguard/wstunnel.sh && post_down %i %I
SaveConfig = true
" 

echo "$wg_config" | sudo tee /etc/wireguard/wg0.conf

wstunnel_config="
REMOTE_HOST=family.lif.ink
REMOTE_PORT=51820
UPDATE_HOSTS='/etc/hosts'
"
echo "$wg_config" | sudo tee /etc/wireguard/wg0.wstunnel

# 创建 wstunnel 的配置文件
echo "REMOTE_HOST=family.lif.ink" | sudo tee /etc/wireguard/wg0.wstunnel
echo "REMOTE_PORT=51820" | sudo tee /etc/wireguard/wg0.wstunnel
echo "UPDATE_HOSTS='/etc/hosts'"| sudo tee /etc/wireguard/wg0.wstunnel


# 配置转发
sudo sh -c 'echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf'
sudo sh -c 'echo "net.ipv6.conf.all.forwarding=1" >> /etc/sysctl.conf'

sudo sysctl -p