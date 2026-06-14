curl -L -O https://github.com/pymumu/smartdns/releases/download/Release48.1/smartdns.1.2026.06.07-1153.x86_64-debian-all.deb
dpkg -i smartdns*.deb
cat << EOF > /etc/smartdns/smartdns.conf
bind-tcp 127.0.0.1:53
cache-size 4096
cache-persist no
prefetch-domain yes
force-qtype-SOA 28 65
rr-ttl-min 300
speed-check-mode ping,tcp:443,tcp:80
response-mode first-ping
server-tls 1.1.1.1:853
server-tls 1.0.0.1:853
server-tls 8.8.8.8:853
max-reply-ip-num 3
log-level info
EOF
systemctl enable smartdns
systemctl start smartdns
LOG "SmartDNS installed and started"