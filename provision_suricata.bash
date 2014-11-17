#!/bin/bash

sudo apt-get -y -qq install git
sudo apt-get -y -qq install libtool autoconf pkg-config libpcre3-dev libyaml-dev
sudo apt-get -y -qq install zlib1g-dev
sudo apt-get -y -qq install libpcap-dev
sudo apt-get -y -qq install libnet-dev
sudo apt-get -y -qq install libmagic-dev
sudo apt-get -y -qq install libjansson-dev

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
sudo suricata -T --disable-detection
sudo suricata --list-app-layer-protos 

cd ..
#rm -rf oisf


# reading suricata socket with python
sudo apt-get -y -qq install python-setuptools
mkdir /opt/suristats2influxdb
cd /opt/suristats2influxdb
git clone https://github.com/influxdb/influxdb-python.git
cd influxdb-python
python setup.py install


curl -s -XPOST 'http://192.168.33.111:8086/db?u=root&p=root' -d '{"name": "suricata-stats"}'
curl -s 'http://192.168.33.111:8086/db?u=root&p=root'


