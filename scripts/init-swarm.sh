#!/usr/bin/env bash
if [ -z $1 ]; then
    echo Usage: $0 advertise_ip_addr
    exit 1
fi

while [ ! $(docker info -f '{{json .OperatingSystem}}') ];
    do sleep 2
done

docker swarm init --advertise-addr $1
exit $?
