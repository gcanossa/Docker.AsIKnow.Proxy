#!/bin/bash

declare -a ARR_PORTS
ARR_PORTS_COUNT=0

declare -a ARR_HOSTS
ARR_HOSTS_COUNT=0

declare -a ARR_PATHS
ARR_PATHS_COUNT=0

if [ -z $CFG_LISTEN ]; then
	CFG_LISTEN=9000
fi

if [ -z $CFG_PORTS ]; then
	echo "CFG_PORTS not set";
	exit 1
else
	for i in $(echo $CFG_PORTS | tr ',' '\n'); do
		ARR_PORTS[$ARR_PORTS_COUNT]=$i
		ARR_PORTS_COUNT=$(( $ARR_PORTS_COUNT + 1 ))
	done
	#echo ${ARR_PORTS[*]}
fi

if [ -z $CFG_HOSTS ]; then
	echo "CFG_HOSTS not set";
	exit 1
else
	for i in $(echo $CFG_HOSTS | tr ',' '\n'); do
		ARR_HOSTS[$ARR_HOSTS_COUNT]=$i
		ARR_HOSTS_COUNT=$(( $ARR_HOSTS_COUNT + 1 ))
	done
	#echo ${ARR_HOSTS[*]}
fi

if [ -z $CFG_PATHS ]; then
	echo "CFG_PATHS not set";
	exit 1
else
	for i in $(echo $CFG_PATHS | tr ',' '\n'); do
		ARR_PATHS[$ARR_PATHS_COUNT]=$i
		ARR_PATHS_COUNT=$(( $ARR_PATHS_COUNT + 1 ))
	done
	#echo ${!ARR_PATHS[@]}
fi

if [[ $ARR_PORTS_COUNT != $ARR_HOSTS_COUNT || $ARR_PORTS_COUNT != $ARR_PATHS_COUNT || $ARR_PORTS_COUNT = 0 ]] 
then
	echo "Ports, paths, apis and hosts must be the same number and at least 1"
	exit 2
fi


#echo ${ARR_HOSTS[$i]}:${ARR_PORTS[$i]}${ARR_PATHS[$i]}
echo "worker_processes 1;"

echo "events { worker_connections 1024; }"

echo "http {"

echo 	"sendfile on;"

for i in ${!ARR_PATHS[@]};do	
   echo "upstream us_${i}_${ARR_HOSTS[$i]}_${ARR_PORTS[$i]} {"
   echo "server ${ARR_HOSTS[$i]}:${ARR_PORTS[$i]};"
   echo "}"
done

echo "server {"
echo "listen $CFG_LISTEN;"
for prop in `printenv | grep -e "^CFG_SERVER_PROP" | sed -e "s/^CFG_SERVER_PROP_//"`; do
	echo "`echo $prop | cut -f1 -d=` `echo $prop | cut -f2 -d=`;"
done

for i in ${!ARR_PATHS[@]};do		
	if [[ ${ARR_PATHS[$i]} = !* ]]
	then	
		TMP=`echo ${ARR_PATHS[$i]} | cut -c2-`
		echo "location ${TMP} {"
		echo "deny	all;"
		echo "return	404;"
		echo "}"
	elif [[ ${ARR_PATHS[$i]} = *:* ]]
	then
		TMP_O=`echo ${ARR_PATHS[$i]} | cut -d: -f1`
		TMP_I=`echo ${ARR_PATHS[$i]} | cut -d: -f2`
	
		echo "location ${TMP_O} {"
		echo "proxy_pass         http://us_${i}_${ARR_HOSTS[$i]}_${ARR_PORTS[$i]}${TMP_I};"
		echo "proxy_redirect     off;"
		echo -n 'proxy_set_header   Host $host:'
		echo -n $CFG_LISTEN
		echo ';'
		echo 'proxy_set_header   X-Real-IP $remote_addr;'
		echo 'proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;'
		echo 'proxy_set_header   X-Forwarded-Host $server_name;'
		echo 'proxy_set_header   X-Forwarded-Port $server_port;'
		echo 'proxy_set_header   X-Forwarded-Proto $scheme;'
		echo 'sub_filter_once off;'
		echo 'sub_filter_types application/json;'
		echo "sub_filter \"${TMP_I}\" \"${TMP_O}\";"
		echo "}"
	else
		echo "location ${ARR_PATHS[$i]} {"
		echo "proxy_pass         http://us_${i}_${ARR_HOSTS[$i]}_${ARR_PORTS[$i]}/;"
		echo "proxy_redirect     off;"
		echo -n 'proxy_set_header   Host $host:'
		echo -n $CFG_LISTEN
		echo ';'
		echo 'proxy_set_header   X-Real-IP $remote_addr;'
		echo 'proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;'
		echo 'proxy_set_header   X-Forwarded-Host $server_name;'
		echo 'proxy_set_header   X-Forwarded-Port $server_port;'
		echo 'proxy_set_header   X-Forwarded-Proto $scheme;'
		echo "}"
	fi
done

echo  "}"
echo "}"
