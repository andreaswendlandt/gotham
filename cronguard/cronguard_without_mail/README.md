# CRONGUARD
## cronguard_without_mail

#### as the name implies the difference to the "original one" is that the daemon does not send mails, instead it does write the failed ones and stuck ones to a logfile from which the results can be monitored with a logfile analyzer like logwatch in combination with a monitoring tool like check_mk

the name of the logfile is '/var/log/cronguard_error.log' and a typical entry would look like this:
```
ERROR, failed Cronjob on servername: "false"
```
