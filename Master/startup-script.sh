#!/bin/bash
HostIP=$(ip route show | awk '/default/ {print $9}')
docker pull kentpun/jmeter-distributed:jmeter-master
docker run -dit --name master --network host -e HostIP=$HostIP -e Xms=256m -e Xmx=512m -e MaxMetaspaceSize=512m -v /opt/Sharedvolume:/opt/Sharedvolume kentpun/jmeter-distributed:jmeter-master /bin/bash
