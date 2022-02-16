#!/usr/bin/env bash
set -ex 

influxdata_data=/home/sol/influxdata
influxdata_config=/home/sol/influxdata-config
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