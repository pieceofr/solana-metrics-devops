#!/usr/bin/env bash
# influxdb
declare -A influxdb_name
#influxdb_name[mainnet]=influxdb-mainnet
influxdb_name[testnet]=influxdb-testnet
#influxdb_name[devnet]=influxdb-devnet
influxdb_name[sandbox]=influxdb-sandbox

declare -A influxdb_portmap
#influxdb_portmap[mainnet]=8087:8086
influxdb_portmap[testnet]=8085:8086
#influxdb_portmap[devnet]=8089:8086
influxdb_portmap[sandbox]=8086:8086

declare -A influxdb_config
influxdb_config[testnet]=/root/metrics-config/influxdb-testnet.conf:/etc/influxdb/influxdb.conf
influxdb_config[sandbox]=/root/metrics-config/influxdb-sandbox.conf:/etc/influxdb/influxdb.conf

declare -A influxdb_data
influxdb_data[testnet]=/root/metrics-data/influxdb-testnet:/var/lib/influxdb
influxdb_data[sandbox]=/root/metrics-data/influxdb-sandbox:/var/lib/influxdb

# kapacitor
declare -A kapacitor_name
#kapacitor_name[mainnet]=kapacitor-mainnet
kapacitor_name[testnet]=kapacitor-testnet
#kapacitor_name[devnet]=kapacitor-devnet
kapacitor_name[sandbox]=kapacitor-sandbox

declare -A kapacitor_portmap
kapacitor_portmap[testnet]=9092:9092
kapacitor_portmap[sandbox]=9092:9092

declare -A kapacitor_config
kapacitor_config[testnet]=/root/metrics-config/kapacitor-testnet.conf:/etc/kapacitor/kapacitor.conf
kapacitor_config[sandbox]=/root/metrics-config/kapacitor-sandbox.conf:/etc/kapacitor/kapacitor.conf

declare -A kapacitor_data
kapacitor_data[testnet]=/home/sol/metrics-data/kapacitor-testnet:/var/lib/kapacitor
kapacitor_data[sandbox]=/home/sol/metrics-data/kapacitor-sandbox:/var/lib/kapacitor

## chronograf Config
declare -A chronograf_name
chronograf_name[sandbox]=chronograf-sandbox

declare -A chronograf_portmap
chronograf_portmap[sandbox]=8888:8888

declare -A chronograf_config
chronograf_config[sandbox]=/root/metrics-config/chronograf-sandbox.conf:/etc/chronograf/chronograf.conf

declare -A chronograf_data
chronograf_data[sandbox]=/home/sol/metrics-data/chronograf-sandbox:/var/lib/chronograf

declare -A chronograf_influx_url
chronograf_influx_url[sandbox]=http://127.0.0.1:8086

declare -A chronograf_env_public_url
chronograf_env_public_url[sandbox]=http://127.0.0.1:8888
