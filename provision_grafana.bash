#!/bin/bash

mkdir -p /opt/grafana
cd /opt/grafana

git clone https://github.com/strima/grafana-authentication-proxy.git
wget http://grafanarel.s3.amazonaws.com/grafana-1.8.1.tar.gz


