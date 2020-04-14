#!/bin/bash

#asking for hostname
read -p "Hostname: " -e -i $HOSTNAME HOSTNAME

HOST=$(echo ${HOSTNAME} | cut -d'.' -f1)
COUNTRY=$(echo ${HOST} | cut -d'-' -f1)
CITY=$(echo ${HOST} | cut -d'-' -f2)
USER=initial
RADIUS_IP="107.191.96.57"
RADIUS_SECRET=""

if [[ ! $RADIUS_IP ]]; then
	read -p "Radius IP address: " RADIUS_IP
fi

if [[ ! $RADIUS_SECRET ]]; then
	read -p "Radius Secret: " RADIUS_SECRET
fi
	
if [[ "$EUID" -ne 0 ]]; then
	echo "Sorry, you need to run this as root"
	exit 1
fi
if [[ ! -e /dev/net/tun ]]; then
	echo "TUN/TAP is not available"
	exit 2
fi
if grep -qs "CentOS release 5" "/etc/redhat-release"; then
	echo "CentOS 5 is too old and not supported"
	exit 3
fi

if [[ -e /etc/debian_version ]]; then
	OS=debian
	RCLOCAL='/etc/rc.local'
elif [[ -e /etc/centos-release || -e /etc/redhat-release ]]; then
	OS=centos
	RCLOCAL='/etc/rc.d/rc.local'
	# Needed for CentOS 7
	chmod +x /etc/rc.d/rc.local
else
	echo "Looks like you aren't running this installer on a Debian, Ubuntu or CentOS system"
	exit 4
fi

newclient () {
echo "client
dev tun
proto tcp
remote ${HOSTNAME} 443
resolv-retry infinite
nobind
tun-mtu 1500
tun-mtu-extra 32
mssfix 1450
persist-key
persist-tun
remote-cert-tls server
auth-nocache
auth-user-pass
comp-lzo
verb 3
<ca>" > ~/cVPN-${COUNTRY}-${CITY}-tcp443.ovpn
cat /etc/openvpn/easy-rsa/pki/ca.crt >> ~/cVPN-${COUNTRY}-${CITY}-tcp443.ovpn
echo "</ca>" >> ~/cVPN-${COUNTRY}-${CITY}-tcp443.ovpn

echo "client
dev tun
proto udp
remote ${HOSTNAME} 1194
resolv-retry infinite
nobind
tun-mtu 1500
tun-mtu-extra 32
mssfix 1450
persist-key
persist-tun
remote-cert-tls server
auth-nocache
auth-user-pass
comp-lzo
verb 3
<ca>" > ~/cVPN-${COUNTRY}-${CITY}-udp1194.ovpn
cat /etc/openvpn/easy-rsa/pki/ca.crt >> ~/cVPN-${COUNTRY}-${CITY}-udp1194.ovpn
echo "</ca>" >> ~/cVPN-${COUNTRY}-${CITY}-udp1194.ovpn
}

freeradiusinstall () {
if [[ "$OS" = 'debian' ]]; then
	apt-get install libgcrypt11 libgcrypt11-dev gcc make build-essential -y
else
	yum install libgcrypt libgcrypt-devel ftp gcc-c++ -y
fi

cd /tmp
wget -O /tmp/radiusplugin_v2.1a_beta1.tar.gz http://www.nongnu.org/radiusplugin/radiusplugin_v2.1a_beta1.tar.gz
tar xvfz /tmp/radiusplugin_v2.1a_beta1.tar.gz
cd /tmp/radiusplugin_v2.1a_beta1/
make
cp /tmp/radiusplugin_v2.1a_beta1/radiusplugin.so /etc/openvpn/
cp /tmp/radiusplugin_v2.1a_beta1/radiusplugin.cnf /etc/openvpn/
sed -i -e "s/192.168.0.153/${RADIUS_IP}/g" /etc/openvpn/radiusplugin.cnf
sed -i -e "s/testpw/${RADIUS_SECRET}/g" /etc/openvpn/radiusplugin.cnf
echo "plugin /etc/openvpn/radiusplugin.so /etc/openvpn/radiusplugin.cnf" >> /etc/openvpn/server.conf
echo "plugin /etc/openvpn/radiusplugin.so /etc/openvpn/radiusplugin.cnf" >> /etc/openvpn/tcp.conf
service openvpn restart
}

IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
if [[ "$IP" = "" ]]; then
		IP=$(wget -qO- ipv4.icanhazip.com)
