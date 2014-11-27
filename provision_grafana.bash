#!/bin/bash

GRAFANA_VERSION=1.9.0-rc1


apt-get -y -qq install git golang-go mercurial

echo "getting grafana-$GRAFANA_VERSION ..."
cd /tmp
wget -q http://grafanarel.s3.amazonaws.com/grafana-$GRAFANA_VERSION.tar.gz
tar -xzf grafana-$GRAFANA_VERSION.tar.gz
mkdir -p /opt/grafana/www/
mv grafana-$GRAFANA_VERSION /opt/grafana/www/
(cd /opt/grafana/www/grafana-$GRAFANA_VERSION; wget -q https://raw.githubusercontent.com/hillar/vagrant_suricata_influxdb_grafana/master/config.js.grafana;  mv config.js.grafana config.js)
#
(cd /opt/grafana/www/grafana-$GRAFANA_VERSION/app/dashboards; wget -q https://raw.githubusercontent.com/hillar/vagrant_suricata_influxdb_grafana/master/default.json.grafana;  mv default.json.grafana default.json)


echo "getting  & building grafana proxy ..."
export GOPATH=/tmp/go
CGO_ENABLED=0 go get -a -ldflags '-s' github.com/artyom/grafanaweb
mkdir -p /opt/grafana/bin
cp /tmp/go/bin/grafanaweb /opt/grafana/bin/grafanaweb
/opt/grafana/bin/grafanaweb --help
ldd /opt/grafana/bin/grafanaweb

# see https://github.com/Dieterbe/influx-cli/issues/9
#echo "getting and building influxdb-cli ... "
#cd /tmp
#CGO_ENABLED=0 go get -a -ldflags '-s' github.com/Dieterbe/influx-cli
#mkdir -p /opt/influxdb/bin
#cp /tmp/go/bin/influx-cli /opt/influxdb/bin/

echo "getting  & building metrix ..."
CGO_ENABLED=0 go get -a -ldflags '-s' github.com/hillar/metrix
mkdir -p /opt/metrix/bin
cp /tmp/go/bin/metrix /opt/metrix/bin/metrix
echo "run metrix with:"
echo "/opt/metrix/bin/metrix --influxdb root:root@192.168.33.111:8086/metrics --cpu --free --df --files --loadavg --memory --net --processes --suricata /opt/suricata/var/run/suricata/suricata-command.socket"

curl -s -XPOST 'http://192.168.33.111:8086/db?u=root&p=root' -d '{"name": "metrics"}'
/opt/metrix/bin/metrix --influxdb root:root@192.168.33.111:8086/metrics --cpu --free --df --files --loadavg --memory --net --processes

echo "run grafana web proxy with:"
echo "/opt/grafana/bin/grafanaweb -listen="192.168.33.112:3003" -proxy="http://192.168.33.111:8086" -root=/opt/grafana/www/grafana-$GRAFANA_VERSION"

/opt/grafana/bin/grafanaweb -listen="192.168.33.112:3003" -proxy="http://192.168.33.111:8086" -root=/opt/grafana/www/grafana-$GRAFANA_VERSION &


