# Use Java 11 JDK Oracle Linux
FROM openjdk:11-jdk-oracle
MAINTAINER Dragos
# Set the JMeter version you want to use
ARG JMETER_VERSION="5.1.1"
# Set JMeter related environment variables
ENV JMETER_HOME /opt/apache-jmeter-${JMETER_VERSION}
ENV JMETER_BIN ${JMETER_HOME}/bin
ENV JMETER_DOWNLOAD_URL https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz
# Set default values for allocation of system resources (memory) which will be used by JMeter
ENV Xms 256m
ENV Xmx 512m
ENV MaxMetaspaceSize 1024m
# Change timezone to local time
ENV TZ="Europe/Bucharest"
RUN export TZ=$TZ
# Install jmeter
RUN microdnf install yum
RUN yum -y install curl \
 && mkdir -p /tmp/dependencies \
 && curl -L ${JMETER_DOWNLOAD_URL} > /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz \
 && mkdir -p /opt \
 && tar -xzf /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz -C /opt \
 && rm -rf /tmp/dependencies
# Set JMeter home
ENV PATH $PATH:$JMETER_BIN
# copy our entrypoint
COPY entrypoint.sh /
RUN chmod +x ./entrypoint.sh
# Run command to allocate the default system resources to JMeter at 'docker run'
ENTRYPOINT ["/entrypoint.sh"]
