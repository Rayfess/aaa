#!/bin/bash

# Kode warna untuk umpan balik
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

# Fungsi untuk menampilkan animasi loading
function loading_animation {
    local delay=0.5
    local dots=""
    while true; do
        echo -ne "${YELLOW}Sedang memproses${dots}...${RESET}\r"
        sleep $delay
        dots+="."
        if [ ${#dots} -ge 3 ]; then
            dots=""
        fi
    done
}

# Menampilkan pesan awal
echo "Inisialisasi awal ..."

# Menambahkan repositori Kartolo
{
    echo "Menambahkan repositori Kartolo..."
    loading_animation &  # Jalankan animasi loading di background

    # Menulis repositori ke sources.list
    cat <<EOF | sudo tee /etc/apt/sources.list > /dev/null
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-updates main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-security main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-backports main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-proposed main restricted universe multiverse
EOF

    # Hentikan animasi loading
    kill $!
    echo -e "${GREEN}✅ Berhasil menambahkan repositori!${RESET}"
} &

# Update dan instal paket dengan animasi loading
{
    echo "Mengupdate daftar paket dan menginstal isc-dhcp-server..."
    loading_animation &  # Jalankan animasi loading di background

    sudo apt update -y > /dev/null
    sudo apt install -y isc-dhcp-server expect > /dev/null

    # Hentikan animasi loading
    kill $!
    echo -e "${GREEN}✅ Berhasil menginstal isc-dhcp-server dan expect!${RESET}"
} &

# Konfigurasi Pada Netplan
{
    echo "Mengonfigurasi Netplan..."
    loading_animation &  # Jalankan animasi loading di background

    # Menulis konfigurasi Netplan
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

    # Hentikan animasi loading
    kill $!
    echo -e "${GREEN}✅ Berhasil mengonfigurasi Netplan!${RESET}"

    # Terapkan konfigurasi Netplan
    echo "Menerapkan konfigurasi Netplan..."
    loading_animation &  # Jalankan animasi loading di background
    sudo netplan apply

    # Hentikan animasi loading
    kill $!
    echo -e "${GREEN}✅ Konfigurasi Netplan diterapkan!${RESET}"
} &

# Tunggu semua proses latar belakang selesai
wait