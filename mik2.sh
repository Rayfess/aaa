#!/bin/bash

expect << EOF

spawn telnet 192.168.74.137 30004
expect "Mikrotik Login:"
send "admin\r"

expect "Password:"
send "\r"

expect ">"
send "n"

expect "new password"
send "123\r"

expect "repeat new password"
send "123\r"

expect ">"
send "/ip address add address=192.168.200.1/24 interface=ether2\r"

expect ">"
send "/ip address add address=192.168.17.2/24 interface=ether1\r"

expect ">"
send "/ip pool add name=dhcp_pool ranges=192.168.200.2-192.168.200.200\r"

expect ">"
send "/ip dhcp-server add name=dhcp1 interface=ether2 address-pool=dhcp_pool\r"

expect ">"
send "/ip dhcp-server network add address=192.168.200.0/24 gateway=192.168.200.1 dns-server=8.8.8.8\r"

expect ">"
send "/ip dhcp-server enable dhcp1\r"

expect ">"
send "/ip firewall nat add chain=srcnat out-interface=ether1 action=masquerade\r"

expect ">"
send "/ip route add gateway=192.168.17.1\r"

expect eof

EOF

sudo systemctl restart isc-dhcp-server
sudo systemctl restart isc-dhcp-server
sudo systemctl restart isc-dhcp-server