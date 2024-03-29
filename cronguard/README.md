# CRONGUARD
## ensure that your cronjobs finish successfully or get notified via mail if they don't
###### this application pulls the logic about if a cronjob succeeded or failed and the notification about failed or stuck cronjobs out of cron itself 
it consists of 3 parts, at the client side the wrapper script cron_wrapper.sh - whatever you want to run, either a script, a command or a piped command chain, just call the script with the cronjob you want to execute, it starts a post curl with some metadata about the cronjob(start time, command, a generated token, the hostname, the action and the result) to the cronguard server, executes the cronjob and sends the result of the cronjob again to the cronguard server with a second post curl 
on the server the script cronguard.php takes the data and writes it into a database(and provides a simple api so that you can check all entries via a browser)
finally on the server runs the script cronguard.sh in a daemon mode, it checks once per minute if there are entries in the database and processes them - in terms of entries which have the result success it removes the entry, in case the result of a failed one it sends a mail to the configured mail address and then removes the entry, the third possibility is that a job has no result as it is still running, then it checks if the cronjob is running for longer than one day, in case it is running for longer than one day the entry will be removed and a mail will be send
1. client
  
    1.1 cronwrapper
    - script cron_wrapper.sh
    - reports to the cronguard server via curl the start of a cronjob, the end and the succesful or nonsuccesful result of the cronjob
    - dependency: the package 'curl' must be installed
    - example: 
    ```
    ./cron_wrapper.sh "command1 | command2 | command3" 
    ```
    or
    ```
    ./cron_wrapper.sh "your_script"
    ``` 
    or  
    ```
    ./cron_wrapper.sh "command"
    ```
     
   1.2 required file
   - url.inc.sh - in that file is the url to the cronguard server, cron_wrapper.sh expects it in the direcory /opt/cronguard

2. server

    2.1 database
    - dependency, a running mysql or mariadb server, as an example for mysql the following packages must be installed:
      - libmysqlclient20:amd64
      - mysql-client-5.7
      - mysql-client-core-5.7
      - mysql-common
      - mysql-server
      - mysql-server-5.7
      - mysql-server-core-5.7
    
    2.1.1 database creation (mysql)
    - mysql table structure:
    ```
    jobid(bigint)
    token(char 6)
    host(varchar 50)
    start_time(bigint)
    end_time(bigint)
    command(varchar 300)
    action(varchar 8)
    result(varchar 7)
    ```
    - mysql commands to create the database, table and user:
    ```
    CREATE DATABASE cronguard;
    ```
    ```
    CREATE TABLE jobs ( jobid INT NOT NULL AUTO_INCREMENT, token CHAR(6), host VARCHAR(50), start_time BIGINT, end_time BIGINT, command VARCHAR(300), action VARCHAR(8), result VARCHAR(7), PRIMARY KEY (jobid) ) ENGINE MyISAM;
    ```
    ```
    GRANT ALL PRIVILEGES ON cronguard.* TO 'cronguard'@'localhost' identified by 'cronguard';
    ```

    2.2 webserver + php
    - in case of apache2 and php(in that example php-7.2) the following packages must be installed:
      - apache2
      - apache2-bin
      - apache2-data
      - apache2-utils
      - libapache2-mod-dnssd
      - libapache2-mod-php7.2
      - php
      - php-common
      - php-json
      - php7.2
      - php7.2-cli
      - php7.2-common
      - php7.2-json
      - php7.2-mysql
      - php7.2-opcache
      - php7.2-readline
        
    2.3 cronguard server script cronguard.php - has two purposes:
    
    2.3.1 the first purpose is a to be a server for the cron wrapper, it receives the data that is sent from the cron wrapper via post and writes it into the database
    
    2.3.2 the second purpose is to provide a rest api:
     - in case there are entries in the database you can look at them with a browser by calling the following url: http://localhost/cronguard.php?method=api you get all entries in json format or, if there are none, you get "0 Results"
    
    2.3.3 required file
     - the file db.inc.php needs to be in place in the same directory, it manages all database connections

3. cronguard daemon - the script cronguard.sh
  - checks once per minute the database if there are entries, 3 states are possible for the result column, success - the entry will be deleted, fail - a mail will be sent and the entry will be deleted, null - the cronjob is still running, cronguard will check for how long the cronjob is running, if it is running longer than one day a mail will be sent and the entry will be deleted, otherwise nothing happens
 
    3.1. required files
    - db.inc.sh - database credentials and the used tablename, cronguard expects this file in /opt/cronguard
    - mail.inc.sh - the mail address where the mails will be sent to, cronguard expects this file in /opt/cronguard

    3.2 usage 
    - it behaves and is used like a regular daemon: 
    ```
    ./cronguard.sh start | stop | restart | status
    ```
    - start will start cronguard in case it is not running yet
    - stop will stop cronguard in case it is running
    - restart will stop and then start cronguard in case it is running, if it is not running it will be started
    - status will print out the state of cronguard, either it is running or not

    3.3 best practice
    - copy the script to /etc/init.d/cronguard, now it can be treated the "nix" fashion way like
    
    ```/etc/init.d/cronguard start | stop | restart | status```
    - one step further - activate the daemon so it will start and stop with the system:
    ```
    update-rc.d cronguard defaults
    ```
    - to disable it
    ```
    update-rc.d cronguard disable
    ```

4. additional stuff

    4.1. nagios/icinga plugin check_daemon.sh
    - for the above described case that you run cronguard as a "real" daemon under /etc/init.d/ you may want to know or get informed if cronguard is not running(anymore) 
    - usage:
    ```./check_daemon.sh cronguard```
    - useful hint: this script works with every daemon/service located under /etc/init.d/
