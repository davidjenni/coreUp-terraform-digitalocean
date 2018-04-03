#!/usr/bin/env bash
if [ -z $1 -o -z $2 ]; then
    echo Usage: $0 join_token advertise_ip_addr
    exit 1
fi

while [ ! $(docker info -f '{{json .OperatingSystem}}') ];
    do sleep 2
done

docker swarm join --token $1 $2:2377
exit $?
