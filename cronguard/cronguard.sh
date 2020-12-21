#!/bin/bash
# author: guerillatux
# desc: Cronguard Daemon, checks and processes Database Entries, sends Mails and removes them
# last modified: 07.08.2020

# Quit if not called by root
if [ "$(id -u)" -ne "0" ]; then
    echo "Error: Cronguard must be run as root"
    exit 1
fi

# Variables
daemon="cronguard"
pidfile="/var/run/cronguard.pid"
init_pidfile="/var/run/cronguard_init.pid"
logfile="/var/log/cronguard.log"
pid="$$"
interval="60"

# Check if called with sudo (important for checking the processes)
if ps -ef | grep $((pid -1)) | grep sudo >/dev/null 2>&1; then 
    sudo_pid=$((pid -1))
fi

# Logging Function
log() {
    echo $(date) "$@" >>$logfile
}

# Include Config Files
if ! source /opt/cronguard/db.inc.sh 2>/dev/null; then
    log "Could not include db.inc.sh from /opt/cronguard, aborting"
    exit 1
fi

if ! source /opt/cronguard/mail.inc.sh 2>/dev/null; then
    log "Could not include mail.inc.sh from /opt/cronguard, aborting"
    exit 1
fi

# Sending Mail Function
send_mail(){
    subject="$1"
    body="$2"
    echo "$body" | mail -s "$subject" $mail_to
}

# Starting Cronguard Function
start_cronguard() { 
    if [ $(check_cronguard; echo $?) -eq 1 ]; then
        echo "Error: $daemon is already running."
        exit 1
    fi
    echo "Starting $daemon with PID: $pid"
    echo "$pid" > "$pidfile"
    log "Starting $daemon"
    loop &
}

# Stopping Cronguard Function
stop_cronguard() {
    if [ $(check_cronguard; echo $?) -eq 0 ]; then
        echo "Error: $daemon is not running"
        exit 1
    fi
    echo "Stopping $daemon"
    log "Stopping $daemon"
    init_pid=$(ps -ef | grep cronguard | grep -v grep | awk '$3 ~ /1/ {print $2}')
    echo "$init_pid" > "$init_pidfile"
    if [ -s $pidfile ]; then
        pidfile_content=$(cat "$pidfile")
        init_pidfile_content=$(cat "$init_pidfile")
        rm -rf $pidfile >/dev/null 2>&1
        rm -rf $init_pidfile >/dev/null 2>&1
        kill -15 $(echo "$pidfile_content") >/dev/null 2>&1
        kill -15 $(echo "$init_pidfile_content") >/dev/null 2>&1
    else
        echo "Error: Can not stop $daemon because $pidfile is empty, please check manually!"
        log "Error: Can not stop $daemon because $pidfile is empty, please check manually!"
    fi
}

# Status of Cronguard Function
status_cronguard() {
    if [ $(check_cronguard; echo $?) -eq 1 ]; then
        echo "$daemon is running"
    else
        echo "$daemon is not running"
    fi
    exit 0
}

# Restarting Cronguard Function
restart_cronguard() {
    if [ $(check_cronguard; echo $?) -eq 0 ]; then
        echo "$daemon is not running, starting it"
	log "Starting $daemon"
	start_cronguard
    fi
    echo "Restarting $daemon"
    log "Restarting $daemon"
    stop_cronguard
    start_cronguard
}

# Checking Cronguard Function
check_cronguard() {
    if [ -z "$sudo_pid" ]; then
        if ! [ -z "$oldpid" ] && ps -ef | grep "$daemon" | egrep -v "grep|$pid|mysql|cronguard.log" > /dev/null 2>&1; then
            # Daemon is running
            return 1
        else
            # Daemon isn't running.
            return 0
        fi
    else
        if ! [ -z "$oldpid" ] && ps -ef | grep "$daemon" | egrep -v "grep|$pid|$sudo_pid|mysql|cronguard.log" > /dev/null 2>&1; then
            # Daemon is running
            return 1
	else
            # Daemon isn't running.
            return 0
        fi
    fi
}

# Cronguard Function
cronguard() {
    query=$(mysql -u $db_user -p$db_password $db -e"SELECT token,result,host FROM $table" 2>&1 | grep -v 'Using a password' | tail -n +2)
    if ! [ -z "$query" ]; then
        echo -e "$query" | while read line; do
            set $line
	    if [ "$2" == "success" ]; then
                log "$1 will be removed"
	        if mysql -u $db_user -p$db_password $db -e"DELETE FROM $table WHERE token = \"$1\"" 2>&1 | grep -v 'Using a password'; then
                    log "$1 from $3 removed"
                fi
            elif [ "$2" == "fail" ]; then
                log "$1 will be sent"
                failed_command=$(mysql -u $db_user -p$db_password $db -e"SELECT command FROM $table WHERE token =\"$1\"" 2>&1 | grep -v 'Using a password' | tail -n +2)
                if send_mail "Failed Cronjob on $3" "This Cronjob failed: \"$failed_command\""; then
	            mysql -u $db_user -p$db_password $db -e"DELETE FROM $table WHERE token = \"$1\"" 2>&1 | grep -v 'Using a password'
	        fi    
            elif [ "$2" == "NULL" ]; then
                log "$1 is still running"
	        current_time=$(date +%s)
                start_time=$(mysql -u $db_user -p$db_password $db -e"SELECT start_time FROM $table WHERE token =\"$1\"" 2>&1 | grep -v 'Using a password' | tail -n +2)
	        running_since=$((current_time-start_time))
                if [ $running_since -ge 86400 ]; then
                long_running_command=$(mysql -u $db_user -p$db_password $db -e"SELECT command FROM $table WHERE token =\"$1\"" 2>&1 | grep -v 'Using a password' | tail -n +2)
                    if send_mail "Long running Cronjob on $3" "This Cronjob is running longer than one day($running_since seconds): \"$long_running_command\""; then
                        mysql -u $db_user -p$db_password $db -e"DELETE FROM $table WHERE token = \"$1\"" 2>&1 | grep -v 'Using a password'
	            fi
                fi
            fi
        done
    else
        log "empty db"
    fi
    sleep 1
}

# Loop Function
loop(){
    now=$(date +%s)
    cronguard
    last=$(date +%s)
    result=$((now-last+interval))
    if [ $result -lt $interval -a $result -gt 0 ]; then
        sleep $result
    fi
    loop
}

# Defining the oldpid variable for checking purposes
if [ -f "$pidfile" ]; then
    oldpid=$(cat "$pidfile")
fi

# Daemon Functionality
case "$1" in
  start)
    start_cronguard
    ;;
  stop)
    stop_cronguard
    ;;
  status)
    status_cronguard
    ;;
  restart)
    restart_cronguard
    ;;
  *)
  echo "Error, Usage: $0 start | stop | restart | status"
  exit 1
esac
