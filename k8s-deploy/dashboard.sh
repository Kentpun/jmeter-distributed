#!/usr/bin/env bash

working_dir=`pwd`

#Get namesapce variable
tenant="jmeter"

## Create jmeter database automatically in Influxdb

echo "Creating Influxdb jmeter Database"

##Wait until Influxdb Deployment is up and running
##influxdb_status=`kubectl get po -n $tenant | grep influxdb-jmeter | awk '{print $2}' | grep Running

influxdb_pod=`kubectl get po -n $tenant | grep influxdb | awk '{print $1}'`
kubectl exec -ti -n $tenant $influxdb_pod -- influx -execute 'CREATE DATABASE jmeter'

## Create the influxdb datasource in Grafana

echo "Creating the Influxdb data source"
grafana_pod=`kubectl get po -n $tenant | grep grafana | awk '{print $1}'`

## Make load test script in Jmeter master pod executable

#Get Master pod details

master_pod=`kubectl get po -n $tenant | grep master | awk '{print $1}'`
kubectl exec -ti -n $tenant $master_pod -- bash -c "mkdir -p /jmeter && ls -la /jmeter"
kubectl exec -ti -n $tenant $master_pod -- bash -c "cp -r /load_test /jmeter/load_test && ls -la /jmeter"

kubectl exec -ti -n $tenant $master_pod -- chmod 755 /jmeter/load_test

##kubectl cp $working_dir/influxdb-jmeter-datasource.json -n $tenant $grafana_pod:/influxdb-jmeter-datasource.json

kubectl exec -ti -n $tenant $grafana_pod -- curl 'http://admin:admin@127.0.0.1:3000/api/datasources' -X POST -H 'Content-Type: application/json;charset=UTF-8' --data-binary '{"name":"jmeterdb","type":"influxdb","url":"http://jmeter-influxdb:8086","access":"proxy","isDefault":true,"database":"jmeter","user":"admin","password":"admin"}'
