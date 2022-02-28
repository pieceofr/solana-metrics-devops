#!/usr/bin/env bash
set +e # must set to +e, otherwiser the command exit when error
set -x

# Setup instruction
## check/setup path of lib-influxdata-container.sh
## setup cluster/hosts/slack
### setup cluster to be used, ie. cluster=devnet
### setup/check host for each clusters
### go to lib-influxdata-container.sh
## setup container
### check/set version to run. ie. influxdb_version="1.8.1" , kapacitor_version="1.5"
### check/set influxdb_volume_name for container name. This name will be used to stop/start container
### check/set port map and mount config file and data directories

source /home/sol/metrics-devops/lib-influxdata-container.sh
#### !!!! setup cluster to use !!!! #####
cluster=sandbox

# specify influxdb hosts and cmd
declare -A influxdb_ping
influxdb_ping[mainnet]="http://127.0.0.1:8086/ping"
influxdb_ping[testnet]="http://127.0.0.1:8086/ping"
influxdb_ping[devnet]="http://127.0.0.1:8086/ping"
influxdb_ping[sandbox]="http://127.0.0.1:8086/ping"


# specify kapacitor hosts and cmd
declare -A kapacitor_ping
kapacitor_ping[mainnet]="http://127.0.0.1:9092/kapacitor/v1/ping"
kapacitor_ping[testnet]="http://127.0.0.1:9092/kapacitor/v1/ping"
kapacitor_ping[devnet]="http://127.0.0.1:9092/kapacitor/v1/ping"
kapacitor_ping[sandbox]="http://127.0.0.1:9092/kapacitor/v1/ping"

# check alive. must specify ping_cmd. ie  ping_cmd=http://localhost:9086/ping .
# it is better to setup alive_name. ie alive_status=influxdb-sandbox
# The function results alive_status=1 or 0
alive-check() {
    for retry in 0 1 2
	do
        echo retry=$retry
		if [[ $retry -gt 0 ]];then
			sleep 5
		fi

		alive_status_code=$(curl -o /dev/null -s -w "%{http_code}\n" --connect-timeout 10 $ping_cmd)
		if [[ $alive_status_code == 204 ]];then
            alive_status=1
            echo $cluster  $alive_name is alive, status:$alive_status_code
            break
		else
            alive_status=0
            echo $cluster $alive_name is NOT alive, status:$alive_status_code
		fi
   
	done
}


# main rountine
check-routine() {
    alive_name=${influxdb_volume_name[$cluster]}
    ping_cmd=${influxdb_ping[$cluster]}
    alive-check
    if [ $alive_status -eq 0 ];then # influxdb=!alive, restart container
        container_name=${influxdb_volume_name[$cluster]}        # container to be remvoed
        remove-container                                                             
        influxdb_name=${influxdb_volume_name[$cluster]}         # container Names
        influxdb_portmap=${influxdb_volume_portmap[$cluster]}   # container port mapping
        influxdb_config=${influxdb_volume_config[$cluster]}     # container config file mounts
        influxdb_data=${influxdb_volume_data[$cluster]}         # container data directory mounts
        slacktext="$influxdb_name is restarting!"
        start-influxdb                                          
    fi
    alive_name=${kapacitor_volume_name[$cluster]}
    ping_cmd=${kapacitor_ping[$cluster]}
    alive-check
    if [ $alive_status -eq 0 ];then # kapacitor=!alive, restart container
        container_name=${kapacitor_volume_name[$cluster]}        # container to be remvoed
        remove-container
        kapacitor_name=${kapacitor_volume_name[$cluster]}
        kapacitor_portmap=${kapacitor_volume_portmap[$cluster]}
        kapacitor_config=${kapacitor_volume_config[$cluster]}
        kapacitor_data=${kapacitor_volume_data[$cluster]}
        slacktext="$kapacitor_name is restarting!"
        start-kapacitor
    fi

}

# main function
check-routine
