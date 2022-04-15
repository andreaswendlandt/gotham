## unix_file_permission_converter
# what it is

the unix_file_permission_converter.sh converts classic unix file permissions like `rwxr-wr-w` into the octal version of it `755` 
it is also capable of handling the special bits setuid, setgid and sticky bit - weather they are set correctly or not

# how to use it
call the script with the permission string you want to have in octal

`./unix_file_permission_converter.sh rwxr-xr-t`

`1755`

important is that the permission string you call the script as a parameter with has the exact length of 9 characters and that these characters consist only of 'rwxsStT-', the script will check both of that and abort if one of these checks fails

`./unix_file_permission_converter.sh rwxr-xr-`

`wrong character number of permission string`

`./unix_file_permission_converter.sh rwxr-xr-f`

`Illegal character in permission string`
