**直接使用**
```
bash <(curl -Ls https://raw.githubusercontent.com/yoier/hysteria2-script/main/fastconfig.sh)
```

客户端配置:
```
{
  "tls": {
    "insecure": false,
    "sni": "$domain"
  },
  "transport": {
    "udp": {
      "hopInterval": "180s"//端口跳跃间隔
    },
    "type": "udp"
  },
  "lazy": true,
  "fast_open": false,
  "socks5": {
    "disableUDP": false,
    "listen": "0.0.0.0:1234"
  },
  "auth": "$password",
  "quic": {
    "initConnReceiveWindow": 67108864,
    "disablePathMTUDiscovery": false,
    "initStreamReceiveWindow": 26843545
  },//$quic
  "server": "$ip:$port,$scope"//scope将中间的':'改为'-'
}
```

