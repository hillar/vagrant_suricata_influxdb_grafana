#!/bin/bash

wget http://s3.amazonaws.com/influxdb/influxdb_latest_amd64.deb
sudo dpkg -i influxdb_latest_amd64.deb
service influxdb start
sleep 1
curl -X POST 'http://localhost:8086/db?u=root&p=root' -d '{"name": "provision_test"}'
curl 'http://localhost:8086/db?u=root&p=root'
curl -X DELETE 'http://localhost:8086/db/provision_test?u=root&p=root'
curl 'http://localhost:8086/db?u=root&p=root'
