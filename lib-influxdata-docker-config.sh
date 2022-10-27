#!/usr/bin/env bash
# influxdb
declare -A influxdb_name
influxdb_name[mainnet]=influxdb-mainnet
influxdb_name[testnet]=influxdb-testnet
influxdb_name[devnet]=influxdb-devnet
influxdb_name[sandbox]=influxdb-sandbox

declare -A influxdb_portmap
influxdb_portmap[mainnet]=8087:8086
influxdb_portmap[testnet]=8088:8086
influxdb_portmap[devnet]=8089:8086
influxdb_portmap[sandbox]=8086:8086

declare -A influxdb_config
influxdb_data[mainnet]=/var/lib/influxdb-testnet:/var/lib/influxdb
influxdb_data[testnet]=/var/lib/influxdb-testnet:/var/lib/influxdb
influxdb_data[devnet]=/var/lib/influxdb-testnet:/var/lib/influxdb
influxdb_data[sandbox]=/var/lib/influxdb-testnet:/var/lib/influxdb

declare -A influxdb_data
influxdb_data[mainnet]=/var/lib/influxdb-testnet:/var/lib/influxd
influxdb_data[testnet]=/var/lib/influxdb-testnet:/var/lib/influxd
influxdb_data[devnet]=/var/lib/influxdb-testnet:/var/lib/influxd
influxdb_data[sandbox]=/var/lib/influxdb-testnet:/var/lib/influxd

# kapacitor
declare -A kapacitor_name
kapacitor_name[mainnet]=kapacitor-mainnet
kapacitor_name[testnet]=kapacitor-testnet
kapacitor_name[devnet]=kapacitor-devnet
kapacitor_name[sandbox]=kapacitor-sandbox

declare -A kapacitor_portmap
kapacitor_portmap[testnet]=9092:9092
kapacitor_portmap[sandbox]=9092:9092

declare -A kapacitor_config
kapacitor_config[mainnet]=/root/metrics-config/kapacitor-mainnet.conf:/etc/kapacitor/kapacitor.conf
kapacitor_config[testnet]=/root/metrics-config/kapacitor-testnet.conf:/etc/kapacitor/kapacitor.conf
kapacitor_config[devnet]=/root/metrics-config/kapacitor-devnet.conf:/etc/kapacitor/kapacitor.conf
kapacitor_config[sandbox]=/root/metrics-config/kapacitor-sandbox.conf:/etc/kapacitor/kapacitor.conf

declare -A kapacitor_data
kapacitor_data[mainnet]=/var/lib/kapacitor:/var/lib/kapacitor
kapacitor_data[testnet]=/var/lib/kapacitor:/var/lib/kapacitor
kapacitor_data[devnet]=/var/lib/kapacitor:/var/lib/kapacitor
kapacitor_data[sandbox]=/var/lib/kapacitor:/var/lib/kapacitor

## chronograf Config
declare -A chronograf_name
chronograf_name[sandbox]=chronograf-sandbox

declare -A chronograf_portmap
chronograf_portmap[sandbox]=8888:8888

declare -A chronograf_config
chronograf_config[sandbox]=/root/metrics-config/chronograf-sandbox.conf:/etc/chronograf/chronograf.conf

declare -A chronograf_data
chronograf_data[sandbox]=/root/metrics-data/chronograf-sandbox:/var/lib/chronograf

declare -A chronograf_influx_url
chronograf_influx_url[sandbox]=http://127.0.0.1:8086

declare -A chronograf_env_public_url
chronograf_env_public_url[sandbox]=http://127.0.0.1:8888
