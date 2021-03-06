#!/bin/sh

zabbix_path='/data/lnmp/monitor_tools/app/zabbix_agent'

mkdir $zabbix_path/libexec -p

server="59.175.238.8"
username="zabbix"
passwd="19880103"


ftp -n $server <<EOF
prompt off
user $username $passwd
lcd $zabbix_path/libexec
cd /zabbix_youxididai/libexec
get nginx_site_discovery.py
get nginx_total_analyze.py
get nginx_analyze.py
get nginx.py
bye
EOF

cat > $zabbix_path/etc/zabbix_agentd.conf.d/nginx.conf <<EOF
# zabbix LLD scripts about site self
UserParameter=nginx.statistics.200[*],/data/lnmp/Python-2.7.3/python $zabbix_path/libexec/nginx.py \$1 200
UserParameter=nginx.statistics.404[*],/data/lnmp/Python-2.7.3/python $zabbix_path/libexec/nginx.py \$1 404
UserParameter=nginx.requests[*],/data/lnmp/Python-2.7.3/python $zabbix_path/libexec/nginx.py \$1 requests
UserParameter=nginx.traffic[*],/data/lnmp/Python-2.7.3/python $zabbix_path/libexec/nginx.py \$1 traffic
UserParameter=nginx.sites.discovery_python,/data/lnmp/Python-2.7.3/python $zabbix_path/libexec/nginx_site_discovery.py

# zabbix nginx total requests , total status statistics and total traffic
UserParameter=nginx.total.200,/data/lnmp/Python-2.7.3/python $zabbix_path/libexec/nginx_total_analyze.py 200
UserParameter=nginx.total.404,/data/lnmp/Python-2.7.3/python $zabbix_path/libexec/nginx_total_analyze.py 404
UserParameter=nginx.total.traffic,/data/lnmp/Python-2.7.3/python $zabbix_path/libexec/nginx_total_analyze.py traffic
UserParameter=nginx.total.requests,/data/lnmp/Python-2.7.3/python $zabbix_path/libexec/nginx_total_analyze.py requests
EOF

pkill zabbix_agentd
$zabbix_path/sbin/zabbix_agentd 

chmod +x $zabbix_path/libexec/*
chmod o+r /usr/local/app/lnmp/nginx/logs/*