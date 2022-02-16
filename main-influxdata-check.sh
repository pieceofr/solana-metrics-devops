#!/usr/bin/env bash
set +e # must set to +e, otherwiser the command exit when error
set -x

# Setup instruction
## setup cluster/hosts/slack
### setup cluster to be used, ie. cluster=devnet
### setup/check host for each clusters
### go to lib-influxdata-container.sh
## setup container
### check/set version to run. ie. influxdb_version="1.8.1" , kapacitor_version="1.5"
### check/set influxdb_volume_name for container name. This name will be used to stop/start container
### check/set port map and mount config file and data directories

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

# slack webhook
slack_webhook="https://hooks.slack.com/services/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"
source /home/sol/scripts/lib-influxdata-container.sh

if [[ -z "$slack_webhook"  ]];then
	echo "ERROR : slack_webhook=$slack_webhook"
	exit 1
fi

slack_alert(){
	sdata=$(jq --null-input --arg val "$slacktext" '{"text":$val}')
	curl -X POST -H 'Content-type: application/json' --data "$sdata" $slack_webhook
}


# check kapacitor alive. must specify ping_cmd. ie  ping_cmd=http://localhost:9086/ping
# The function results alive_influxdb=1 or 0
alive_influxdb() {
    for retry in 0 1 2
	do
        echo retry=$retry
		if [[ $retry -gt 0 ]];then
			sleep 5
		fi

		influxdb_status=$(curl -o /dev/null -s -w "%{http_code}\n" --connect-timeout 10 $ping_cmd)
		if [[ $influxdb_status == 204 ]];then
            alive_influxdb=1
            echo influxdb:$cluster is alive, status:$influxdb_status
            break
		else
            alive_influxdb=0
            echo influxdb:$cluster is NOT alive, status:$influxdb_status
		fi
   
	done
}
# check kapacitor alive. must specify ping_cmd. ie  ping_cmd=http://localhost:9092/kapacitor/v1/ping
# The function results alive_kapacitor=1 or 0
alive_kapacitor() {
    for retry in 0 1 2
	do
        echo retry=$retry
		if [[ $retry -gt 0 ]];then
			sleep 5
		fi
        kapacitor_status=$(curl -o /dev/null -s -w "%{http_code}\n" --connect-timeout 10  $ping_cmd)
        if [[ $kapacitor_status == 204 ]];then
            alive_kapacitor=1
            echo influxdb:$cluster is alive, status:$kapacitor_status
        else
            alive_kapacitor=0
            echo influxdb:$cluster is NOT alive, status:$kapacitor_status
        fi
    done
}


# main rountine
check-routine() {
    ping_cmd=${influxdb_ping[$cluster]}
    alive_influxdb
    if [ $alive_influxdb -eq 0 ];then # influxdb=!alive, restart container
        container_name=${influxdb_volume_name[$cluster]}        # container to be remvoed
        remove-container
                                                                # setup container
        influxdb_name=${influxdb_volume_name[$cluster]}         # container Names
        influxdb_portmap=${influxdb_volume_portmap[$cluster]}   # container port mapping
        influxdb_config=${influxdb_volume_config[$cluster]}     # container config file mounts
        influxdb_data=${influxdb_volume_data[$cluster]}         # container data directory mounts
        slacktext="$influxdb_name is restarting!"
        slack_alert
        start-influxdb                                          
    fi

    ping_cmd=${kapacitor_ping[$cluster]}
    alive_kapacitor
    if [ $alive_kapacitor -eq 0 ];then # kapacitor=!alive, restart container
        container_name=${kapacitor_volume_name[$cluster]}        # container to be remvoed
        remove-container
        kapacitor_name=${kapacitor_volume_name[$cluster]}
        kapacitor_portmap=${kapacitor_volume_portmap[$cluster]}
        kapacitor_config=${kapacitor_volume_config[$cluster]}
        kapacitor_data=${kapacitor_volume_data[$cluster]}
        slacktext="$kapacitor_name is restarting!"
        slack_alert
        start-kapacitor
    fi

}

# main function
check-routine
