#!/bin/bash

set -e

GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}██   ██  █████  ██   ██ ██      ██ ██     ████████ ███████  █████  ███    ███ ${NC}"
echo -e "${GREEN}██  ██  ██   ██ ██   ██ ██      ██ ██        ██    ██      ██   ██ ████  ████ ${NC}"
echo -e "${GREEN}█████   ███████ ███████ ██      ██ ██        ██    █████   ███████ ██ ████ ██ ${NC}"
echo -e "${GREEN}██  ██  ██   ██ ██   ██ ██ ██   ██ ██        ██    ██      ██   ██ ██  ██  ██ ${NC}"
echo -e "${GREEN}██   ██ ██   ██ ██   ██ ██  █████  ██        ██    ███████ ██   ██ ██      ██ ${NC}"                                                       

echo -e "${GREEN}- Dimas Firmansah${NC}"
echo -e "${GREEN}- Gilar Bimo Tio Altan${NC}"
echo -e "${GREEN}- Jenar Adi Raditya${NC}"
echo -e "${GREEN}- Muhammad Khosy Pahala${NC}"
echo -e "${GREEN}- Rafi Ilham Muzaki${NC}"
echo -e "${GREEN}- Zein Aljundi${NC}"

set -e

# Inisialisasi awal ...
# Menambah Repositori Kartolo
cat <<EOF | sudo tee /etc/apt/sources.list
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-updates main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-security main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-backports main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-proposed main restricted universe multiverse
EOF

sudo apt update
sudo apt install isc-dhcp-server -y
sudo apt install expect -y
sudo DEBIAN_FRONTEND=noninteractive apt install -y iptables-persistent
sudo ufw allow 30002/tcp
sudo ufw allow 30004/tcp
sudo ufw allow from 192.168.74.137 to any port 30002
sudo ufw allow from 192.168.74.137 to any port 30004
sudo ufw reload

# Konfigurasi Pada Netplan
echo "Mengkonfigurasi netplan..."
cat <<EOF | sudo tee /etc/netplan/01-netcfg.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: true
    eth1:
      dhcp4: no
  vlans:
     eth1.10:
       id: 10
       link: eth1
       addresses: [192.168.17.1/24]
EOF

sudo netplan apply

# Konfigurasi DHCP Server
echo "Menyiapkan konfigurasi DHCP server..."
cat <<EOL | sudo tee /etc/dhcp/dhcpd.conf
# Konfigurasi subnet untuk VLAN 10
subnet 192.168.17.0 netmask 255.255.255.0 {
    range 192.168.17.2 192.168.17.200;
    option routers 192.168.17.1;
    option subnet-mask 255.255.255.0;
    option domain-name-servers 8.8.8.8, 8.8.4.4;
    default-lease-time 600;
    max-lease-time 7200;
}

# Konfigurasi Fix DHCP
host fantasia {
  hardware ethernet 00:50:79:66:68:06;
  fixed-address 192.168.17.10;
}
EOL

echo -e "${GREEN}██   ██  █████  ██   ██ ██      ██ ██     ████████ ███████  █████  ███    ███ ${NC}"
echo -e "${GREEN}██  ██  ██   ██ ██   ██ ██      ██ ██        ██    ██      ██   ██ ████  ████ ${NC}"
echo -e "${GREEN}█████   ███████ ███████ ██      ██ ██        ██    █████   ███████ ██ ████ ██ ${NC}"
echo -e "${GREEN}██  ██  ██   ██ ██   ██ ██ ██   ██ ██        ██    ██      ██   ██ ██  ██  ██ ${NC}"
echo -e "${GREEN}██   ██ ██   ██ ██   ██ ██  █████  ██        ██    ███████ ██   ██ ██      ██ ${NC}"                                                       

echo -e "${GREEN}- Dimas Firmansah${NC}"
echo -e "${GREEN}- Gilar Bimo Tio Altan${NC}"
echo -e "${GREEN}- Jenar Adi Raditya${NC}"
echo -e "${GREEN}- Muhammad Khosy Pahala${NC}"
echo -e "${GREEN}- Rafi Ilham Muzaki${NC}"
echo -e "${GREEN}- Zein Aljundi${NC}"

# Konfigurasi DDHCP Server
echo "Menyiapkan konfigurasi DDHCP server..."
cat <<EOL | sudo tee /etc/default/isc-dhcp-server
INTERFACESv4="eth1.10"
EOL

# Mengaktifkan IP forwarding dan mengonfigurasi IPTables
echo "Mengaktifkan IP forwarding dan mengonfigurasi IPTables..."
sudo sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A OUTPUT -p tcp --dport 30002 -j ACCEPT
sudo iptables -A OUTPUT -p tcp --dport 30004 -j ACCEPT

echo "Restart DHCP Server..."
sudo systemctl restart isc-dhcp-server

sudo ip route add 192.168.200.0/24 via 192.168.17.2

echo "Konfigurasi Ubuntu Selesai"

echo -e "${GREEN}██   ██  █████  ██   ██ ██      ██ ██     ████████ ███████  █████  ███    ███ ${NC}"
echo -e "${GREEN}██  ██  ██   ██ ██   ██ ██      ██ ██        ██    ██      ██   ██ ████  ████ ${NC}"
echo -e "${GREEN}█████   ███████ ███████ ██      ██ ██        ██    █████   ███████ ██ ████ ██ ${NC}"
echo -e "${GREEN}██  ██  ██   ██ ██   ██ ██ ██   ██ ██        ██    ██      ██   ██ ██  ██  ██ ${NC}"
echo -e "${GREEN}██   ██ ██   ██ ██   ██ ██  █████  ██        ██    ███████ ██   ██ ██      ██ ${NC}"                                                       

echo -e "${GREEN}- Dimas Firmansah${NC}"
echo -e "${GREEN}- Gilar Bimo Tio Altan${NC}"
echo -e "${GREEN}- Jenar Adi Raditya${NC}"
echo -e "${GREEN}- Muhammad Khosy Pahala${NC}"
echo -e "${GREEN}- Rafi Ilham Muzaki${NC}"
echo -e "${GREEN}- Zein Aljundi${NC}"