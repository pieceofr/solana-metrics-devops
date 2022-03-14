#!/usr/bin/env bash
# specify docker images
set -x
set +e

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

container_name=influxdb-sandbox
remove-container
container_name=kapacitor-sandbox
remove-container
container_name=telegraf-sandbox
remove-container
container_name=chronograf-sandbox
remove-container

#container_name=grafana
#remove-container

