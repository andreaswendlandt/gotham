#!/bin/bash
# author: andreas.wendlandt
# desc: create a password that consists of at least 8 characters(which is the default length)
# desc: you can call that script with a number as a parameter, that parameter should be greater than 8, in case the parameter
# desc: is smaller than 8 or is not a number at all the script will use 8 as a default value, the same 
# desc: applies when no parameter is passed
# desc: the script will always create a 8 character long "basic password" with 2 upper case letters, 2 lower case letters 
# desc: 2 numbers and 2 special characters
# desc: if the given number is larger than 8 the generated password will be the basic password + a random character from the 4 
# desc: character classes for every additional number(above 8) for example './password_generator 12' = basic password + 4 characters
# last modified: 25.05.2022

# function to check if a given parameter is an integer one
is_int(){
    if [ -z "${1//[[:digit:]]/}" ]; then
        return 0
    else
        return 1
    fi
}

# check if a parameter was given to the script and what kind it is
if [ $# -eq 1 ]; then
    if is_int "$1"; then
        if [ "$1" -lt 8 ]; then
            echo "Password length too short - defaulting to 8"
        else
            password_len=$1
	    length=true
        fi
    else
        echo "The given parameter is not an integer - defaulting to 8"
    fi
elif [ $# -gt 1 ]; then
    echo "Too many parameters given - defaulting to 8"
else
    echo "No parameter given - defaulting to 8"
fi
 
# arrays for 4 character classes(upper letters, lower letters, special chars, integers)
upper_letters=("A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M" "N" "O" "P" "Q" "R" "S" "T" "U" "V" "W" "X" "Y" "Z")
lower_letters=("a" "b" "c" "d" "e" "f" "g" "h" "i" "j" "k" "l" "m" "n" "o" "p" "q" "r" "s" "t" "u" "v" "w" "x" "y" "z")
special_chars=("!" "#" "$" "%" "&" "(" ")" "*" "+" "," "-" "." "/" ":" ";" "<" "=" ">" "?" "@" "[" "]" "^" "_" "{" "|" "}" "~")
integers=("0" "1" "2" "3" "4" "5" "6" "7" "8" "9")

# get the length of the 4 arrays
upper_letters_len=${#upper_letters[@]}
lower_letters_len=${#lower_letters[@]}
integers_len=${#integers[@]}
special_chars_len=${#special_chars[@]}

# generate a random char for a given characterclass
generate_random_char(){
    rand_int=$((0 + RANDOM % $1))
    declare -n char=$2
    random_char=${char[$rand_int]}
    echo "'$random_char'"
}

# create an 8 character long basic password with two characters from upper letters, lower letters, special chars and integers
upper="generate_random_char $upper_letters_len upper_letters"
lower="generate_random_char $lower_letters_len lower_letters"
integer="generate_random_char $integers_len integers"
special="generate_random_char $special_chars_len special_chars"
basic_password_raw="$(eval "$upper"; eval "$integer"; eval "$lower"; eval "$special"; eval "$lower"; eval "$integer"; eval "$special"; eval "$upper")"
basic_password_filtered=$(echo "$basic_password_raw" | sed -e 's/ //g' -e "s/'//g")
mapfile -t basic_password_purified < <(echo "$basic_password_filtered")
basic_password_final="${basic_password_purified[*]}"
basic_password="${basic_password_final// /}"

# check for the length of the passed parameter, if the length is less or equal 8 then just print out the basic password, if the length is 
# larger than 8 then create a password consisting of the basic password plus an additional password string
if "$length" >/dev/null 2>&1; then
    characters_left=$((password_len-8))    
    array_char=("upper" "lower" "integer" "special")
    declare -a additional_chars
    for (( i=1; i<=characters_left; i++ )); do
        rand_int=$((0 + RANDOM % 4))
        character_class=${array_char[$rand_int]}
	char=$(eval "\$$character_class")
	additional_chars+=("$char")
    done
    additional_password=$(echo "${additional_chars[*]}" | sed -e 's/ //g' -e "s/'//g")
    long_password="${basic_password}${additional_password}"
    echo "your password:"
    echo "$long_password"
else
    echo "your password:"
    echo "$basic_password"
fi
