#!/bin/bash
LOG() {
    case "$1" in
        r)
            echo -e "\033[0;31m $2 \033[0m"
            ;;
        g)
            echo -e "\033[0;32m $2 \033[0m"
            ;;
        *)
            echo -e "\033[0;34m $1 \033[0m"
            ;;
    esac
}

get_ip() {
    eth=`ifconfig | grep -Eo ".*: " | grep -Eo "\w*" | grep -v lo`
    ip=`ifconfig $eth| grep -Eo "inet [0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | grep -Eo "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*"`
    ethnum=`ifconfig | grep -Eo ".*: " | grep -Eo "\w*" | grep -v -c lo`
    ethnum=$((ethnum))
    if [ $ethnum != 1 ];then
            LOG g "Input IP"
            read ip
            eth=`ifconfig | grep -B1 "inet $ip" | awk '$1!="inet" && $1!="--" {print $1}'|cut -d ":" -f1`
    fi
    LOG "YourIP: $ip"
    LOG "Yoereth: $eth"
}
apt update
apt install cron ufw unzip curl net-tools
bash <(curl -fsSL https://get.hy2.sh/)
LOG "Enter domain name: (Use Acme)"
read domain
email=$(echo $domain | sed 's/\.//g')@gmail.com
#@sharklasers.com
LOG "Input port: (default 443)"
read port
port=${port:-443}
ufw allow $port
get_ip
LOG "Enter Password"
read password
LOG "QUIC config?(y(default)/n)"
read x1
if [[ $x1 != "n" ]];then
quic="quic:
  initStreamReceiveWindow: 26843545 
  maxStreamReceiveWindow: 26843545 
  initConnReceiveWindow: 67108864 
  maxConnReceiveWindow: 67108864
  maxIdleTimeout: 60s 
  maxIncomingStreams: 1024
  disablePathMTUDiscovery: false"
# 将发送、接收两个缓冲区都设置为 16 MB
cat /etc/sysctl.conf|grep 16777216
if [[ $? == 1 ]];then
sysctl -w net.core.rmem_max=16777216
sysctl -w net.core.wmem_max=16777216
cat << EOF >> /etc/sysctl.conf
net.core.rmem_max=16777216
net.core.wmem_max=16777216
EOF
cat /etc/sysctl.conf|grep 16777216
else
LOG r "Has same ruls"
fi
fi
LOG "Masquerade method\n\t1. proxy(bing,default)\n\t2. file"
read x2
if [[ $x2 == "2" ]];then

cd /root
rm -rf site_back
rm -rf mv_tmp
mkdir site_back
mkdir mv_tmp
mkdir -p /var/www/html
cd mv_tmp
curl -JLo html.zip https://github.com/yoier/hysteria2-script/archive/refs/tags/0.0.1.zip
unzip html.zip
cd hysteria2-script*
mv -f /var/www/html/* /root/site_back
mv -f html/* /var/www/html
cd /root
rm -rf mv_tmp
#可更换mv内容html
ls /var/www/html
ufw allow 80
ufw allow 443
masquerade="masquerade:
  listenHTTP: :80
  listenHTTPS: :443
  forceHTTPS: true
  type: file
  file:
    dir: /var/www/html"
else
masquerade="masquerade:
  type: proxy
  proxy:
    url: https://bing.com
    rewriteHost: true"
fi

LOG "Port Hopping(num:num);null mean off"
read scope
if [[ $scope != "" ]];then
iptables -t nat -L|grep "$scope"
if [[ $? == 1 ]];then
ufw allow $scope/udp
iptables -t nat -A PREROUTING -i $eth -p udp --dport $scope -j DNAT --to-destination :$port
cat /etc/rc.local|grep "exit 0"
if [[ $? == 1 ]];then
echo "iptables -t nat -A PREROUTING -i $eth -p udp --dport $scope -j DNAT --to-destination :$port" >> /etc/rc.local
else
sed -i "/^exit 0/i\iptables -t nat -A PREROUTING -i $eth -p udp --dport $scope -j DNAT --to-destination :$port" /etc/rc.local
fi
iptables -t nat -L|grep "$scope"
cat /etc/rc.local|grep "$scope"
else
LOG r "Has same scope"
fi
fi

cat << EOF > /etc/hysteria/config.yaml
listen: $ip:$port

acme:
  domains:
    - $domain
  email: $email

auth:
  type: password
  password: $password

$quic

$masquerade

EOF

crontab -l|grep "https://get.hy2.sh/"
if [[ $? == 1 ]];then
LOG g "crontab:"
(crontab -l; echo "0 6 * * 1 bash <(curl -fsSL https://get.hy2.sh/)") | crontab -
crontab -l|grep "https://get.hy2.sh/"
else
LOG r "Has same cron"
fi

LOG g "Start hysteria?(y/n(default))"
read x3
if [[ $x3 == "y" ]];then
systemctl enable hysteria-server.service
systemctl restart hysteria-server.service
fi

LOG g "config:"
cat /etc/hysteria/config.yaml
LOG g "\n\tscope=$scope\n\t"

LOG g "Enable ufw?(y/n(default))"
read x4
if [[ $x4 == "y" ]];then
ufw enable
ufw status
fi
