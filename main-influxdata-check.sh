#!/usr/bin/env bash
set +e # must set to +e or not set, otherwiser the command exit when error
set -x

# Setup instruction
## check/setup path of lib-influxdata-container.sh
## setup cluster/hosts/slack
### setup cluster to be used, ie. cluster=devnet
### setup/check host for each clusters
### go to lib-influxdata-container.sh
## setup container
### check/set version to run. ie. influxdb_version="1.8.1" , kapacitor_version="1.5"
### check/set influxdb_name for container name. This name will be used to stop/start container
### check/set port map and mount config file and data directories

source $PWD/lib-influxdata-container.sh
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

declare -A chronograf_ping
chronograf_ping[sandbox]="http://127.0.0.1:8888"

# slack webhook, the webhook is invalid
slack_webhook=""

echo $(date -u) === start script ===

if [[ -z "$slack_webhook"  ]];then
	echo "ERROR : slack_webhook=$slack_webhook"
	exit 1
fi

slack_alert(){
	sdata=$(jq --null-input --arg val "$slacktext" '{"text":$val}')
	curl -X POST -H 'Content-type: application/json' --data "$sdata" $slack_webhook
}

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
		if [[ $alive_status_code == 204 || $alive_status_code == 200 ]];then
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
    alive_name=${influxdb_name[$cluster]} # for alive-check()
    ping_cmd=${influxdb_ping[$cluster]}  # for alive-check()
    alive-check
    if [ $alive_status -eq 0 ];then # influxdb=!alive, restart container
        remove_container_name=${influxdb_name[$cluster]}        # container to be remvoed, used in remove-container() 
        remove-container
        influxdb_docker_name=${influxdb_name[$cluster]}                                                           
        influxdb_docker_portmap=${influxdb_portmap[$cluster]}   # container port mapping
        influxdb_docker_config=${influxdb_config[$cluster]}     # container config file mounts
        influxdb_docker_data=${influxdb_data[$cluster]}         # container data directory mounts
        slacktext="$influxdb_docker_name is restarting!"
        slack_alert
        start-influxdb                                          
    fi
    alive_name=${kapacitor_name[$cluster]}
    ping_cmd=${kapacitor_ping[$cluster]}
    alive-check
    if [ $alive_status -eq 0 ];then # kapacitor=!alive, restart container
        remove_container_name=${kapacitor_name[$cluster]}
        remove-container
        kapacitor_docker_name=${kapacitor_name[$cluster]}
        kapacitor_docker_portmap=${kapacitor_portmap[$cluster]}
        kapacitor_docker_config=${kapacitor_config[$cluster]}
        kapacitor_docker_data=${kapacitor_data[$cluster]}
        slacktext="$kapacitor_docker_name is restarting!"
        slack_alert
        start-kapacitor
    fi
    # alive_name=${chronograf_name[$cluster]}
    # ping_cmd=${chronograf_ping[$cluster]}
    # alive-check
    # if [ $alive_status -eq 0 ];then
    #     remove_container_name=${chronograf_name[$cluster]}
    #     remove-container
    #     chronograf_docker_name=${chronograf_name[$cluster]}
    #     chronograf_docker_portmap=${chronograf_portmap[$cluster]}
    #     chronograf_docker_data=${chronograf_data[$cluster]}
    #     chronograf_docker_public_url=${chronograf_env_public_url[cluster]}
    #     chronograf_docker_influx_url=${chronograf_influx_url[$cluster]}
    #     slacktext="$chronograf_docker_name is restarting!"
    #     slack_alert
    #     start-chronograf
    # fi
}

# main function
check-routine
