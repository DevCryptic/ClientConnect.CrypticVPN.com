RCLOCAL='/etc/rc.local'

sed -i "1 a\iptables -A FORWARD -p tcp -m tcp --dport 25 -j DROP" $RCLOCAL
sed -i "1 a\iptables -A FORWARD -p udp -m udp --dport 25 -j DROP" $RCLOCAL
sed -i "1 a\iptables -A FORWARD -p tcp -m tcp --dport 587 -j DROP" $RCLOCAL
sed -i "1 a\iptables -A FORWARD -p udp -m udp --dport 587 -j DROP" $RCLOCAL
sed -i "1 a\iptables -A FORWARD -p tcp -m tcp --dport 26 -j DROP" $RCLOCAL
sed -i "1 a\iptables -A FORWARD -p udp -m udp --dport 26 -j DROP" $RCLOCAL
sed -i "1 a\iptables -A FORWARD -p udp -m udp --dport 110 -j DROP" $RCLOCAL
sed -i "1 a\iptables -A FORWARD -p tcp -m tcp --dport 110 -j DROP" $RCLOCAL
sed -i "1 a\iptables -A FORWARD -p tcp -m tcp --dport 995 -j DROP" $RCLOCAL
sed -i "1 a\iptables -A FORWARD -p udp -m udp --dport 995 -j DROP" $RCLOCAL
sed -i "1 a\iptables -A FORWARD -p udp -m udp --dport 143 -j DROP" $RCLOCAL
sed -i "1 a\iptables -A FORWARD -p tcp -m tcp --dport 143 -j DROP" $RCLOCAL
sed -i "1 a\iptables -A FORWARD -p tcp -m tcp --dport 993 -j DROP" $RCLOCAL
sed -i "1 a\iptables -A FORWARD -p udp -m udp --dport 993 -j DROP" $RCLOCAL
sed -i "1 a\iptables -A FORWARD -p tcp -m tcp --dport 465 -j DROP" $RCLOCAL
sed -i "1 a\iptables -A FORWARD -p udp -m udp --dport 465 -j DROP" $RCLOCAL


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
service iptables save