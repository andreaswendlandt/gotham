## my_lib
# what it is

the idea behind my_lib is to have a 'library' - a collection of functions - that you include in your shellscripts to have
some basic functions, functions like checking if a variable is empty, or is an integer, contains only letters, 
a logging function and so on and so on
instead of writing them always again just include my_lib the usual way (with the source or the dot command) and everything
is in place

# what it is not
complete - no seriously, it is far from being complete, my_lib will be constantly updated which means whenever i come across
something useful i will add it but in case you have any suggestions - please contact me and let me know!

# how do i use it
download and save my_lib on your machine to a location that makes sense for a library, /usr/lib for instance
to download it you can use wget:
`sudo wget https://raw.githubusercontent.com/andreaswendlandt/gotham/master/my_lib/my_lib-P /usr/lib/`

once the library is on your system include in in your shellscripts
`. /usr/lib/my_lib`
or
`source /usr/lib/my_lib`


# what functions are already there and what is their purpose
* is_int() - checking if a variable is an integer one

  example `var=1234; is_int $var; echo $?`
   
  `0`

  but `var=1234f; is_int $var; echo $?`

  `1`

* is_alpha() - checking if a variable consists only of letters
 
  example `var=abcd; is_alpha $var; echo $?`
  
  `0`
  
  but `var=abc1; is_alpha $var; echo $?`
   
  `1`

* is_empty() - checking if a variable is empty
  
  example `var=""; is_empty $var; echo $?`
  
  `0`
 
   
   but `var="foo"; is_empty $var; echo $?`
  
   `1`
   
* has_specialchars() - checks if a variable contains specialchars
  
  example `var="foo%"; has_specialchars $var; echo $?`
  
  `0`

   but `var="foo"; has_specialchars $var; echo $?`

  `1`
  
* started_as_root() - checks if the script was started with root privileges
   
  example `if started_as_root(); then echo "started as root"; else echo "this script needs root privileges"; fi`

* my_log() - logs whatever this function is given to to /tmp/name_of_the_script.sh.log
  
  example 
  
   imagine you have a script called test.sh, within that script you call `my_log "script successfully finished"`
  
   this will result in /tmp/test.sh.log `Sa 13. Jun 23:34:03 CEST 2020 script successfully finished`
   
* my_flock() - ensures that only one instance of your script is running, any other try to start it while another one
  is running will abort with this error message `ERROR, another instance of $(basename $0) is already running - aborting!!!`
 
* config_grep() - help function for grepping in files, what if you grep in a file for a search pattern (usually in an 
  if statement) you get a match and the line of the match is outcommented, can it be that the logic of your if statement is     inverted? you can avoid that behaviour with using config_grep(), it has 3 possible return values, "no occurence" - your       search pattern does not exist in the file your are grepping in "outcommented" - the search pattern does exist in the file     you are grepping in but the line is outcommented and "match" - your search pattern does exist in the file you are grepping   in and the line where it appears does not start with either a "#" or a ";" usage: `config_grep <file> <search_pattern>`
  
* is_version() - checks if a variable consists only of numbers and dots(just like most version strings are)

  example `var="1.2.3.4"; is_version $var; echo $?`

  `0`
  
  but `var="1.2.3.4foo"; is_version $var; echo $?`
  
  `1`

* is_ipv4() - checks if a variable is a valid ipv4 address

  example `var="192.168.2.1"; is_ipv4 $var; echo $?`
  
  `0`
  
  but `var="192.168.2.256"; is_ipv4 $var; echo $?`
  
  `1`

* is_float() - checking if a variable is a float one

  example `var=1.2; is_float $var; echo $?`

  `0`

  but `var=1,2; is_float $var; echo $?`

  `1`

* has_lower_letter() - checking for lower letters in a string

  example `var=aH53K; has_lower_letter $var; echo $?`

 `0`

  but `var=AH53K; has_lower_letter $var; echo $?`

 `1`

* has_upper_letter() - checking for upper letters in a string

  example `var=Ah53k; has_upper_letter $var; echo $?`

  `0`

  but `var=ah53k; has_upper_letter $var; echo $?`

  `1`

* has_int() - checking for integers in a string

  example - `var=ah53k; has_int $var; echo $?`

  `0`

  but `var=ahebk; has_int $var; echo $?`

  `1`
