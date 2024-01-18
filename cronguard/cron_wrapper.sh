#!/bin/bash
# author: andreaswendlandt
# desc: wrapper script for cronjobs whith or without piped commands
# desc: it notifies the cronguard server via curl about the start-/endtime and the result of a command or script
# last modified: 21.12.2020

if [ $# -ne 1 ]; then
    echo "This Script needs 1 Parameter, a Command-Chain"
    echo "Usage: $0 <\"command1|command2|command3\">"
    exit 1
fi

# Check that curl is present on the system
if ! which curl >/dev/null; then
    echo "Error, curl is missing on this system, the cronjob will be executed but the cronguard server will not be contacted"
fi

# Include config File
if ! source /opt/cronguard/url.inc.sh 2>/dev/null; then
    echo "Could not include url.inc.sh from /opt/cronguard, the cronjob will be executed but the cronguard server will not be contacted"
fi

# Variables
command="$1"
host=$(hostname)
token=$(openssl rand -hex 3)
start_time=$(date +%s)
action="start"

# First curl, adding a new database entry with the starttime
curl -X POST -F "token=$token" -F "host=$host" -F "start_time=$start_time" -F "command=$command" -F "action=$action" $url

# execute the cron command(s) and save the pipestatus / returnvalue in the variable "pipe"
if echo $command | grep ";">/dev/null 2>&1;then
    commands=$(echo $command|sed -e 's/\;/\n/g')
    i=0
    while read subcommand; do
        eval "$subcommand; " ; eval "pipe[$i]"=$(echo $?)
        i=$((i+1))
    done < <(echo "$commands")
    set ${pipe[*]}
    j=1
    error=
    for a in $*; do
        if [ $a -ne 0 ]; then
            error="$error $j.command"
        fi
        j=$((j+1))
    done
else
    eval "$command; "'pipe=${PIPESTATUS[*]}'
    set $pipe
fi

# Checking the Array for errors
j=1
error=
for a in $*; do
    if [ $a -ne 0 ]; then
        error="$error $j.command"
    fi
    j=$((j+1))
done

# Defining the result for the next curl and database entry
result=
if [ -z "$error" ]; then
    result="success"
else
    result="fail"
fi

# Define the endtime and make the second curl, modify the above database entry
action="finished"
end_time=$(date +%s)
curl -X POST -F "token=$token" -F "action=$action" -F "end_time=$end_time" -F "result=$result" $url
