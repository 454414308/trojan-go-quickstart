#!/bin/sh

echo "Getting the latest version of trojan-go"
latest_version="$(curl -s "https://api.github.com/repos/p4gefau1t/trojan-go/releases" | jq -r '.[0].tag_name' --raw-output)"
echo "${latest_version}"
trojango_link="https://github.com/p4gefau1t/trojan-go/releases/download/${latest_version}/trojan-go-linux-amd64.zip"

cd `mktemp -d`
wget -nv "${trojango_link}" -O trojan-go.zip
unzip -q trojan-go.zip && rm -rf trojan-go.zip

mkdir -p "/usr/local/etc/trojan-go"
mv trojan-go /usr/local/bin/trojan-go
mv geoip.dat /usr/local/etc/trojan-go/geoip.dat
mv geosite.dat /usr/local/etc/trojan-go/geosite.dat
mv example/trojan-go.service /etc/systemd/system/trojan-go.service
mv example/server.json /usr/local/etc/trojan-go/config.json
chmod -R 644 /usr/local/etc/trojan-go/config.json

cat > "/etc/systemd/system/trojan-go.service" << EOF
[Unit]
Description=trojan-go
After=network.target network-online.target nss-lookup.target mysql.service mariadb.service mysqld.service

[Service]
Type=simple
StandardError=journal
ExecStart="/usr/local/bin/trojan-go" "/usr/local/etc/trojan-go/config.json"
ExecReload=/bin/kill -HUP $MAINPID
LimitNOFILE=51200
Restart=on-failure
RestartSec=1s

[Install]
WantedBy=multi-user.target
EOF



systemctl daemon-reload
systemctl reset-failed

echo "trojan-go is installed."