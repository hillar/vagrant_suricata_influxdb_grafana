#!/bin/bash

apt-get -y -qq install golang-go mercurial

echo "getting grafana-1.8.1 ..."
cd /tmp
wget -q http://grafanarel.s3.amazonaws.com/grafana-1.8.1.tar.gz
tar -xzf grafana-1.8.1.tar.gz
mkdir -p /opt/grafana/www/
mv grafana-1.8.1 /opt/grafana/www/
wget -q https://raw.githubusercontent.com/hillar/vagrant_suricata_influxdb_grafana/master/config.js.grafana
mv config.js.grafana /opt/grafana/www/grafana-1.8.1/config.js


echo "getting  & building grafana proxy ..."
export GOPATH=/tmp/go
CGO_ENABLED=0 go get -a -ldflags '-s' github.com/artyom/grafanaweb
mkdir -p /opt/grafana/bin
cp /tmp/go/bin/grafanaweb /opt/grafana/bin/grafanaweb
/opt/grafana/bin/grafanaweb --help
ldd /opt/grafana/bin/grafanaweb


/opt/grafana/bin/grafanaweb -listen="192.168.33.112:3003" -proxy="http://192.168.33.111:8086" -root=/opt/grafana/www/grafana-1.8.1 &

curl http://192.168.33.112:3003/
