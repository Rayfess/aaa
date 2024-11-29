#!/bin/bash

# Variabel Konfigurasi
VLAN_INTERFACE="eth1.10"
VLAN_ID=10
IP_ADDR="$IP_Router$IP_Pref"      # IP address untuk interface VLAN di Ubuntu

# Destinasi folder
DHCP_CONF="/etc/dhcp/dhcpd.conf" #Tempat Konfigurasi DHCP
NETPLAN_CONF="/etc/netplan/01-netcfg.yaml" # Tempat Konfigurasi Netplan
DDHCP_CONF="/etc/default/isc-dhcp-server" #Tempat konfigurasi default DHCP
SYSCTL_CONF="/etc/sysctl.conf" #Tempat Konfigurasi IP Forwarding

#Ip PNETLAB
IPNET="192.168.74.137"

#ip default perangkat
IPC="192.168.1.254"
IPU="192.168.17.1"
IPROUTE_ADD="192.168.200.1/24"

#MIKROTIK
MIKROTIK_IP="192.168.200.1"     # IP MikroTik yang baru
MIKROTIK_S="192.168.200.0"
MPORT="30004"

#CISCO
SPORT="30002"

#Konfigurasi IP Yang Anda Inginkan
IP_A="17"
IP_B="200"
IP_C="2"
IP_BC="255.255.255.0"
IP_Subnet="192.168.$IP_A.0"
IP_Router="192.168.$IP_A.1"
IP_Range="192.168.$IP_A.$IP_C 192.168.$IP_A.$IP_B"
IP_DNS="8.8.8.8, 8.8.4.4"
IP_Pref="/24"

# FIX DHCP
IP_FIX="192.168.17.10"
IP_MAC="00:50:79:66:68:06"

set -e

cat << "EOF

 ██████╗ ████████╗ ██████╗ ███╗   ███╗ █████╗ ███████╗██╗        
██╔═══██╗╚══██╔══╝██╔═══██╗████╗ ████║██╔══██╗██╔════╝██║        
██║   ██║   ██║   ██║   ██║██╔████╔██║███████║███████╗██║        
██║   ██║   ██║   ██║   ██║██║╚██╔╝██║██╔══██║╚════██║██║        
╚██████╔╝   ██║   ╚██████╔╝██║ ╚═╝ ██║██║  ██║███████║██║        
 ╚═════╝    ╚═╝    ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝╚═╝        
 
     ██╗███████╗███╗   ██╗ █████╗ ██████╗      █████╗ ██████╗ ██╗
     ██║██╔════╝████╗  ██║██╔══██╗██╔══██╗    ██╔══██╗██╔══██╗██║
     ██║█████╗  ██╔██╗ ██║███████║██████╔╝    ███████║██║  ██║██║
██   ██║██╔══╝  ██║╚██╗██║██╔══██║██╔══██╗    ██╔══██║██║  ██║██║
╚█████╔╝███████╗██║ ╚████║██║  ██║██║  ██║    ██║  ██║██████╔╝██║
 ╚════╝ ╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═╝    ╚═╝  ╚═╝╚═════╝ ╚═╝                                                              
EOF



echo "Inisialisasi awal ..."
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

#Konfigurasi Pada Netplan
echo "Mengkonfigurasi netplan..."
cat <<EOF | sudo tee $NETPLAN_CONF
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
       addresses: [$IP_Router$IP_Pref]
EOF

sudo netplan apply

#  Konfigurasi DHCP Server
echo "Menyiapkan konfigurasi DHCP server..."
cat <<EOL | sudo tee $DHCP_CONF
# Konfigurasi subnet untuk VLAN 10
subnet $IP_Subnet netmask $IP_BC {
    range $IP_Range;
    option routers $IP_Router;
    option subnet-mask $IP_BC;
    option domain-name-servers $IP_DNS;
    default-lease-time 600;
    max-lease-time 7200;
}

# Konfigurasi Fix DHCP
host fantasia {
  hardware ethernet $IP_MAC;
  fixed-address $IP_FIX;
}
EOL

#  Konfigurasi DDHCP Server
echo "Menyiapkan konfigurasi DDHCP server..."
cat <<EOL | sudo tee $DDHCP_CONF
INTERFACESv4="$VLAN_INTERFACE"
EOL

# Mengaktifkan IP forwarding dan inisialisasi IPTables
echo "Mengaktifkan IP forwarding dan mengonfigurasi IPTables..."
sudo sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" | sudo tee -a $SYSCTL_CONF
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A OUTPUT -p tcp --dport $SPORT -j ACCEPT
sudo iptables -A OUTPUT -p tcp --dport $MPORT -j ACCEPT
sudo ufw allow $SPORT/tcp
sudo ufw allow $MPORT/tcp
sudo ufw allow from $IPNET to any port $SPORT
sudo ufw allow from $IPNET to any port $MPORT
sudo ufw reload
sudo DEBIAN_FRONTEND=noninteractive apt install -y iptables-persistent
sudo netfilter-persistent save

echo "Restart DHCP Server..."
sudo systemctl restart isc-dhcp-server

# sudo ip route add 192.168.200.0 via 192.168.17.2

echo "Konfigurasi Ubuntu Selesai"



























#Konfig Screen
#sudo apt install screen
#sudo screen /dev/tty*(ttyS0) 9600
#Ctrl A K

#Konfig Awal Cisco Switch IoL 2
# en
# conf t
# hostname CiscoSW
# int vl 1
# no sh
# ip add 192.168.1.1 255.255.255.0
# line vty 0 4
# login local
# transport input ssh
# exit

#Konfig Awal Mikrotik
# /system identity set name=MikroTik1
# /ip address add address=192.168.17.100/24 interface=ether1
# /ip service enable ssh