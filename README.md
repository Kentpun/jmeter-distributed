
## Repository for Running Distributed JMeter cluster

References:
[How to build a distributed load testing infrastructure with AWS, Docker, and JMeter, by Dragos Campean](https://dragoscampean.medium.com/how-to-build-a-distributed-load-testing-infrastructure-with-aws-docker-and-jmeter-accf3c2aa3a3)

### Steps to start

1. execute startup-script.sh on each node
2. execute `Master/startup-script.sh` on Master node
3. execute `Slave/startup-script.sh` on Slave node(s)
4. execute `jmeter -n -t /path/to/scriptFile.jmx -Dserver.rmi.ssl.disable=true -R host1PrivateIP, host2PrivateIP,..., hostNPrivateIP -l /path/to/logfile.jtl` to run JMeter script in distributed mode
