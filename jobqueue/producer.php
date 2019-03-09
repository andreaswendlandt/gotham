<?php
/*
author: andreas wendlandt
desc: simple script to read jobs/tasks from a textfile (jobfile.txt)
desc: and put every one of them to a beanstalkd queue
last modified: 4.3.2019
*/

// composer pheanstalk
require 'vendor/autoload.php';
use Pheanstalk\Pheanstalk;

// include config file
require_once ("producer.inc.php");

// check that the script is called by root
if (posix_getuid() != 0){
    exit("Error: this script must be run as root!\n");
}

// write logfile function
function write_log($content){
    $log_file = "/var/log/job_producer.log";
    $log_time = date('M  j H:i:s');
    $log_handle = fopen($log_file, 'a') or die('Can not open:' .$log_file);
    $content = str_replace(array("\n", "\r"), '', $content);
    $log_content = "$log_time  $content\n";
    fwrite($log_handle, $log_content);
    fclose($log_handle);
}

// check that the jobfile is there and has content
if (file_exists($jobfile)){
    if(0 == filesize($jobfile)){
	write_log("jobfile $jobfile exists but is empty - aborting!");
	exit("ERROR - empty jobfile $jobfile!\n");
    }else{
        write_log("jobfile $jobfile exists and is not empty - proceeding");
    }
}else{
    write_log("jobfile $jobfile does not exist - aborting!");
    exit("ERROR - jobfile $jobfile does not exist\n");
}

// put job function
function put_job($job) {
    global $beanstalkd_ip;
    global $tube;
    $pheanstalk = new Pheanstalk($beanstalkd_ip);
    $pheanstalk
      ->useTube($tube)
      ->put("$job");
}

// check that the jobfile is readable and open it for reading
if ($job_file = @fopen("$jobfile", "r")){
    write_log("jobfile $jobfile opened for reading");
}else{
    write_log("Could not open jobfile $jobfile for reading");
    exit("ERROR: Could not open jobfile $jobfile, it seems the file is not readable!\n");
}

// read the jobfile and put all jobs into an array
$jobs = array();
while (($line = fgets($job_file)) !== false){
    array_push($jobs, $line);
}
fclose($job_file);

// put all jobs from the array to the queue
foreach ($jobs AS $job){
    put_job($job);
    write_log("job \"$job\" put to the queue");
}
