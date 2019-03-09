<?php
/* 
author: andreas wendlandt
desc: simple script to check if jobs are in a given beanstalkd queue and process them
desc: in case there are none or all jobs are processed quit
last modified: 4.3.2019
*/

// composer pheanstalk
require 'vendor/autoload.php';
use Pheanstalk\Pheanstalk;

// include config file
require_once ("consumer.inc.php");

// check that the script is called by root
if (posix_getuid() != 0){
    exit("Error: this script must be run as root!\n");
}

// write logfile function
function write_log($content){
    $log_file = "/var/log/job_consumer.log";
    $log_time = date('M  j H:i:s');
    $log_handle = fopen($log_file, 'a') or die('Can not open:' .$log_file);
    $content = str_replace(array("\n", "\r"), '', $content);
    $log_content = "$log_time  $content\n";
    fwrite($log_handle, $log_content);
    fclose($log_handle);
}

// new pheanstalk object
$pheanstalk = new Pheanstalk($beanstalkd_ip);

// observe the given tube and process all containing jobs 
$pheanstalk->watch($tube);
while ($job = $pheanstalk->reserve(0)){
    $cmd = $job->getData(); 
    exec($cmd, $output, $return);
    if ($return != 0) {
        write_log("$cmd could not be processed");
        echo "$job could not be processed";
    } else {
        write_log("$cmd succesfully processed");
        $user_output = implode("\n",$output);
        echo "$user_output\n";
        unset($output);
    }
    $pheanstalk->delete($job);
}
