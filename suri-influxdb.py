# see https://github.com/inliniac/suricata/blob/master/contrib/suri-graphite
from influxdb import InfluxDBClient
import suricatasc
import socket
import sys
import os
import time
import argparse
import json

parser = argparse.ArgumentParser(prog='suri-influxdb', description='Export suricata stats to InfluxDB')
parser.add_argument('-H', '--host', default='localhost', help='Host running InfluxDB')
parser.add_argument('-P', '--port', default=2003, help='Port of InfluxDB data socket')
parser.add_argument('-O', '--oneshot', action='store_const', const=True, help='Send one update and exit', default=False)
parser.add_argument('-D', '--delay', default=10, help='Delay between data dump')
parser.add_argument('-d', '--db', default='suricata', help='Database name in InfluxDB')
parser.add_argument('socket', help='suricata socket file to connect to',
                    default="/var/run/suricata/suricata-command.socket", nargs='?')
parser.add_argument('-v', '--verbose', action='store_const', const=True, help='verbose output', default=False)

args = parser.parse_args()
sc = suricatasc.SuricataSC(args.socket)
try:
    sc.connect()
except:
    error = sys.exc_info()[0]
    print "connection init error :: %r %s" % (error,args.socket)
    if args.oneshot:
        sys.exit(1)

#todo ...
USER = 'root'
PASSWORD = 'root'

client = InfluxDBClient(args.host, args.port, USER, PASSWORD, args.db)
#todo, create db if not exist
#dbs = client.get_database_list()
#print dbs
_,hostname,_,_,_ = os.uname()

while 1:
    try:
        res = sc.send_command("dump-counters")
    except:
        error = sys.exc_info()[0]
        print "connection error :: %r %s" % (error,args.socket)
        time.sleep(float(args.delay))
        try:
            sc.connect()
        except:
            error = sys.exc_info()[0]
            print "connection init error :: %r %s" % (error,args.socket)
    else:        
        if res['return'] == 'NOK':
            print res['message']
        else:
            res = res['message']
            tnow = int(time.time())
            points = []
            for thread in res:
                for counter in res[thread]:
                    if res[thread][counter] != 0:
                        point = {'name': counter, 'columns': ["time", "value", "hostname","thread"], 'points':  [[tnow, res[thread][counter], hostname, thread]]}
                        points.append(point)
                    if args.verbose:
                        print "%s.%s.%s %s %d\n" % (args.db, thread , counter, res[thread][counter], tnow)
            try:
                client.write_points(points)
            except:
                #print str(json.dumps(points))
                # ? queue points ..
                error = sys.exc_info()
                print "points write error :: %r %s:%s/%s" % (error, args.host, args.port, args.db)
            else:
                error = False
    if args.oneshot:
        break
    time.sleep(float(args.delay))