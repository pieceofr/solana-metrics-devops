#!/usr/bin/env bash
source $PWD/lib-influxdata-docker-config.sh
set +e
set -x
# specify docker images 
influxdb_docker_version="1.7"
kapacitor_docker_version="1.5"
chronograf_docker_version="1.8.8"

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

start-chronograf() {
  start_ch_result=$(docker run \
  --detach \
  --env PUBLIC_URL=http://34.81.44.221:8888 \
  --name=$chronograf_docker_name \
  --publish $chronograf_docker_portmap \
  --volume $chronograf_docker_data \
  --log-opt max-size=1g \
  --log-opt max-file=5 \
  chronograf:$chronograf_docker_version --influxdb-url=$chronograf_influx_url)
  echo $start_ch_result
}

# remove container: provide container_name to be killed & remove
## container_name=influxdb-devnet
remove-container() {
  running=$(docker ps --filter "name=$remove_container_name" --format "{{.Names}}")
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