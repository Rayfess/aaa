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
        echo -ne "${YELLOW}Sedang mengkonfigurasi DHCP server${dots}...${RESET}\r"
        sleep $delay
        dots+="."
        # Batasi jumlah titik agar tidak terlalu banyak
        if [ ${#dots} -ge 3 ]; then
            dots=""
        fi
    done
}

# Menginstal isc-dhcp-server
echo -e "${YELLOW}Menginstal isc-dhcp-server...${RESET}"
sudo apt update > /dev/null 2>&1
sudo apt install -y isc-dhcp-server > /dev/null 2>&1

# Cek status instalasi
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Gagal menginstal isc-dhcp-server!${RESET}"
    exit 1
else
    echo -e "${GREEN}✅ Berhasil menginstal isc-dhcp-server!${RESET}"
fi

# Menentukan interface jaringan (ganti dengan nama interface yang sesuai)
INTERFACE="eth0"  # Ganti dengan nama interface yang benar

# Mengonfigurasi file /etc/dhcp/dhcpd.conf
echo -e "${YELLOW}Mengonfigurasi DHCP server...${RESET}"
loading_animation &

# Menyimpan PID dari animasi loading
loading_pid=$!

# Menulis konfigurasi DHCP
cat <<EOL | sudo tee /etc/dhcp/dhcpd.conf > /dev/null
# Konfigurasi DHCP Server
option domain-name "example.org";
option domain-name-servers ns1.example.org, ns2.example.org;

default-lease-time 600;
max-lease-time 7200;

subnet 192.168.1.0 netmask 255.255.255.0 {
    range 192.168.1.10 192.168.1.100;
    option routers 192.168.1.1;
    option broadcast-address 192.168.1.255;
}
EOL

# Hentikan animasi loading
kill $loading_pid
wait $loading_pid 2>/dev/null  # Tunggu proses loading berhenti

# Cek status penulisan konfigurasi
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Gagal mengonfigurasi DHCP server!${RESET}"
    exit 1
else
    echo -e "${GREEN}✅ Berhasil mengonfigurasi DHCP server!${RESET}"
fi

# Mengonfigurasi interface jaringan di /etc/default/isc-dhcp-server
echo -e "${YELLOW}Mengonfigurasi interface jaringan...${RESET}"
sudo sed -i "s/INTERFACESv4=\"\"/INTERFACESv4=\"$INTERFACE\"/" /etc/default/isc-dhcp-server

# Memulai dan mengaktifkan layanan DHCP
echo -e "${YELLOW}Memulai layanan DHCP server...${RESET}"
sudo systemctl restart isc-dhcp-server

# Cek status layanan DHCP
if systemctl is-active --quiet isc-dhcp-server; then
    echo -e "${GREEN}✅ Layanan DHCP server berhasil dijalankan!${RESET}"
else
    echo -e "${RED}❌ Gagal menjalankan layanan DHCP server!${RESET}"
    exit 1
fi

# Menampilkan informasi status
echo -e "${GREEN}✅ Konfigurasi DHCP server selesai!${RESET}"