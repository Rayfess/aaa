#!/bin/bash

IPNET="192.168.74.137"
SPORT="30002"

{
    sleep 1
    echo "enable"
    sleep 1
    echo "configure terminal"
    sleep 1
    echo "int e0/1"
    sleep 1
    echo "sw mo acc"
    sleep 1
    echo "sw acc vl 10"
    sleep 1
    echo "no sh"
    sleep 1
    echo "exit"
    sleep 1
    echo "interface e0/0"
    sleep 1
    echo "sw tr encap do"
    sleep 1
    echo "sw mo tr"
    sleep 1
    echo "no sh"
    sleep 1
    echo "exit"
    sleep 1
} | telnet $IPNET $SPORT > /dev/null

sleep 2

# Memastikan script keluar dengan kode status yang benar
if [ $? -eq 0 ]; then
    echo "Konfigurasi CISCO berhasil diterapkan."
else
    echo "Terjadi kesalahan saat menerapkan konfigurasi."
fi
