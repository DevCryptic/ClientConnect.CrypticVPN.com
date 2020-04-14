<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
include ('db.php');
if (!mysql_connect($host, $username, $password))
    die("Can't connect to database");

if (!mysql_select_db($db_name))
    die("Can't select database");

$sql = "SELECT * FROM radversion ORDER BY id DESC LIMIT 1";
	$result = mysql_query($sql) or die('error');
	while ($row = mysql_fetch_assoc($result)) {
		echo $row["version"] . "|" . $row["download"];
	}
mysql_free_result($result);
?>