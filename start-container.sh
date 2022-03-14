#!/usr/bin/env bash
# start influxdb container
# start container functions. below info must provided
## influxdb_portmap=influxdb_portmap[devnet]
## influxdb_config=influxdb_config[devnet]
## influxdb_data=influxdb_volunm_data[devnet]
## kapacitor_portmap=influxdb_data[devnet]
## kapacitor_config=kapacitor_config[devnet]
## kapacitor_data=kapacitor_data[devnet]
set -ex
# specify docker images 
influxdb_docker_version="1.7"
kapacitor_docker_version="1.5"
chronograf_docker_version="1.8.8"
grafana_version="8.3.1"

# setup cluster
cluster=sandbox
source /home/sol/metrics-devops/lib-influxdata-docker-config.sh

## Graphana Config
declare -A grafana_volume_name
grafana_volume_name[internal]=grafana

declare -A grafana_volume_config8
grafana_volume_config[internal]=/home/sol/metrics-config/grafana-internal.ini:/grafana.ini:ro

declare -A grafana_volume_data
grafana_volume_data_env[internal]=/home/sol/grafana_data:/var/lib/grafana

declare -A grafana_volume_cert
grafana_volume_cert[internal]=/home/sol/certs:/certs:ro


start-influxdb(){
  start_if_result=$(docker run \
    --detach \
    --name=$influxdb_docker_name \
    --publish $influxdb_docker_portmap \
    --volume $influxdb_docker_config \
    --volume $influxdb_docker_data \
    --log-opt max-size=1g \
    --log-opt max-file=5 \
    influxdb:$influxdb_docker_version -config /etc/influxdb/influxdb.conf)

  echo start_influx_result:$start_if_result
}

# start kapacitor
start-kapacitor(){
  start_k_result=$(docker run \
      --detach \
      --name=$kapacitor_docker_name \
      --publish $kapacitor_docker_portmap \
      --volume $kapacitor_docker_config \
      --volume $kapacitor_docker_data \
      --log-opt max-size=1g \
      --log-opt max-file=5  \
      kapacitor:$kapacitor_docker_version)

  echo $start_k_result
}



# start Graphan

start-grafana() {
  start_g_result= $(docker run \
    --detach \
    --name=grafana \
    --publish $grafana_portmap \
    --volume $grafana_certs \
    --volume $grafana_config \
    --volume $grafana_data \
    --env GF_PATHS_CONFIG=/grafana.ini \
    --log-opt max-size=1g \
    --log-opt max-file=5 \
    grafana:$grafana_version)
}


start-chronograf() {
  start_ch_result=$(docker run \
  --detach \
  --env PUBLIC_URL=$chronograf_docker_public_url\
  --name=$chronograf_docker_name \
  --publish $chronograf_docker_portmap \
  --volume $chronograf_docker_data \
  --log-opt max-size=1g \
  --log-opt max-file=5 \
  chronograf:$chronograf_docker_version --influxdb-url=$chronograf_influx_url)
}



influxdb_docker_name=${influxdb_name[$cluster]}         # container Names
influxdb_docker_portmap=${influxdb_portmap[$cluster]}   # container port mapping
influxdb_docker_config=${influxdb_config[$cluster]}     # container config file mounts
influxdb_docker_data=${influxdb_data[$cluster]}         # container data directory mounts
start-influxdb

kapacitor_docker_name=${kapacitor_name[$cluster]}
kapacitor_docker_portmap=${kapacitor_portmap[$cluster]}
kapacitor_docker_config=${kapacitor_config[$cluster]}
kapacitor_docker_data=${kapacitor_data[$cluster]}
start-kapacitor

grafana_name=${grafana_volume_name[$cluster]}
grafana_portmap=${grafana_volume_portmap[$cluster]}
grafana_config=${grafana_volume_config[$cluster]}
grafana_data=${grafana_volume_data[$cluster]}
grafana_certs=${grafana_volume_cert[$cluster]}
#start-grafana

chronograf_docker_name=${chronograf_name[$cluster]}
chronograf_docker_portmap=${chronograf_portmap[$cluster]}
chronograf_docker_data=${chronograf_data[$cluster]}
chronograf_docker_public_url=${chronograf_env_public_url[cluster]}
chronograf_docker_influx_url=${chronograf_influx_url[$cluster]}
start-chronograf