#!/bin/bash

# Kode warna
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

# Fungsi untuk menampilkan animasi loading
function loading_animation {
    local delay=0.5
    local dots=""
    while true; do
        echo -ne "${YELLOW}Sedang mengkonfigurasi${dots}...${RESET}\r"
        sleep $delay
        dots+="."
        # Batasi jumlah titik agar tidak terlalu banyak
        if [ ${#dots} -ge 3 ]; then
            dots=""
        fi
    done
}

# Menjalankan animasi di background
loading_animation &

# Menyimpan PID dari background job
loading_pid=$!

# Menambah Repositori Kartolo
{
    echo "deb http://kartolo.sby.datautama.net.id/ubuntu/ focal main restricted universe multiverse"
    echo "deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-updates main restricted universe multiverse"
    echo "deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-security main restricted universe multiverse"
    echo "deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-backports main restricted universe multiverse"
    echo "deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-proposed main restricted universe multiverse"
} | sudo tee /etc/apt/sources.list > /dev/null

# Cek status exit dari perintah sebelumnya
if [ $? -eq 0 ]; then
    # Jika berhasil, hentikan animasi
    kill $loading_pid
    echo -e "${GREEN}✅ Konfigurasi selesai!${RESET}"
    
    # Lanjutkan dengan perintah berikutnya
    # Contoh perintah tambahan (misalnya update)
    echo "Menjalankan perintah selanjutnya..."
    sudo apt update
else
    # Jika gagal, hentikan animasi dan tampilkan pesan kesalahan
    kill $loading_pid
    echo -e "${RED}❌ Gagal menambahkan repositori!${RESET}"
    exit 1
fi