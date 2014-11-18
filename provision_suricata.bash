#!/bin/bash

echo "installing pre'ps ..."
sudo apt-get -y -qq install git
sudo apt-get -y -qq install libtool autoconf pkg-config libpcre3-dev libyaml-dev
sudo apt-get -y -qq install zlib1g-dev
sudo apt-get -y -qq install libpcap-dev
sudo apt-get -y -qq install libnet-dev
sudo apt-get -y -qq install libmagic-dev
sudo apt-get -y -qq install libjansson-dev
sudo apt-get -y -qq install python-setuptools


echo "building suricata ..."
cd /tmp

#luajit
wget http://luajit.org/download/LuaJIT-2.0.3.tar.gz
tar -xzf LuaJIT-2.0.3.tar.gz 
cd LuaJIT-2.0.3/
make
sudo make install
sudo ldconfig
cd ..
rm -rf LuaJIT-2.0.3 

# libhtp
git clone https://github.com/ironbee/libhtp.git -b 0.5.x
cd libhtp
./autogen.sh
./configure
make
sudo make install
sudo ldconfig
cd ..
rm -rf libhtp

#suricata
git clone git://phalanx.openinfosecfoundation.org/oisf.git
cd oisf
./autogen.sh
./configure --enable-luajit --enable-non-bundled-htp --disable-shared --enable-static --prefix=/opt/suricata
make
sudo make install-full
(cd /tmp/oisf/scripts/suricatasc; python setup.py install)
/opt/suricata/bin/suricata -T --disable-detection
/opt/suricata/bin/suricata --list-app-layer-protos 
/opt/suricata/bin/suricata --build-info
(cd /etc/init/; wget -q https://raw.githubusercontent.com/hillar/vagrant_suricata_influxdb_grafana/master/suricata.conf)
status suricata
start suricata
sleep 1
status suricata

cd ..
#rm -rf oisf


# reading suricata socket with python

mkdir /opt/suristats2influxdb
cd /opt/suristats2influxdb
git clone https://github.com/influxdb/influxdb-python.git
cd influxdb-python
python setup.py install
cd ..
echo "creating database ..."
curl -s -XPOST 'http://192.168.33.111:8086/db?u=root&p=root' -d '{"name": "suricata-stats"}'
curl -s -XPOST 'http://192.168.33.111:8086/db?u=root&p=root' -d '{"name": "grafana"}'
curl -s 'http://192.168.33.111:8086/db?u=root&p=root'

wget -q https://raw.githubusercontent.com/hillar/vagrant_suricata_influxdb_grafana/master/suri-influxdb.py

python /opt/suristats2influxdb/suri-influxdb.py /opt/suricata/var/run/suricata/suricata-command.socket --db=suricata-stats -H 192.168.33.111 -P 8086 &