fi


if [[ -e /etc/openvpn/server.conf ]]; then
	echo "Looks like OpenVPN is already installed"
	exit 1
else
	clear
	echo "Please confirm the IPv4 address of the network interface you want OpenVPN"
	echo "listening to."
	read -p "IP address: " -e -i $IP IP
	echo ""
	echo "Okay, that was all I needed. We are ready to setup your OpenVPN server now"
	read -n1 -r -p "Press any key to continue..."
	if [[ "$OS" = 'debian' ]]; then
		apt-get update
		apt-get install openvpn iptables openssl ca-certificates -y
	else
		# Else, the distro is CentOS
		yum install epel-release -y
		yum install openvpn iptables openssl wget ca-certificates -y
	fi
	# An old version of easy-rsa was available by default in some openvpn packages
	if [[ -d /etc/openvpn/easy-rsa/ ]]; then
		rm -rf /etc/openvpn/easy-rsa/
	fi
	# Get easy-rsa
	wget -O ~/EasyRSA-3.0.1.tgz https://github.com/OpenVPN/easy-rsa/releases/download/3.0.1/EasyRSA-3.0.1.tgz
	tar xzf ~/EasyRSA-3.0.1.tgz -C ~/
	mv ~/EasyRSA-3.0.1/ /etc/openvpn/
	mv /etc/openvpn/EasyRSA-3.0.1/ /etc/openvpn/easy-rsa/
	chown -R root:root /etc/openvpn/easy-rsa/
	rm -rf ~/EasyRSA-3.0.1.tgz
	cd /etc/openvpn/easy-rsa/
	# Create the PKI, set up the CA, the DH params and the server + client certificates
	./easyrsa init-pki
	./easyrsa --batch build-ca nopass
	./easyrsa gen-dh
	./easyrsa build-server-full server nopass
	./easyrsa build-client-full $USER nopass
	./easyrsa gen-crl
	# Move the stuff we need
	cp pki/ca.crt pki/private/ca.key pki/dh.pem pki/issued/server.crt pki/private/server.key /etc/openvpn
	# Generate server.conf
	echo "port 1194 #- port
proto udp #- protocol
dev tun
tun-mtu 1500
tun-mtu-extra 32
mssfix 1450
reneg-sec 0
ca /etc/openvpn/ca.crt
cert /etc/openvpn/server.crt
key /etc/openvpn/server.key
dh /etc/openvpn/dh.pem
client-cert-not-required
username-as-common-name
server 10.8.0.0 255.255.255.0" > /etc/openvpn/server.conf
	echo 'push "redirect-gateway def1"' >> /etc/openvpn/server.conf
	echo 'push "dhcp-option DNS 8.8.8.8"' >> /etc/openvpn/server.conf
	echo 'push "dhcp-option DNS 8.8.4.4"' >> /etc/openvpn/server.conf
	echo "keepalive 5 30
comp-lzo
persist-key
persist-tun
status 1194.log
verb 3" >> /etc/openvpn/server.conf

	#Generate tcp.conf
	echo "port 443 #- port
proto tcp #- protocol
dev tun
tun-mtu 1500
tun-mtu-extra 32
mssfix 1450
reneg-sec 0
ca /etc/openvpn/ca.crt
cert /etc/openvpn/server.crt
key /etc/openvpn/server.key
dh /etc/openvpn/dh.pem
plugin /etc/openvpn/radiusplugin.so /etc/openvpn/radiusplugin.cnf
client-cert-not-required
username-as-common-name
server 10.8.1.0 255.255.255.0"  > /etc/openvpn/tcp.conf
	echo 'push "redirect-gateway def1"' >> /etc/openvpn/tcp.conf
	echo 'push "dhcp-option DNS 8.8.8.8"' >> /etc/openvpn/tcp.conf
	echo 'push "dhcp-option DNS 8.8.4.4"' >> /etc/openvpn/tcp.conf
	echo "keepalive 5 30
