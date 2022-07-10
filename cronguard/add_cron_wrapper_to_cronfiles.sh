#!/bin/bash
# author: awendlandt
# desc: replace existing cronjob commands with the same command but called by cron_wrapper.sh for all files in /etc/cron.d 
# note: this script only works for files in /etc/cron.d (and all similar directories) - and not for crontab files!
# last modified: 09.07.2022

insert_script="/opt/cronguard/cron_wrapper.sh"
logfile="/var/log/$0.log"
rm -rf "${logfile}" >/dev/null 2>&1

tmp_dir=$(mktemp -d)
cd "${tmp_dir}" || exit 1

for file in $(ls -1 /etc/cron.d_tmp/); do
    (cat /etc/cron.d_tmp/"$file"; echo) | while read -r line; do
        if  echo "$line" | egrep '^#|^([[:alpha:]]{1,}|[[:alnum:]]{1,}[[:punct:]]{1}[[:alnum:]]{1,}=)' >/dev/null; then
            echo -e "line '$line' from file '$file' - skipping...\n" >>$logfile
	    continue
        elif echo "$line" | egrep '^$|^[[:blank:]]' >/dev/null; then
            continue
        elif  echo "$line" | grep "$insert_script" >/dev/null; then
            echo -e "line '$line' from file '$file' already has the cron_wrapper.sh\n" >>$logfile
	    continue
        elif ! echo "$line" | grep "$insert_script" >/dev/null; then
		set -- $line
		cron_command=$(echo "${@:7:$#}")
	        cron_command=$(echo "$cron_command" | sed -e 's,\\,\\\\,g' -e 's,*,\\*,g' -e 's,=,\\=,g' -e 's,\[,\\[,g' -e 's,\],\\],g')
		line_replace=$(echo "$line" | sed -e "s,$cron_command,$insert_script \"&\",")
		line_replace=$(echo "$line_replace" | sed -e 's,\\,\\\\,g' -e 's,*,\\*,g'  -e 's,=,\\=,g' -e 's,&,\\&,g' -e 's,\,,\\\,,g' -e 's,\[,\\[,g' -e 's,\],\\],g')
		line_old=$(echo "$line" | sed -e 's,\\,\\\\,g' -e 's,*,\\*,g'  -e 's,=,\\=,g' -e 's,\,,\\\,,g' -e 's,\[,\\[,g' -e 's,\],\\],g')
		sed -i "s,$line_old,$line_replace," /etc/cron.d_tmp/$file
		echo -e "line '$line' from file '$file' - adapted...\n" >>$logfile
        else
            echo -e "something went wrong with line '$line' in file '$file'\n" >>$logfile
        fi
    done
done

rm -rf $tmp_dir >/dev/null 2>&1
