#!/bin/bash
HostIP=$(ip route show | awk '/default/ {print $9}')
docker pull kentpun/jmeter-distributed:jmeter-slave
docker run -dit --name slave --network host -e HostIP=$HostIP -e Xms=256m -e Xmx=512m -e MaxMetaspaceSize=512m dragoscampean/testrepo:jmetruslave /bin/bash
