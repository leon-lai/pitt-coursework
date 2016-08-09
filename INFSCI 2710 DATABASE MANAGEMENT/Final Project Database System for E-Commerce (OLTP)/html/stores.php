<?php

/* 2015-04-13 Leon Lai <Leon.Lai@pitt.edu> */

require 'call_ro_procedure.php';

?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.1//EN" "http://www.w3.org/TR/xhtml-basic/xhtml-basic11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="Cache-Control" content="no-cache" />
<link rel="stylesheet" type="text/css" href="/style.css" />
<title>Stores | Digital Sales</title>
</head>
<body>
<div id="header" class="menu">
	<h1 class="logo"><a href="/">Digital Sales</a></h1>
	<ul class="nav">
		<li><a href="/products.php">PRODUCTS</a></li>
		<li><a href="/stores.php">STORES</a></li>
		<li><a href="/oltp.php">OLTP</a></li>
	</ul>
</div>
<div id="content">
	<table id="output">
		<tr><th>Name</th><th>Location</th><th>Telephone</th><th>Email</th><th>Hours</th></tr>
<?php

foreach(call_ro_procedure('list_for_public_stores', NULL) as $row)
{
	echo '		<tr><td>';
	echo $row['name'];
	echo '</td><td>';
	echo $row['address'];
	echo '</td><td>';
	echo $row['telephone'];
	echo '</td><td>';
	echo $row['email'];
	echo '</td><td>';
	echo 'Call or email.';
	echo '</td></tr>' . "\n";
}

?>
	</table>
</div>
<div id="footer" class="menu">
	<h1 class="logo"><a href="/">Digital Sales</a></h1>
	<ul class="nav">
		<li><a href="/products.php">PRODUCTS</a></li>
		<li><a href="/stores.php">STORES</a></li>
		<li><a href="/oltp.php">OLTP</a></li>
	</ul>
</div>
</body>
</html>
