#!/bin/bash

if [[ $# -ne 1 ]]; then
  echo "error: this script needs 1 parameter, a file that will be decrypted"	
  echo "usage: $0 encrypted_file decrypted_file"
  exit 1
fi

decrypted_file=${1%.*}
if openssl enc -d -aes256 -pbkdf2 -in "${1}" -out "${decrypted_file}" 2>/dev/null; then
    rm "${1}" >/dev/null 2>&1
else
    echo "something went wrong with decrypting ${1}, a wrong password maybe?"
    rm "${decrypted_file}"
fi
