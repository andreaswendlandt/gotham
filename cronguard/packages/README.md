# cronguard packages - install all necessary components for running cronguard

## download and install cronguard-server
```
wget https://raw.githubusercontent.com/andreaswendlandt/gotham/master/cronguard/packages/cronguard-server_1.0-1.deb
dpkg -i cronguard-server_1.0-1.deb
```
- it copies the script cronguard.php and the file db.inc.php to /var/www/html

## download and install cronguard-wrapper
```
wget https://raw.githubusercontent.com/andreaswendlandt/gotham/master/cronguard/packages/cronguard-wrapper_1.0-1.deb
dpkg -i dpkg -i cronguard-wrapper_1.0-1.deb
```
- it copies the script cron_wrapper.sh and the file url.inc.sh to /opt/cronguard

## download and install cronguard-daemon
```
wget https://raw.githubusercontent.com/andreaswendlandt/gotham/master/cronguard/packages/cronguard-daemon_1.0-1.deb
dpkg -i dpkg -i cronguard-daemon_1.0-1.deb
```
- it copies the script cronguard.sh and the file mail.inc.sh to /opt/cronguard



