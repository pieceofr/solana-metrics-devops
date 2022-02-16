#!/usr/bin/env bash

# start container functions. below info must provided
## influxdb_portmap=influxdb_volume_portmap[devnet]
## influxdb_config=influxdb_volume_config[devnet]
## influxdb_data=influxdb_volunm_data[devnet]
## kapacitor_portmap=influxdb_volume_data[devnet]
## kapacitor_config=kapacitor_volume_config[devnet]
## kapacitor_data=kapacitor_volume_data[devnet]
set +e
set -x
# specify docker images 
influxdb_version="1.8.1"
kapacitor_version="1.5"

declare -A influxdb_volume_name
influxdb_volume_name[mainnet]=influxdb-mainnet
influxdb_volume_name[testnet]=influxdb-testnet
influxdb_volume_name[devnet]=influxdb-devnet
influxdb_volume_name[sandbox]=influxdb-sandbox

declare -A influxdb_volume_portmap
influxdb_volume_portmap[mainnet]=8087:8086
influxdb_volume_portmap[testnet]=8088:8086
influxdb_volume_portmap[devnet]=8089:8086
influxdb_volume_portmap[sandbox]=8086:8086

declare -A influxdb_volume_config
influxdb_volume_config[mainnet]=/home/sol/influxdata-config/influxdb-mainnet.conf:/etc/influxdb/influxdb.conf
influxdb_volume_config[testnet]=/home/sol/influxdata-config/influxdb-testnet.conf:/etc/influxdb/influxdb.conf
influxdb_volume_config[devnet]=/home/sol/influxdata-config/influxdb-devnet.conf:/etc/influxdb/influxdb.conf
influxdb_volume_config[sandbox]=/home/sol/influxdata-config/influxdb-sandbox.conf:/etc/influxdb/influxdb.conf

declare -A influxdb_volume_data
influxdb_volume_data[mainnet]=/home/sol/influxdata/influxdb-mainnet:/var/lib/influxdb
influxdb_volume_data[testnet]=/home/sol/influxdata/influxdb-testnet:/var/lib/influxdb
influxdb_volume_data[devnet]=/home/sol/influxdata/influxdb-devnet:/var/lib/influxdb
influxdb_volume_data[sandbox]=/home/sol/influxdata/influxdb-sandbox:/var/lib/influxdb

declare -A kapacitor_volume_name
kapacitor_volume_name[mainnet]=kapacitor-mainnet
kapacitor_volume_name[testnet]=kapacitor-testnet
kapacitor_volume_name[devnet]=kapacitor-devnet
kapacitor_volume_name[sandbox]=kapacitor-sandbox

declare -A kapacitor_volume_portmap
kapacitor_volume_portmap[mainnet]=9092:9092
kapacitor_volume_portmap[testnet]=9092:9092
kapacitor_volume_portmap[devnet]=9092:9092
kapacitor_volume_portmap[sandbox]=9092:9092

declare -A kapacitor_volume_config
kapacitor_volume_config[mainnet]=/home/sol/influxdata-config/kapacitor-mainnet.conf:/etc/kapacitor/kapacitor.conf
kapacitor_volume_config[testnet]=/home/sol/influxdata-config/kapacitor-testnet.conf:/etc/kapacitor/kapacitor.conf
kapacitor_volume_config[devnet]=/home/sol/influxdata-config/kapacitor-devnet.conf:/etc/kapacitor/kapacitor.conf
kapacitor_volume_config[sandbox]=/home/sol/influxdata-config/kapacitor-sandbox.conf:/etc/kapacitor/kapacitor.conf

declare -A kapacitor_volume_data
kapacitor_volume_data[mainnet]=/home/sol/influxdata/kapacitor-mainnet:/var/lib/kapacitor
kapacitor_volume_data[testnet]=/home/sol/influxdata/kapacitor-testnet:/var/lib/kapacitor
kapacitor_volume_data[devnet]=/home/sol/influxdata/kapacitor-devnet:/var/lib/kapacitor
kapacitor_volume_data[sandbox]=/home/sol/influxdata/kapacitor-sandbox:/var/lib/kapacitor

start-influxdb(){
  start_if_result=$(docker run \
    --detach \
    --name=$influxdb_name \
    --publish $influxdb_portmap \
    --volume $influxdb_config \
    --volume $influxdb_data \
    --log-opt max-size=1g \
    --log-opt max-file=5 \
    influxdb:$influxdb_version -config /etc/influxdb/influxdb.conf)
  echo start_influx_result:$start_if_result
}

start-kapacitor(){
  start_k_result=$(docker run \
      --detach \
      --name=$kapacitor_name \
      --publish $kapacitor_portmap \
      --volume $kapacitor_config \
      --volume $kapacitor_data \
      --log-opt max-size=1g \
      --log-opt max-file=5  \
      kapacitor:$kapacitor_version)
  echo $start_k_result
}

# remove container: provide container_name to be killed & remove
## container_name=influxdb-devnet
remove-container() {
  running=$(docker ps --filter "name=$container_name" --format "{{.Names}}")
  if [[ ! ${#running} -eq 0 ]];then
    kill_result=$(docker kill $container_name)
    echo kill container: $kill_result
  fi
  dead=$(docker ps -a --filter "name=$container_name" --format "{{.Names}}")
  if [[ ! ${#dead} -eq 0 ]];then
    rm_result=$(docker rm $container_name)
    echo remove container: $rm_result
  fi
}