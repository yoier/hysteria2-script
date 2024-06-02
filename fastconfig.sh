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
            echo -e "\033[0;33m $1 \033[0m"
            ;;
    esac
}

get_ip() {
    eth=`ifconfig | grep -Eo ".*: " | grep -Eo "\w*" | grep -v lo`
    ip=`ifconfig $eth| grep -Eo "inet [0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | grep -Eo "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*"`
    ethnum=`ifconfig | grep -Eo ".*: " | grep -Eo "\w*" | grep -v -c lo`
    ethnum=$((ethnum))
    LOG "YourIP: $ip"
    #echo $ethnum
    #echo -e "all_ipaddress:\n"$ip
    use_ip=""
    if [ $ethnum != 1 ];then
            LOG g "Input IP"
            read use_ip
            eth=`ifconfig | grep -B1 "inet $ip" | awk '$1!="inet" && $1!="--" {print $1}'|cut -d ":" -f1`
    fi
}

bash <(curl -fsSL https://get.hy2.sh/)
LOG "Enter domain name: (Use Acme)"
read domain
email=$(echo $domain | sed 's/\.//g')@gmail.com
#@sharklasers.com
LOG "Input port: (default 443)"
read port
get_ip
LOG "Enter Password"
read password
LOG "QUIC config?(y(default)/n)"
read x1
if [[ $x1 == "y" ]];then
xx="quic:
  initStreamReceiveWindow: 26843545 
  maxStreamReceiveWindow: 26843545 
  initConnReceiveWindow: 67108864 
  maxConnReceiveWindow: 67108864
  maxIdleTimeout: 30s 
  maxIncomingStreams: 1024
  disablePathMTUDiscovery: false"
# 将发送、接收两个缓冲区都设置为 16 MB
sysctl -w net.core.rmem_max=16777216
sysctl -w net.core.wmem_max=16777216
cat << EOF >> /etc/sysctl.conf
net.core.rmem_max=16777216
net.core.wmem_max=16777216
EOF
fi
LOG "Masquerade method\n\t1. proxy(bing)\n\t2. file"
read x2
if [[ $x2 == "2" ]];then

cd /root
mkdir site_back
mkdir mv_tmp
cd mv_tmp
curl -JLo html.zip https://github.com/yoier/d4099fef0beb59b6/archive/refs/tags/rls.zip
unzip html.zip
cd hysteria2-scripts
mv -f /var/www/html/* /root/site_tp
mv -f html/* /var/www/html
cd /root
rm -rf mv_tmp
#可更换mv内容html
ls /var/www/html

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

LOG "Port Hopping(num:num)"
read scope
if [[ $scope != "" ]];then
iptables -t nat -A PREROUTING -i $eth -p udp --dport $scope -j DNAT --to-destination :$port
sed -i "/^exit 0/i\iptables -t nat -A PREROUTING -i $eth -p udp --dport $scope -j DNAT --to-destination :$port" /etc/rc.local
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

$xx

$masquerade

EOF

