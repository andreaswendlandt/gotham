<?php
require_once ("db.inc.php");

function api() {
    global $conn;
    $sql = "SELECT * FROM job_foo";
    $result = $conn->query($sql);
    if ($result->num_rows > 0) {
        $cronjobs = array();
        while($row = $result->fetch_assoc()) {
            $cronjobs[] = $row;
        } 
    header('Content-Type: application/json');
    echo json_encode($cronjobs, JSON_PRETTY_PRINT);
    }
    else {
        echo "0 results";
    }
    exit();
}

if (isset ($_GET['method'])) {
    $method = $_GET['method'];
    if ("$method" == "api") {
        api();
    }
    else {
        echo "Invalid Argument ($method), use api<br>";
	exit();
    }
}

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
    $stmt = $conn->prepare("INSERT INTO job_foo (token, host, start_time, command, action)
    VALUES (?, ?, ?, ?, ?)");
    $stmt->bind_param("ssiss", $token, $host, $start_time, $command, $action);
    if ($stmt->execute() === TRUE){
        echo "New record created successfully";
    }
    else {
        echo "Error with creating a new record";
    }
    $stmt->close();
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
    $stmt = $conn->prepare("UPDATE job_foo SET end_time = ?, action = ?, result = ? WHERE token = ?");
    $stmt->bind_param("isss", $end_time, $action, $result, $token);
    if ($stmt->execute() === TRUE){
        echo "Record updated successfully";
    }
    else {
        echo "Error with updating the record";
    }
    $stmt->close();
}
else {
    die("something messed up");
}

$conn->close();
?>
