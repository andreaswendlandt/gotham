#!/bin/bash
# author: andreas wendlandt
# desc: script to encrypt or decrypt a file with a self chosen password
# last modified: 20230416

print_help(){
    echo "error: something went wrong with the parameters and options"
    echo "you need to pass either -e for encrypting or -d for decrypting and -i <filename> for the input file"
    echo "example: $0 -e -i password"
    echo "this would encrypt the content of password, save it in password.enc and remove the source file password"
    echo "or"
    echo "example: $0 -d -i password.enc"
    echo "this would decrypt the encrypted file password.enc and save it in password and remove the file password.enc"
    exit 1
}

help=false
encrypt=false
decrypt=false

while getopts hedi: opt 2>/dev/null
do
   case $opt in
       h) help=true;;
       e) encrypt=true;;
       d) decrypt=true;;
       i) input_file=${OPTARG};;
       *) print_help
   esac
done

if [[ ${help} == true ]]; then
    print_help
elif [[ ${encrypt} == true ]] && [[ ${decrypt} == true ]]; then
    print_help
elif [[ ${encrypt} == false ]] && [[ ${decrypt} == false ]]; then
    print_help
else
    if [[ ${encrypt} == true ]]; then
        output_file="${input_file}.enc"
        command="openssl enc -${option} -aes256 -pbkdf2 -in "${input_file}" -out "${output_file}""
    elif [[ ${decrypt} == true  ]]; then
        decrypted_file=${input_file%.*}
        command="openssl enc -d -aes256 -pbkdf2 -in "${input_file}" -out "${decrypted_file}" 2>/dev/null && rm ${input_file}"
    fi
fi

if eval "${command}"; then
    rm "${input_file}" >/dev/null 2>&1
else
    rm ${decrypted_file} >/dev/null 2>&1
fi
