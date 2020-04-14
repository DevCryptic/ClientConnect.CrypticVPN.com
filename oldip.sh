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
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j SNAT --to-source $ipaddr
iptables -t nat -A POSTROUTING -s 10.8.1.0/24 -j SNAT --to-source $ipaddr
iptables -A FORWARD -p tcp -m tcp --dport 25 -j DROP
iptables -A FORWARD -p udp -m udp --dport 25 -j DROP
iptables -A FORWARD -p tcp -m tcp --dport 587 -j DROP
iptables -A FORWARD -p udp -m udp --dport 587 -j DROP
iptables -A FORWARD -p tcp -m tcp --dport 26 -j DROP
iptables -A FORWARD -p udp -m udp --dport 26 -j DROP
iptables -A FORWARD -p udp -m udp --dport 110 -j DROP
iptables -A FORWARD -p tcp -m tcp --dport 110 -j DROP
iptables -A FORWARD -p tcp -m tcp --dport 995 -j DROP
iptables -A FORWARD -p udp -m udp --dport 995 -j DROP
iptables -A FORWARD -p udp -m udp --dport 143 -j DROP
iptables -A FORWARD -p tcp -m tcp --dport 143 -j DROP
iptables -A FORWARD -p tcp -m tcp --dport 993 -j DROP
iptables -A FORWARD -p udp -m udp --dport 993 -j DROP
iptables -A FORWARD -p tcp -m tcp --dport 465 -j DROP
iptables -A FORWARD -p udp -m udp --dport 465 -j DROP
iptables -A FORWARD -p tcp -m tcp --dport 3389 -j DROP
iptables -A FORWARD -p udp -m udp --dport 3389 -j DROP
iptables -A FORWARD -p tcp -m tcp --dport 80 -j DROP
iptables -A FORWARD -p udp -m udp --dport 80 -j DROP
iptables -A FORWARD -p tcp -m tcp --dport 8080 -j DROP
iptables -A FORWARD -p udp -m udp --dport 8080 -j DROP
service iptables save
service openvpn restart
