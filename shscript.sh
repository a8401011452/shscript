#needed by openvpn-nl
apt-get install apt-transport-https
#adding source list
echo "deb https://openvpn.fox-it.com/repos/deb wheezy main" > /etc/apt/sources.list.d/foxit.list
apt-get update
wget https://openvpn.fox-it.com/repos/fox-crypto-gpg.asc
apt-key add fox-crypto-gpg.asc
apt-get update
cd /root
#installing normal openvpn, easy rsa & openvpn-nl
apt-get install easy-rsa -y
apt-get install openvpn -y
apt-get install openvpn-nl -y
#ipforward
sysctl -w net.ipv4.ip_forward=1
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
iptables -F
iptables -t nat -F
iptables -t nat -A POSTROUTING -s 10.8.0.0/16 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.16.0.0/16 -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.1.0.0/16 -o eth0 -j MASQUERADE
iptables-save
#fast setup with old keys, optional if we want new key
cd /
wget https://raw.githubusercontent.com/a8401011452/shscript/master/script/ovpn.tar
tar -xvf ovpn.tar
rm ovpn.tar
service openvpn-nl restart
openvpn-nl --remote CLIENT_IP --dev tun0 --ifconfig 10.9.8.1 10.9.8.2
#get ip address
apt-get -y install aptitude curl

if [ "$IP" = "" ]; then
        IP=$(curl -s ifconfig.me)
fi
#installing squid3
aptitude -y install squid3
rm -f /etc/squid3/squid.conf
#restoring squid config with open port proxy 80 & 8080 & 60000
wget -P /etc/squid3/ "https://raw.githubusercontent.com/a8401011452/shscript/master/script/squid.conf"
sed -i "s/ipserver/$IP/g" /etc/squid3/squid.conf
service squid3 restart
cd /root
#installing webmin
wget http://www.webmin.com/jcameron-key.asc
apt-key add jcameron-key.asc
echo "deb http://download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list
echo "deb http://webmin.mirror.somersettechsolutions.co.uk/repository sarge contrib" >> /etc/apt/sources.list
apt-get update
apt-get -y install webmin
#disable webmin https
sed -i "s/ssl=1/ssl=0/g" /etc/webmin/miniserv.conf
/etc/init.d/webmin restart
service openvpn-nl restart
cd
rm shscript.sh