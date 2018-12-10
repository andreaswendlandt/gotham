<?php
require_once ("db.inc.php");
if (isset($_POST['action'])) {
    $action = $_POST['action'];
}
else {
    die("Something went wrong with the data transmission\n");
}

if ($action == 'start') {
    if (isset($_POST['token']) && isset($_POST['host']) && isset($_POST['start_time']) && isset($_POST['command'])) {
        $token = $_POST['token'];
        $host = $_POST['host'];
        $start_time = $_POST['start_time'];
        $command = $_POST['command'];
    }
    else {  
        die("no data retrieved\n");
    }
    $sql = "INSERT INTO jobs (token, host, start_time, command, action)
    VALUES ('$token', '$host', '$start_time', '$command', '$action')";
}
elseif ($action == "finished") {
    if (isset($_POST['token']) && isset($_POST['end_time']) && isset($_POST['result'])) {
        $token = $_POST['token'];
        $end_time = $_POST['end_time'];
        $result = $_POST['result'];
    }
    else {
        die("no data retrieved\n");
    }
    $sql = "UPDATE jobs SET end_time='$end_time', action='$action', result='$result' WHERE token='$token'";
}
else {
    die("something messed up");
}

if ($conn->query($sql) === TRUE) {
    echo "New record created successfully";
} else {
    echo "Error: " . $sql . "<br>" . $conn->error;
}

$conn->close();
?>
