
## Repository for Running Distributed JMeter cluster

*Remarks: this repo assumes the use of* ***Ubuntu*** *instances*

References:
[How to build a distributed load testing infrastructure with AWS, Docker, and JMeter – by Dragos Campean](https://dragoscampean.medium.com/how-to-build-a-distributed-load-testing-infrastructure-with-aws-docker-and-jmeter-accf3c2aa3a3)

### Steps to start

1. execute `./startup-script.sh` on each node *
2. execute `Master/startup-script.sh` on Master node *
3. execute `Slave/startup-script.sh` on Slave node(s) *
4. (optional) execute following to download .jmx file to JMeter nodes
```yes | sudo apt install awscli
aws s3 cp s3://bucket-name/folder-name/test-plan.jmx /home/ubuntu/dest-file-name/test-plan.jmx
chown ubuntu /home/ubuntu/dest-file-name/test-plan.jmx
docker cp /home/ubuntu/dest-file-name/test-plan.jmx master:/home/test-plan.jmx
```
5. execute the following in master node to run JMeter script in distributed mode
```
jmeter -n -t /path/to/scriptFile.jmx -Dserver.rmi.ssl.disable=true -R host1PrivateIP, host2PrivateIP,..., hostNPrivateIP -l /path/to/logfile.jtl
```

*note: you may include the shell scripts from step 1, 2, 3 & 4 in launch template*
