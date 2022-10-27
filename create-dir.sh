#!/usr/bin/env bash
set -ex 
## File structure
## config file : all config is in the same dir
## data : each cluster and application data are in their folder
## ie : /root/influxdata/influxdb-testnet/
## if the directory is the symbolic link, the docker may not work for it

influxdata_data=/root/influxdata
influxdata_config=/root/influxdata-config
influxdb_dir=("influxdb-devnet" "influxdb-testnet" "influxdb-mainnet")
kapacitor_dir=("kapacitor-devnet" "kapacitor-testnet" "kapacitor-mainnet")

if [[ ! -d "$influxdata_data" ]];then
    mkdir "$influxdata_data"
fi

if [[ ! -d "$influxdata_config" ]];then
    mkdir "$influxdata_config"
fi

for((i=0; i<${#influxdb_dir[@]}; i++))
do
    dir=$influxdata_data/${influxdb_dir[i]}
    echo $dir
    if [[ ! -d $dir ]];then
        mkdir $dir
    fi
done
for((i=0; i<${#kapacitor_dir[@]}; i++))
do
    dir=$influxdata_data/${kapacitor_dir[i]}
    echo $dir
    if [[ ! -d $dir ]];then
        mkdir $dir
    fi
done