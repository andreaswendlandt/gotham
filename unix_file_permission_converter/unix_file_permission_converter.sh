#!/bin/bash
# author: andreaswendlandt
# desc: this script converts a string of classic unix permissions like rwxr-xr-- into a 4 character octal one
# last modified: 20220504
# shellcheck disable=SC2001

if [[ $# -ne 1 ]]; then 
    echo "Usage: $0 rwxr-xr-x"
    exit 1
fi

permission_string=${1}

if [[ ${#permission_string} -ne 9 ]]; then
    echo "Wrong character number of permission string"
    exit 1
fi

if ! [[ $(echo "${permission_string}" | sed -e 's/[rwxsStT-]//g') == "" ]]; then
    echo "Illegal character in permission string"
    exit 3
fi

check_position(){
    if [[ $1 == *"$2"* ]]; then
        return 0
    else
        return 1
    fi
}

j=1
for i in {0..8}; do
    if [[ $i == 0 ]] || [[ $i == 3 ]] || [[ $i == 6 ]]; then
        if ! check_position r- "${permission_string:i:1}"; then
            wrong_char="$j.position (${permission_string:i:1})"
        fi
    elif [[ $i == 1 ]] || [[ $i == 4 ]] || [[ $i == 7 ]]; then
        if ! check_position w- "${permission_string:i:1}"; then
            wrong_char="${wrong_char} $j.position (${permission_string:i:1})"
        fi
    elif [[ $i == 2 ]] || [[ $i == 5 ]]; then
        if ! check_position x-sS "${permission_string:i:1}"; then
            wrong_char="${wrong_char} $j.position (${permission_string:i:1})"
        fi
    elif [[ $i == 8 ]]; then
        if ! check_position x-tT "${permission_string:i:1}"; then
            wrong_char="${wrong_char} $j.position (${permission_string:i:1})"
        fi
    fi
    j=$((j+1))
done

if [[ -n $wrong_char ]]; then
    echo "wrong character: $wrong_char!"
    exit 5
fi


if [[ ${permission_string} =~ [sStT] ]]; then
    i=1
    while read -r line; do
        if [[ $i == 1 ]] && [[ $line =~ [Ss] ]]; then
	    if [[ $line =~ s ]]; then
	        permission_string=$(echo "${permission_string}" | sed 's/./x/3')
	    elif [[ $line =~ S ]]; then
	        permission_string=$(echo "${permission_string}" | sed 's/./-/3')
            fi
            special_bit=4
        elif [[ $i == 2 ]] && [[ $line =~ [Ss] ]]; then
	    if [[ $line =~ s ]]; then
	        permission_string=$(echo "${permission_string}" | sed 's/./x/6')
	    elif [[ $line =~ S ]]; then
	        permission_string=$(echo "${permission_string}" | sed 's/./-/6')
            fi
            special_bit=$((special_bit+2))
        elif [[ $i == 3 ]] && [[ $line =~ [Tt] ]]; then
	    if [[ $line =~ t ]]; then
	        permission_string=$(echo "${permission_string}" | sed 's/./x/9')
	    elif [[ $line =~ T ]]; then
	        permission_string=$(echo "${permission_string}" | sed 's/./-/9')
            fi
            special_bit=$((special_bit+1))
        fi
        ((i++))
    done <<< "$(echo "${permission_string}" | grep -o ".\{3\}")"
else
    special_bit=0
fi

octal(){
    oct=$(echo "${1}" | awk '{k=0; for(i=0;i<=8;i++)k+=((substr($1,i+1,1)~/[rwx]/)*2^(8-i)); if(k)printf("%0o ",k)}')
    echo "$oct"
}

calculated_permissions=$(octal "${permission_string}")
complete_octal_permissions="${special_bit}${calculated_permissions}"
echo "${complete_octal_permissions}"
