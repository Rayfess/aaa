#!/bin/bash

# Kode warna untuk umpan balik
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

# Menampilkan pesan awal
echo "Inisialisasi awal ..."

# Menambahkan repositori Kartolo
echo "Menambahkan repositori Kartolo..."
cat <<EOF | sudo tee /etc/apt/sources.list > /dev/null
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-updates main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-security main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-backports main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-proposed main restricted universe multiverse
EOF

# Cek keberhasilan menambahkan repositori
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Berhasil menambahkan repositori!${RESET}"
else
    echo -e "${RED}❌ Gagal menambahkan repositori!${RESET}"
    exit 1
fi

# Update dan instal paket
echo "Mengupdate daftar paket dan menginstal isc-dhcp-server..."
sudo apt update -y > /dev/null
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Gagal mengupdate daftar paket!${RESET}"
    exit 1
fi

sudo apt install -y isc-dhcp-server expect > /dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Berhasil menginstal isc-dhcp-server dan expect!${RESET}"
else
    echo -e "${RED}❌ Gagal menginstal isc-dhcp-server dan expect!${RESET}"
    exit 1
fi

# Konfigurasi Pada Netplan
echo "Mengonfigurasi Netplan..."
cat <<EOF | sudo tee /etc/netplan/01-netcfg.yaml > /dev/null
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

# Cek keberhasilan konfigurasi Netplan
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Berhasil mengonfigurasi Netplan!${RESET}"
else
    echo -e "${RED}❌ Gagal mengonfigurasi Netplan!${RESET}"
    exit 1
fi

# Terapkan konfigurasi Netplan
echo "Menerapkan konfigurasi Netplan..."
sudo netplan apply
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Konfigurasi Netplan diterapkan!${RESET}"
else
    echo -e "${RED}❌ Gagal menerapkan konfigurasi Netplan!${RESET}"
    exit 1
fi
