FROM kentpun/jmeter-distributed:jmeterbase-1

MAINTAINER kentpun

# Expose ports for JMeter Slave
EXPOSE 1099 50000

COPY entrypoint.sh /

RUN chmod +x ./entrypoint.sh

# Run command to allocate the default system resources to JMeter at 'docker run' and start jmeter-server with all required parameters
ENTRYPOINT	["/entrypoint.sh"]
