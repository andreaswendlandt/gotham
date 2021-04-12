# Passwordgenerator
## that script generates a random password string that consists of upper case letters, lower case letters, special characters and numbers
you call the script with a number as a parameter:
```
./password_generator.sh 12
your password:
S3r?n0+UxCt~
```
if you call the script without a parameter it will use the default value 8:
```
./password_generator.sh
No parameter given - defaulting to 8
your password:
F8k$o6{Y
```
the same value will be used when a non number parameter is passed to the script:
```
./password_generator.sh foobar
The given parameter is not an integer - defaulting to 8
your password:
G9u}b1[X
```
or when a number smaller than 8 is passed to the script:
```
./password_generator.sh 6
Password length too short - defaulting to 8
your password:
J2h*b2+W
```

