#!/bin/sh
ipaddr=`curl getipaddr.net -s | head -n 1`
echo "Stopping firewall and allowing everyone..."
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 ! -d 10.8.0.0/24 -j SNAT --to $ipaddr
iptables -t nat -A POSTROUTING -s 10.8.1.0/24 ! -d 10.8.1.0/24 -j SNAT --to $ipaddr
service iptables save
service openvpn restart