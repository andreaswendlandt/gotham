<?php
/* 
author: andreas wendlandt
desc: simple script to delete all jobs from a certain tube
last modified: 9.3.2019
*/

// composer pheanstalk
require 'vendor/autoload.php';
use Pheanstalk\Pheanstalk;

// include config file
require_once ("clean_tube.inc.php");

// check that the script is called by root
if (posix_getuid() != 0){
    exit("Error: this script must be run as root!\n");
}

// write logfile function
function write_log($content){
    $log_file = "/var/log/job_clean_tube.log";
    $log_time = date('M  j H:i:s');
    $log_handle = fopen($log_file, 'a') or die('Can not open:' .$log_file);
    $content = str_replace(array("\n", "\r"), '', $content);
    $log_content = "$log_time  $content\n";
    fwrite($log_handle, $log_content);
    fclose($log_handle);
}

// new pheanstalk object
$pheanstalk = new Pheanstalk($beanstalkd_ip);

// delete all jobs 
$pheanstalk->watch($tube);
while ($job = $pheanstalk->reserve(0)){
    $cmd = $job->getData(); 
    $pheanstalk->delete($job);
    write_log("$cmd deleted");
}
