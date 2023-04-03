# file encryption/decryption
two scripts for encrypting and decrypting files

## encrypt.sh
script for encrypting a given file, the script will encrypt the content of the file, store it in a file with the same name and the .enc suffix, the source file will be deleted afterwards
assumed you have a file named _password_ with the following simple content:
```
~ cat password 
root    secret
admin   even_more_secret
```
after running the script encrypt.sh you will be prompted to type in a password
```
~ /encrypt.sh password 
enter AES-256-CBC encryption password:
Verifying - enter AES-256-CBC encryption password:
```
the result is a the new file password.enc with unreadable content:
```
Salted__Æ<8b>Ø^Ow1Ë<89>¾x¦¹Óÿ·)´çC^_ì<84>²^F^HN»ÆÙ^]"Û^T8^^wy^]<9a>¹á§r<8f>^Kr^\U¨ìcË^v/<8c>
```
## decrypt.sh
decrypting the above file will be done with:
```
~ ./decrypt.sh password.enc 
enter AES-256-CBC decryption password:
```
you will be again prompted to type in the password, afterwards there is the decrypted file _password_
```
~ cat password 
root    secret
admin   even_more_secret
```
just in case you type in the wrong password the script will abort with the following error message:
```
~ ./decrypt.sh password.enc 
enter AES-256-CBC decryption password:
something went wrong with decrypting password.enc, a wrong password maybe?
```
