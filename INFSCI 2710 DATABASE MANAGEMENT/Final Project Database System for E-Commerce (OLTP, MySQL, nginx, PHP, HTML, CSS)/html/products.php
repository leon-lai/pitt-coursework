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
<title>Products | Digital Sales</title>
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
<?php

// https://php.net/manual/en/types.comparisons.php

if (isset($_GET['search']) && $_GET['search'] !== '') // search mode
{
	echo '	<table id="output">' . "\n";
	echo '		<tr><th>Description</th><th>Product category</th><th>Price</th><th>Remarks</th></tr>' . "\n";
	foreach(call_ro_procedure('find_for_public_products', array($_GET['search'])) as $row)
	{
		echo '		<tr><td>';
		echo $row['description'];
		echo '</td><td>';
		echo $row['product_category'];
		echo '</td><td>';
		echo '$' . $row['price'];
		echo '</td><td>';
		echo $row['remarks'];
		echo '</td></tr>' . "\n";
	}
	echo '	</table>' . "\n";
}
elseif (isset($_GET['browse']) && $_GET['browse'] !== '') // browse-by-category mode
{
	echo '	<table id="output">' . "\n";
	echo '		<tr><th>Description</th><th>Price</th><th>Remarks</th></tr>' . "\n";
	foreach(call_ro_procedure('list_for_public_products_in_category', array($_GET['browse'])) as $row)
	{
		echo '		<tr><td>';
		echo $row['description'];
		echo '</td><td>';
		echo '$' . $row['price'];
		echo '</td><td>';
		echo $row['remarks'];
		echo '</td></tr>' . "\n";
	}
	echo '	</table>' . "\n";
}
elseif (isset($_GET['browse'])) // browse-all mode
{
	echo '	<table id="output">' . "\n";
	echo '		<tr><th>Description</th><th>Product category</th><th>Price</th><th>Remarks</th></tr>' . "\n";
	foreach(call_ro_procedure('list_for_public_products', NULL) as $row)
	{
		echo '		<tr><td>';
		echo $row['description'];
		echo '</td><td>';
		echo $row['product_category'];
		echo '</td><td>';
		echo '$' . $row['price'];
		echo '</td><td>';
		echo $row['remarks'];
		echo '</td></tr>' . "\n";
	}
	echo '	</table>' . "\n";
}
else // no-input mode
{
}

?>
	<div id="input">
		<form action="" method="get">
			<div>
				<input type="text" name="search" placeholder="search" />
				<input type="submit" />
			</div>
		</form>
		Browse by product category:
<?php

foreach(call_ro_procedure('list_product_categories', NULL) as $row)
{
	$product_category = $row['product_category'];
	echo '		<a href="?browse=' . $product_category . '">' . $product_category . '</a>' . "\n";
}

?>
		<a href="?browse">ALL</a>
	</div>
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
