#!/bin/bash
sudo apt-get install  curl  apt-transport-https ca-certificates software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce
USER_DOCKER=$(getent passwd {1000..60000} | grep "/bin/bash" | awk -F: '{ print $1}')
sudo usermod -aG docker $USER_DOCKER