comp-lzo
persist-key
persist-tun
status 443.log
verb 3" >> /etc/openvpn/tcp.conf
	# Enable net.ipv4.ip_forward for the system
	if [[ "$OS" = 'debian' ]]; then
		sed -i 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|' /etc/sysctl.conf
	else
		# CentOS 5 and 6
		sed -i 's|net.ipv4.ip_forward = 0|net.ipv4.ip_forward = 1|' /etc/sysctl.conf
		# CentOS 7
		if ! grep -q "net.ipv4.ip_forward=1" "/etc/sysctl.conf"; then
			echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
		fi
	fi
	# Avoid an unneeded reboot
	echo 1 > /proc/sys/net/ipv4/ip_forward
	# Set NAT for the VPN subnet
	iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j SNAT --to $IP
	iptables -t nat -A POSTROUTING -s 10.8.1.0/24 -j SNAT --to $IP
	#sed -i "1 a\iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j SNAT --to $IP" $RCLOCAL
	#sed -i "1 a\iptables -t nat -A POSTROUTING -s 10.8.1.0/24 -j SNAT --to $IP" $RCLOCAL
	sed -i "1 a\wget clientconnect.crypticvpn.com/ip.sh; chmod +x ip.sh; sh ip.sh; rm -rf ip.sh;" $RCLOCAL
	#if pgrep firewalld; then
		# We don't use --add-service=openvpn because that would only work with
		# the default port. Using both permanent and not permanent rules to
		# avoid a firewalld reload.
	#	firewall-cmd --zone=public --add-port=1194/udp
	#	firewall-cmd --zone=public --add-port=443/tcp
	#	firewall-cmd --zone=trusted --add-source=10.8.0.0/24
	#	firewall-cmd --zone=trusted --add-source=10.8.1.0/24
	#	firewall-cmd --permanent --zone=public --add-port=443/tcp
	#	firewall-cmd --permanent --zone=trusted --add-source=10.8.0.0/24
	#fi
	#if iptables -L | grep -qE 'REJECT|DROP'; then
		# If iptables has at least one REJECT rule, we asume this is needed.
		# Not the best approach but I can't think of other and this shouldn't
		# cause problems.
	#	iptables -I INPUT -p tcp --dport 443 -j ACCEPT
	#	iptables -I INPUT -p udp --dport 1194 -j ACCEPT
	#	iptables -I FORWARD -s 10.8.0.0/24 -j ACCEPT
	#	iptables -I FORWARD -s 10.8.1.0/24 -j ACCEPT
	#	iptables -I FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
	#	sed -i "1 a\iptables -I INPUT -p tcp --dport 443 -j ACCEPT" $RCLOCAL
	#	sed -i "1 a\iptables -I FORWARD -s 10.8.0.0/24 -j ACCEPT" $RCLOCAL
	#	sed -i "1 a\iptables -I INPUT -p udp --dport 1194 -j ACCEPT" $RCLOCAL
	#	sed -i "1 a\iptables -I FORWARD -s 10.8.1.0/24 -j ACCEPT" $RCLOCAL
	#	sed -i "1 a\iptables -I FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT" $RCLOCAL
	#fi
	# And finally, restart OpenVPN
	if [[ "$OS" = 'debian' ]]; then
		# Little hack to check for systemd
		if pgrep systemd-journal; then
			systemctl restart openvpn@server.service
		else
			/etc/init.d/openvpn restart
		fi
	else
		if pgrep systemd-journal; then
			systemctl restart openvpn@server.service
			systemctl enable openvpn@server.service
		else
			service openvpn restart
			chkconfig openvpn on
		fi
	fi

	# Generates the custom client.ovpn
	newclient "$USER"
	freeradiusinstall
	echo ""
	echo "Finished!"
	echo ""
	echo "TCP config is available at ~/cVPN-${COUNTRY}-${CITY}-tcp443.ovpn"
	echo "UDP config is available at ~/cVPN-${COUNTRY}-${CITY}-udp1194.ovpn"
	echo ""
	echo "RADIUS CONFIG BEGIN"
	echo ""
	echo "client ${HOSTNAME} {"
        echo "secret = $RADIUS_SECRET"
        echo "shortname	= $RADIUS_SECRET"
        echo "nastype = other"
        echo "}"
	echo ""
	echo "RADIUS CONFIG END"	
fi

USERNAME="cryptic"
PASSWORD="DQL^ZIt!4M1RQnM"
SERVER="107.161.24.101"
# Directory where file is located
DIR="/root/"
#  Filename of backup file to be transfered
FILE1="cVPN-${COUNTRY}-${CITY}-tcp443.ovpn"
FILE2="cVPN-${COUNTRY}-${CITY}-udp1194.ovpn"
# login to ftp server and transfer file
cd $DIR
ftp -n -i $SERVER <<EOF
user $USERNAME $PASSWORD
binary
put $FILE1
put $FILE2
quit
EOF
# End of script

echo "Files have been uploaded to downloads server"

