#!/usr/bin/env bash
# start influxdb container
# start container functions. below info must provided
## influxdb_portmap=influxdb_volume_portmap[devnet]
## influxdb_config=influxdb_volume_config[devnet]
## influxdb_data=influxdb_volunm_data[devnet]
## kapacitor_portmap=influxdb_volume_data[devnet]
## kapacitor_config=kapacitor_volume_config[devnet]
## kapacitor_data=kapacitor_volume_data[devnet]
set -ex
# specify docker images 
influxdb_version="1.8.1"
kapacitor_version="1.5"
# setup cluster
cluster=sandbox
## container config
declare -A influxdb_volume_name
influxdb_volume_name[devnet]=influxdb-devnet
influxdb_volume_name[sandbox]=influxdb-sandbox

declare -A influxdb_volume_portmap
influxdb_volume_portmap[devnet]=8089:8086
influxdb_volume_portmap[sandbox]=8086:8086

declare -A influxdb_volume_config
influxdb_volume_config[devnet]=/home/sol/influxdata-config/influxdb-devnet.conf:/etc/influxdb/influxdb.conf
influxdb_volume_config[sandbox]=/home/sol/influxdata-config/influxdb-sandbox.conf:/etc/influxdb/influxdb.conf

declare -A influxdb_volume_data
influxdb_volume_data[devnet]=/home/sol/influxdata/influxdb-devnet:/var/lib/influxdb
influxdb_volume_data[sandbox]=/home/sol/influxdata/influxdb-sandbox:/var/lib/influxdb

declare -A kapacitor_volume_name
kapacitor_volume_name[devnet]=kapacitor-devnet
kapacitor_volume_name[sandbox]=kapacitor-sandbox

declare -A kapacitor_volume_portmap
kapacitor_volume_portmap[devnet]=9092:9092
kapacitor_volume_portmap[sandbox]=9092:9092

declare -A kapacitor_volume_config
kapacitor_volume_config[devnet]=/home/sol/influxdata-config/kapacitor-devnet.conf:/etc/kapacitor/kapacitor.conf
kapacitor_volume_config[sandbox]=/home/sol/influxdata-config/kapacitor-sandbox.conf:/etc/kapacitor/kapacitor.conf

declare -A kapacitor_volume_data
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

# start kapacitor
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

influxdb_name=${influxdb_volume_name[$cluster]}         # container Names
influxdb_portmap=${influxdb_volume_portmap[$cluster]}   # container port mapping
influxdb_config=${influxdb_volume_config[$cluster]}     # container config file mounts
influxdb_data=${influxdb_volume_data[$cluster]}         # container data directory mounts
#start-influxdb

kapacitor_name=${kapacitor_volume_name[$cluster]}
kapacitor_portmap=${kapacitor_volume_portmap[$cluster]}
kapacitor_config=${kapacitor_volume_config[$cluster]}
kapacitor_data=${kapacitor_volume_data[$cluster]}
start-kapacitor

