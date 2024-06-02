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
    LOGD "检测到的IP:"$ip
    #echo $ethnum
    #echo -e "all_ipaddress:\n"$ip
    use_ip=""
    if [ $ethnum != 1 ];then
            LOG g "输入IP"
            read use_ip
    else
            use_ip=$ip
    fi
}

use_acme() {
    LOG "输入你的域名(确保域名能够解析到本机ip):"
    read acme0
    LOG "输入你的邮箱:"
    read acme1

}

other_conf() {
    LOG "绑定地址:\n\t1.ipv42.\n\tipv6\n\t3.ipv4+ipv6"

    LOG "绑定接口:\n\t1.所有地址\n\t2.选择地址\n\t3.输入地址"

    LOG "输入混淆密码:"

    LOG "输入"
}

cat << EOF > /etc/hysteria/config.yaml
listen: :443

acme:
  domains:
    - hk.yoier.com
  email: 2246test@sharklasers.com

auth:
  type: password
  password: 35774101113

quic:
  initStreamReceiveWindow: 26843545 
  maxStreamReceiveWindow: 26843545 
  initConnReceiveWindow: 67108864 
  maxConnReceiveWindow: 67108864
  maxIdleTimeout: 30s 
  maxIncomingStreams: 1024
  disablePathMTUDiscovery: false
  
masquerade:
  listenHTTP: :80
  listenHTTPS: :443
  forceHTTPS: true
  type: file
  file:
    dir: /var/www/html
EOF

#选择配置方式
menu() {
    get_ip()
    LOG "输入监听地址 (默认: $use_ip:443)"
    read ipport
    LOG "选择配置方式:\n\t1.使用acme\n\t2.使用自签证书"
    read menu0
    case "${menu0}" in
        1)
            ;;
        2)
            ;;
        *)
            ;;
    esac
}

