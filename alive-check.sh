[200~#!/usr/bin/env bash
set +e # must set to +e, otherwiser the command exit when error
set -x
cluster=sandbox
# specify influxdb hosts and cmd
declare -A influxdb_ping
#influxdb_ping[mainnet]="http://35.208.192.135:8087/ping"
#influxdb_ping[testnet]="http://35.206.91.25:8086/ping"
#influxdb_ping[devnet]="http://35.208.238.138:8089/ping"
influxdb_ping[sandbox]="http://127.0.0.1:8086/ping"

# specify kapacitor hosts and cmd
declare -A kapacitor_ping
#kapacitor_ping[mainnet]="http://34.80.3.230:9092/kapacitor/v1/ping"
#kapacitor_ping[testnet]="http://34.80.3.230:9092/kapacitor/v1/ping"
#kapacitor_ping[devnet]="http://34.80.3.230:9092/kapacitor/v1/ping"
kapacitor_ping[sandbox]="http://127.0.0.1:8086/kapacitor/v1/ping"

alive_influxdb() {
    for retry in 0 1 2
	do
        echo retry=$retry
		if [[ $retry -gt 0 ]];then
			sleep 5
		fi

		influxdb_status=$(curl -o /dev/null -s -w "%{http_code}\n" --connect-timeout 10  $ping_cmd)
		echo "exist curl"
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

echo "$cluster alive is $alive_influxdb"

ping_cmd=${influxdb_ping[$cluster]}
alive_influxdb