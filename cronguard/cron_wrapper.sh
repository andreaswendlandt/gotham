#!/bin/bash
# author: guerillatux
# desc: wrapper script for cronjobs whith or without piped commands
# desc: it notifies the cronguard server via curl about the start-/endtime and the result of a command or script
# last modified: 1.12.2018

if [ $# -ne 1 ]; then
    echo "This Script needs 1 Parameter, a Command-Chain"
    echo "Usage: $0 <\"command1|command2|command3\">"
    exit 1
fi

# Check that curl is present on the system
if ! which curl >/dev/null; then
    echo "Error, curl is missing on this system!"
    exit 1
fi

# Variables
command="$1"
host=$(hostname)
token=$(openssl rand -hex 3)
start_time=$(date +%s)
action="start"

# First curl, adding a new Database Entry with the Starttime
curl -X POST -F "token=$token" -F "host=$host" -F "start_time=$start_time" -F "command=$command" -F "action=$action" http://localhost/cron.php

# Execute the Cron Command and save the Pipestatus in the Variable "pipe"
eval "$command; "'pipe=${PIPESTATUS[*]}'
set $pipe

# Checking the Array for Errors
j=1
error=
for i in $*; do
    if [ $i -ne 0 ]; then
        error="$error $j.command"
    fi
    j=$((j+1))
done

# Defining the Result for the next Curl and Database Entry
result=
if [ -z "$error" ]; then
    result="success"
else
    result="fail"
fi

# Define the Endtime and make the second Curl, modify the above Database Entry
action="finished"
end_time=$(date +%s)
curl -X POST -F "token=$token" -F "action=$action" -F "end_time=$end_time" -F "result=$result" http://localhost/cron.php
