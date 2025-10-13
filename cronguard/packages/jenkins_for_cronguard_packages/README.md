# "out of the box" this will not work(the slave node will not connect properly) 
## so these steps needs to be done...

* create a node in the webinterface(name jenkins_slave and workdir /opt/build)

* go to the settings of the new node

* copy the jar file to the jenkins_slave directory(as this one is mounted in the container)
```
curl -sO http://localhost:8080/jnlpJars/agent.jar 
```

* adjust the following line in jenkins_slave/start.sh with the secret from the settings page
```
java -jar /opt/agent.jar -url http://${ip}:8080/ -secret <change me> -name jenkins_slave -webSocket -workDir "/opt/build"
```

## optional
* disable the master node from execution(use only exclusive projects) from the settings to send all builds to the slave node

* restart both containers
```
docker compose down
...
docker compose up -d
```
