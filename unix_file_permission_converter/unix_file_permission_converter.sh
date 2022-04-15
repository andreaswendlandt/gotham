#!/bin/bash
# author: andreaswendlandt
# desc: this script converts a string of classic unix permissions like rwxr-xr-- into a 4 character octal one
# last modified: 20220417
# shellcheck disable=SC2001
# todo: implement a check that tests the bits from the given parameter and that their position is correct (rwxr-x--- and not wrxw-r-- )

if [[ $# -ne 1 ]]; then 
    echo "Error, this script needs one parameter - a permission string"
    echo "Usage: $0 rwxr-xr-x"
    exit 1
fi

permission_string=${1}

if [[ ${#permission_string} -ne 9 ]]; then
    echo "wrong character number of permission string"
    exit 1
fi

if ! [[ $(echo "${permission_string}" | sed -e 's/[rwxsStT-]//g') == "" ]]; then
    echo "Illegal character in permission string"
    exit 1
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
