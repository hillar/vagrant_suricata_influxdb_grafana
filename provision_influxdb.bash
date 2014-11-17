#!/bin/bash
echo "downloading s3.amazonaws.com/influxdb/influxdb_latest_amd64.deb"
wget -q http://s3.amazonaws.com/influxdb/influxdb_latest_amd64.deb

sudo dpkg -i influxdb_latest_amd64.deb
service influxdb start
date
sleep 5
date
netstat -ln
