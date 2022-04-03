
## Repository for Running Distributed JMeter cluster


Repository by Kent Pun, for personal academic and scientific purposes. Feel free to contact me for any suggestions or fun collabs :)

References:
[How to build a distributed load testing infrastructure with AWS, Docker, and JMeter – by Dragos Campean](https://dragoscampean.medium.com/how-to-build-a-distributed-load-testing-infrastructure-with-aws-docker-and-jmeter-accf3c2aa3a3)

### [WIP]: To support on-demand resource

Details:
1. Ability to start pods on-demand
2. Automated script

### Running JMeter master-slave nodes on Kubernetes

##### Prerequisite

1. install kubectl
2. install kustomize

##### Useful Commands

To deploy:
```
make deploy
```

To delete all resources:
```
make delete
```

### Steps to run JMeter master-slave nodes on instances

1. Execute `./startup-script.sh` on each node
2. Execute `Master/startup-script.sh` on Master node
3. Execute `Slave/startup-script.sh` on Slave node(s)
4. (optional) Upload the .jmx file to s3 and execute following to download .jmx file to JMeter nodes
```yes | sudo apt install awscli
aws s3 cp s3://bucket-name/folder-name/test-plan.jmx /home/ubuntu/dest-file-name/test-plan.jmx
chown ubuntu /home/ubuntu/dest-file-name/test-plan.jmx
docker cp /home/ubuntu/dest-file-name/test-plan.jmx master:/home/test-plan.jmx
```
5. Execute the following in master node to run JMeter script in distributed mode (*hostNPrivateIP* refers to private IPs of Slave node(s))
```
jmeter -n -t /path/to/scriptFile.jmx -Dserver.rmi.ssl.disable=true -R host1PrivateIP, host2PrivateIP,..., hostNPrivateIP -l /path/to/logfile.jtl
```

*note: you may include the shell scripts from step 1, 2, 3 & 4 in ec2 user-data*
