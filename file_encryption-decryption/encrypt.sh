#!/bin/bash

if [[ $# -ne 1 ]]; then
  echo "error: that script needs one parameter, a file to encrypt"
  echo "usage: $0 filename"
  exit 1
fi

openssl enc -e -aes256 -pbkdf2 -in "${1}" -out "${1}".enc
rm "${1}"
