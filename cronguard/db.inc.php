<?php
// Connecting to the database with the following credentials("host","user","password","database")
$conn = @(new mysqli("localhost", "cronguard", "superstrong_and_secure_password", "cronguard"));
if ($conn->connect_error) {
  echo "Error while connecting: " . mysqli_connect_error();
  exit();
}
?>
