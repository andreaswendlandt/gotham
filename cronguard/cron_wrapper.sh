#!/bin/bash
# author: andreas wendlandt
# desc: wrapper script for cronjobs
# desc: it notifies the cronguard server via curl about the start-/endtime and the result of a command or script
# last modified: 20250409
# shellcheck disable=SC2048

if [ ${#} -ne 1 ]; then
    echo "this script needs one parameter, a single command, a script or a command-chain"
    echo "Usage: ${0} \"command1 | command2 | command3\""
    echo "       or"
    echo "       ${0} \"./script.sh\""
    echo "       or"
    echo "       ${0} \"command1 && command2\""
    echo "       or"
    echo "       ${0} \"command1; command2\""
    echo "       or"
    echo "       ${0} \"command1 || command2\""
    exit 1
fi

# check that curl is present on the system
if ! which curl >/dev/null; then
    echo "error, curl is missing on this system, the cronjob will be executed but the cronguard server will not be contacted"
fi

# include config File
if ! source /opt/cronguard/url.inc.sh 2>/dev/null; then
    echo "could not include url.inc.sh from /opt/cronguard, the cronjob will be executed but the cronguard server will not be contacted"
fi

# variables
command="${1}"
host=$(hostname)
token=$(openssl rand -hex 3)
start_time=$(date +%s)
action="start"

# first curl, adding a new database entry with the starttime
curl -X POST -F "token=${token}" -F "host=${host}" -F "start_time=${start_time}" --form-string "command=${command}" -F "action=${action}" "${url}"

# execute the cron command(s) and save the pipestatus / returnvalue in the variable "pipe"
pipe=
if echo "${command}" | grep ";">/dev/null 2>&1;then
    commands=$(echo -e "${command//\;/\\n}")
    i=0
    while read -r subcommand; do
        eval "${subcommand}; " ; eval "pipe[$i]"=$?
        i=$((i+1))
    done < <(echo "${commands}")
    set "${pipe[@]}"
    j=1
    error=
    for a in $*; do
        if [ "${a}" -ne 0 ]; then
            error="${error} ${j}.command"
        fi
        j=$((j+1))
    done
else
    eval "${command}; "'pipe=${PIPESTATUS[*]}'
    set "${pipe}"
fi

# checking the array for errors
j=1
error=
for a in $*; do
    if [ "${a}" -ne 0 ]; then
        error="${error} ${j}.command"
    fi
    j=$((j+1))
done

# defining the result for the next curl and database entry
result=
if [ -z "${error}" ]; then
    result="success"
else
    result="fail"
fi

# define the endtime and make the second curl, modify the above database entry
action="finished"
end_time=$(date +%s)
curl -X POST -F "token=${token}" -F "action=${action}" -F "end_time=${end_time}" -F "result=${result}" "${url}"
