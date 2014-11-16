#!/bin/bash
echo "downloading s3.amazonaws.com/influxdb/influxdb_latest_amd64.deb"
wget -q http://s3.amazonaws.com/influxdb/influxdb_latest_amd64.deb

sudo dpkg -i influxdb_latest_amd64.deb
service influxdb start
date
sleep 5
date
netstat -ln
#curl -s -XPOST 'http://localhost:8086/db?u=root&p=root' -d '{"name": "provision_test"}'
#curl -s 'http://localhost:8086/db?u=root&p=root'
#curl -s -X DELETE 'http://localhost:8086/db/provision_test?u=root&p=root'
#curl -s 'http://localhost:8086/db?u=root&p=root'
