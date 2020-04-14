<html>
<center>
<body>

<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
include ('db.php');
if (!mysql_connect($host, $username, $password))
    die("Can't connect to database");

if (!mysql_select_db($db_name))
    die("Can't select database");
else
	echo "Online";
?>
<!--<p>
<p>

<form action="" method="post" >
	Username:<input type="text" name="username" required><p>
	Password:<input type="password" name="password" required><p>

	Server:
	<select name="servers" required>
	<option value="texas">Texas</option>
	<option value="california">California</option>
	</select>
	<p>
	Port:<input type="text" name="port" required><p>
	<input type="Submit" value="Submit" name="Submit">
	<br>
</form>
-->
<?php
if(isset($_POST['Submit']))  {
	$username = $_POST['username'];
        $finalusername = str_replace(' ','',$username); 
	$password = $_POST['password'];
	
	$server = $_POST['servers'];
	$port = $_POST['port'];
	
	
	if (!empty($username)){
		$sql = "SELECT * FROM radcheck WHERE username = '" . mysql_real_escape_string($username) . "' AND value = '" . mysql_real_escape_string($password) . "'";
		$result = mysql_query($sql) or die('error');
		$row = mysql_fetch_assoc($result);
		if(mysql_num_rows($result)) 
		{
			echo "Valid Account";
			echo $username;
			echo $password;
			echo $server;
			echo $port;
			echo "----";
			if ($server == "texas"){
				//echo file_get_contents('http://192.210.214.248/VPN/port.php?u='.$username.'&p='.$port);
			} 
			elseif ($server == "california"){
				//echo file_get_contents('http://192.210.215.129/VPN/port.php?u='.$username.'&p='.$port);
			}
		}
		else
			echo "Invalid login";
	}
	
	
	/*$fields_num = mysql_num_fields($result);
	echo "<table border='1'><tr>";
	for($i=0; $i<$fields_num; $i++)
	{
		$field = mysql_fetch_field($result);
		echo "<td><font color='111111'><strong>{$field->name}</strong></font></td>";
	}
	echo "</tr>\n";
	while($row = mysql_fetch_row($result))
	{
		echo "<tr>";
		foreach($row as $cell)
			echo "<td>$cell</td>";
		echo "</tr>\n";
	}*/
}
?>

</center>
</body>
</html>
  
