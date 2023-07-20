#!/bin/bash
# author: andreas wendlandt
# desc:
# script to check the quality of passwords based on a point system where the best you can reach are 5 points
# in that case your password consists of at least 8 characters and contains lower letters, upper letters, numbers, special characters
# and has maximum only one character duplications
# last modified: 20230723

if ! source ../my_lib/my_lib 2>/dev/null; then
    echo "could not source file 'my_lib'... aborting!"
    exit 1
fi

if [[ ${#} -ne 1 ]]; then
    echo "error: that script needs one parameter, a password hash"
    echo "usage: ${0} jZ6-hA3_nW"
    exit 1
fi

password=${1}

password_quality(){
    points=0
    if [[ ${#password} -lt 8 ]]; then
        echo "password is too short"
	return 1
    fi
    password_length=${#password}
    password_different_chars=$((password_length-1))
    for (( i=0; i<${#password}; i++ )); do 
        if ! [[ "${password_temp}" =~ ${password:$i:1} ]]; then
            password_temp+="${password:$i:1}"
        fi
    done
    if [[ ${#password_temp} -ge ${password_different_chars} ]]; then
        points=$((points+1))
    else
        improve_duplication="- don't use char duplication\n"
    fi
    if has_lower_letter "${password}"; then
        points=$((points+1))
    else
        improve_lower_letters="- add lower letters\n"
    fi
    if has_upper_letter "${password}"; then
        points=$((points+1))
    else
        improve_upper_letters="- add upper letters\n"
    fi
    if has_specialchars "${password}"; then
        points=$((points+1))
    else
        improve_specialchars="- add specialchars\n"
    fi
    if has_int "${password}"; then
        points=$((points+1))
    else
        improve_integers="- add integers\n"
    fi
    if [[ -z ${improve_duplication} ]] && [[ -z ${improve_lower_letters} ]] \
    && [[ -z ${improve_upper_letters} ]] && [[ -z ${improve_specialchars} ]] \
    && [[ -z ${improve_integers} ]]; then
        echo "congrats, there is nothing you can improve with your password"
	echo "you reached 5 out of 5 possible points"
    else
        echo "you reached ${points} out of 5 possible points"
        echo -e "things you can improve:\n${improve_duplication}${improve_lower_letters}${improve_upper_letters}\
${improve_specialchars}${improve_integers}"
    fi
}

password_quality "${password}"
