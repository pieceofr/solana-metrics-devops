#!/usr/bin/env bash
set +e # must set to +e, otherwiser the command exit when error
#set -x
cluster=sandbox
# specify influxdb hosts and cmd
declare -A influxdb_ping
influxdb_ping[mainnet]="http://127.0.0.1:8087/ping"
influxdb_ping[testnet]="http://127.0.0.1:8088/ping"
influxdb_ping[devnet]="http://127.0.0.1:8089/ping"
influxdb_ping[sandbox]="http://127.0.0.1:8086/ping"

# specify kapacitor hosts and cmd
declare -A kapacitor_ping
kapacitor_ping[mainnet]="http://127.0.0.1:9092/kapacitor/v1/ping"
kapacitor_ping[testnet]="http://127.0.0.1:9092/kapacitor/v1/ping"
kapacitor_ping[devnet]="http://127.0.0.1:9092/kapacitor/v1/ping"
kapacitor_ping[sandbox]="http://127.0.0.1:9092/kapacitor/v1/ping"

declare -A chronograf_ping
chronograf_ping[sandbox]="http://127.0.0.1:8888"

alive_check() {
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

alive_name="influxdb"
ping_cmd=${influxdb_ping[$cluster]}
alive_check
alive_name="kapacitor"
ping_cmd=${kapacitor_ping[$cluster]}
alive_check
# alive_name="chronograf"
# ping_cmd=${chronograf_ping[$cluster]}
# alive_check

