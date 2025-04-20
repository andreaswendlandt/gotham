# cronguard packages - install all necessary components for running cronguard

## download and install cronguard-server
```
wget https://raw.githubusercontent.com/andreaswendlandt/gotham/master/cronguard/packages/cronguard-server_1.0-1.deb
dpkg -i cronguard-server_1.0-1.deb
```
- it copies the script cronguard.php and the file db.inc.php to /var/www/html
- it creates the database cronguard, the mysql user cronguard and the table jobs

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


### build the packages on your own

ensure that the package directory is there with all the relevant files/folders in it(for example cronguard-daemon_1.0-1)

**note**
within the package directory must be a folder named DEBIAN where all the files are located that store meta information,
such as debian-binary or control

then run the command:
```
dpkg-deb --build cronguard-daemon_1.0-1/
```
after that a debian package `cronguard-daemon_1.0-1.deb` was created

