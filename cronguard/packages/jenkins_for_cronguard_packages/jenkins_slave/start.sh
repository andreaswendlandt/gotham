#!/bin/bash

ip=$(dig +short jenkins_master)

service mysql start >/tmp/mysql.log 2>&1
sleep 10
service apache2 start >/tmp/apache.log 2>&1

java -jar /opt/agent.jar -url http://${ip}:8080/ -secret 89cccc98d3a9a54933a0ae59120f734961e9d0a017353c955b7d2f1ac5258e08 -name jenkins_slave -workDir "/opt/build"

# if the above command does not work - try this one:
#java -jar /opt/agent.jar -url http://${ip}:8080/ -secret 89cccc98d3a9a54933a0ae59120f734961e9d0a017353c955b7d2f1ac5258e08 -name jenkins_slave -webSocket -workDir "/opt/build"

