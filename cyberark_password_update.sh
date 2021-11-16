#!/bin/bash


echo $(whoami) >> log.txt

auth=$(curl -sb -X POST -H 'Content-Type:application/json' -d '{"jsonrpc": "2.0","method": "user.login","params":{"user": "<Admin>","password": "<password>"},"id": 1}' https://<zabbix_url>/api_jsonrpc.php | /usr/bin/python2 -c "import sys, json; print json.load(sys.stdin)['result']")

while IFS=':' read -r userName macro
do
	
	password=$(curl -XGET 'http://<cyberark_address>/AIMWebService/api/Accounts?AppID=<Application_ID>&Query=Object='"$userName"';Username=<cyberark_user>' | /usr/bin/python2 -c "import sys, json; print json.load(sys.stdin)['Content']")

	globalmacroid=$(curl -sb -X POST -H 'Content-Type:application/json' -d '{"jsonrpc":"2.0","method":"usermacro.get","params":{"filter":{"macro":"'"$macro"'"},"output":"extend","globalmacro":true},"auth":"'"$auth"'","id":1}' https://<zabbix_url>/api_jsonrpc.php | /usr/bin/python2 -c "import sys, json; print json.load(sys.stdin)['result'][0]['globalmacroid']")
	        
	curl -sb -X POST -H 'Content-Type:application/json' -d  '{"jsonrpc":"2.0","method":"usermacro.updateglobal","params":{"globalmacroid":'"$globalmacroid"',"value":"'"$password"'","description":"Update Time : '"$(date)"'"},"auth": "'"$auth"'","id": 1}' https://<zabbix_url>/api_jsonrpc.php


done < /PATH/TO/user.txt


curl -sb -X POST -H 'Content-Type:application/json' -d '{"jsonrpc": "2.0","method": "user.logout","params":[],"id": 1,"auth":"'"$auth"'"}' https://<zabbix_url>/api_jsonrpc.php

echo "worked" >> log.txt
