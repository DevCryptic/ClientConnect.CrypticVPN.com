<?php
include ('db.php');
if (!mysql_connect($host, $username, $password))
    die("Can't connect to database");

if (!mysql_select_db($db_name))
    die("Can't select database");

$function =  mysql_real_escape_string($_GET["f"]);

switch ($function) {

case "login";
		$User = mysql_real_escape_string($_GET["u"]);
		$Pass = mysql_real_escape_string($_GET["p"]);
		$sql = "SELECT * FROM radcheck WHERE username = '". $User ."' AND value = '" . $Pass . "'";
		$result = mysql_query($sql) or die('error');
		if(mysql_num_rows($result)>=1){
			echo "vaild";
		} else {
			echo "Nope";
		}
		mysql_free_result($result);
		break;
		
case "updateV";
		$sql = "SELECT * FROM radserverversion";
		$result = mysql_query($sql);
		 echo mysql_num_rows($result);
		break;
		
case "update";
	$sql = "SELECT * FROM radservers WHERE ENABLE = 1 ORDER BY NAME ASC";	
	$result = mysql_query($sql);
	while ($row = mysql_fetch_assoc($result)) {
		echo $row["NAME"] . "|" . $row["FILE"] . "|" . $row["IP"]. "|" . $row["AUTH"] . "@";
	}	
	break;

case "port";
		echo "You can open ports from CrypticVPN.com. We will add this feature to the client in the near future.";
		break;
		
case "chgpass";
	echo "Please change your password by visiting CrypticVPN.com. This feature will be added to the client in the near future";
	break;
}
	
	
	
/*	$sql = "SELECT * FROM radversion ORDER BY id DESC LIMIT 1";
$result = mysql_query($sql) or die('error');
while ($row = mysql_fetch_assoc($result)) {
	echo $row["version"] . "|" . $row["download"];
}*/
		

?>

