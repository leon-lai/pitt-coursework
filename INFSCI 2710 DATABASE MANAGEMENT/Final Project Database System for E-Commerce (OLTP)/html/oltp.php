<?php

/* 2015-04-18 Leon Lai <Leon.Lai@pitt.edu> */

require 'call_ro_procedure.php';
require 'call_rw_procedure.php';
require 'insert_transaction_group.php';

$business_categories = call_ro_procedure('list_business_categories', NULL);
$marriage_statuses   = call_ro_procedure('list_marriage_statuses'  , NULL);
$genders             = call_ro_procedure('list_genders'            , NULL);
$regions             = call_ro_procedure('list_regions'            , NULL);
$stores              = call_ro_procedure('list_stores'             , NULL);
$product_categories  = call_ro_procedure('list_product_categories' , NULL);
$products            = call_ro_procedure('list_products'           , NULL);

?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.1//EN" "http://www.w3.org/TR/xhtml-basic/xhtml-basic11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="Cache-Control" content="no-cache" />
<link rel="stylesheet" type="text/css" href="/style.css" />
<title>OLTP | Digital Sales</title>
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
	<div id="output">
<?php

function ifset_POST($key)
{
	return isset($_POST[$key]) ? $_POST[$key] : NULL;
}

function iffilled_POST($key)
{
	return (isset($_POST[$key]) && $_POST[$key] !== '') ? $_POST[$key] : NULL;
}

if (array_key_exists('task', $_POST))
{
	$task = $_POST['task'];
	switch ($task)
	{
		case 'find_customers':
			if ($_POST['search'] === '')
			{
				break;
			}
			$results = call_ro_procedure($task, array($_POST['search']));
			if ($results === FALSE)
			{
				break;
			}
			echo '		<table>' . "\n";
			echo '			<tr><th>Customer#</th><th>First name</th><th>Last name</th><th>Address</th><th>Telephone</th><th>Email</th><th>Annual income</th><th>Is corporation?</th><th>Other attributes</th></tr>' . "\n";
			foreach ($results as $row)
			{
				echo "\t\t\t";
				echo '<tr><td>';
				echo $row['ID'];
				echo '</td><td>';
				echo $row['first_name'];
				echo '</td><td>';
				echo $row['last_name'];
				echo '</td><td>';
				echo $row['address'];
				echo '</td><td>';
				echo $row['telephone'];
				echo '</td><td>';
				echo $row['email'];
				echo '</td><td>';
				echo $row['annual_income'];
				echo '</td><td>';
				echo $row['is_corporation'] ? 'Yes' : 'No';
				echo '</td><td>';
				echo $row['other_attributes'];
				echo '</td></tr>';
				echo "\n";
			}
			echo '		</table>' . "\n";
			break;
		case 'find_employees':
			if ($_POST['search'] === '')
			{
				break;
			}
			$results = call_ro_procedure($task, array($_POST['search']));
			if ($results === FALSE)
			{
				break;
			}
			echo '		<table>' . "\n";
			echo '			<tr><th>Employee#</th><th>First name</th><th>Last name</th><th>Address</th><th>Telephone</th><th>Email</th><th>Annual salary</th><th>Employee type</th><th>Other attributes</th></tr>' . "\n";
			foreach ($results as $row)
			{
				echo "\t\t\t";
				echo '<tr><td>';
				echo $row['ID'];
				echo '</td><td>';
				echo $row['first_name'];
				echo '</td><td>';
				echo $row['last_name'];
				echo '</td><td>';
				echo $row['address'];
				echo '</td><td>';
				echo $row['telephone'];
				echo '</td><td>';
				echo $row['email'];
				echo '</td><td>';
				echo $row['annual_salary'];
				echo '</td><td>';
				echo $row['employee_type'];
				echo '</td><td>';
				echo $row['other_attributes'];
				echo '</td></tr>';
				echo "\n";
			}
			echo '		</table>' . "\n";
			break;
		case 'insert_transaction_group':
			$results = insert_transaction_group($_POST);
			if ($results)
			{
				echo 'Successful; Customer#' . $_POST['customer'] . ' paid $' . $results[1][0]['amount_paid'] . ' for Transaction_group#' . $results[0][0]['transaction_group_ID'] . '.' . "\n";
			}
			else
			{
				echo 'Failed to add this customer.' . "\n";
			}
			break;
		case 'insert_customer':
			$results = call_rw_procedure($task, array
				( iffilled_POST('first_name')
				, iffilled_POST('last_name')
				, iffilled_POST('street_po_box')
				, iffilled_POST('city')
				, iffilled_POST('state')
				, iffilled_POST('ZIP_Code')
				, iffilled_POST('telephone')
				, iffilled_POST('email')
				, iffilled_POST('annual_income')
				, iffilled_POST('is_corporation')
				, iffilled_POST('business_category')
				, ifset_POST('marriage_status')
				, ifset_POST('gender')
				, iffilled_POST('birth_date')
				)
			);
			if ($results)
			{
				echo 'Successful; this new customer is Customer#' . $results[0]['O'] . '.' . "\n";
			}
			else
			{
				echo 'Failed to add this customer.' . "\n";
			}
			break;
		case 'insert_salesperson':
			$results = call_rw_procedure($task, array
				( iffilled_POST('first_name')
				, iffilled_POST('last_name')
				, iffilled_POST('street_po_box')
				, iffilled_POST('city')
				, iffilled_POST('state')
				, iffilled_POST('ZIP_Code')
				, iffilled_POST('telephone')
				, iffilled_POST('annual_salary')
				, iffilled_POST('store_ID')
				, iffilled_POST('job_title')
				)
			);
			if ($results)
			{
				echo 'Successful; this new salesperson is Employee#' . $results[0]['O'] . '.' . "\n";
			}
			else
			{
				echo 'Failed to add this salesperson.' . "\n";
			}
			break;
		case 'update_store_manager':
			$results = call_rw_procedure($task, array
				( iffilled_POST('store_ID')
				, iffilled_POST('employee_ID')
				)
			);
			if ($results)
			{
				echo 'Successful; manager of Store#' . $_POST['store_ID'] . ' changed from Employee#' . $results[0]['O'] . ' to Employee#' . $_POST['employee_ID'] . '.' . "\n";
			}
			else
			{
				echo 'Failed to change manager of Store#' . $_POST['store_ID'] . '.' . "\n";
			}
			break;
		case 'update_region_manager':
			$results = call_rw_procedure($task, array
				( iffilled_POST('region_ID')
				, iffilled_POST('employee_ID')
				)
			);
			if ($results)
			{
				echo 'Successful; manager of Region#' . $_POST['region_ID'] . ' changed from Employee#' . $results[0]['O'] . ' to Employee#' . $_POST['employee_ID'] . '.' . "\n";
			}
			else
			{
				echo 'Failed to change manager of Region#' . $_POST['region_ID'] . '.' . "\n";
			}
			break;
		case 'insert_product':
			$results = call_rw_procedure($task, array
				( iffilled_POST('name')
				, iffilled_POST('size_magnitude')
				, iffilled_POST('size_unit')
				, iffilled_POST('price')
				, iffilled_POST('product_category')
				)
			);
			if ($results)
			{
				echo 'Successful; this new product is Product#' . $results[0]['O'] . '.' . "\n";
			}
			else
			{
				echo 'Failed to add this product.' . "\n";
			}
			break;
		case 'increment_product_inventory_amount':
			$results = call_rw_procedure($task, array
				( iffilled_POST('ID')
				, iffilled_POST('inventory_amount_increment')
				)
			);
			if ($results)
			{
				echo 'Successful; product#' . $_POST['ID'] . '\'s new inventory amount is ' . $results[0]['O'] . '.' . "\n";
			}
			else
			{
				echo 'Failed to stock product#' . $_POST['ID'] . "\n";
			}
			break;
		case 'show_aggregate_sales_by_product':
			$results = call_ro_procedure($task, NULL);
			if ($results === FALSE)
			{
				break;
			}
			echo "\t\t" . '<table>' . "\n";
			echo "\t\t\t";
			echo '<tr><th>';
			echo 'Product#';
			echo '</th><th>';
			echo 'Description';
			echo '</th><th>';
			echo 'Product category';
			echo '</th><th>';
			echo 'Aggregated sales';
			echo '</th></tr>';
			echo "\n";
			foreach ($results as $row)
			{
				echo "\t\t\t";
				echo '<tr><td>';
				echo $row['product'];
				echo '</td><td>';
				echo $row['description'];
				echo '</td><td>';
				echo $row['product_category'];
				echo '</td><td>';
				echo $row['product_quantity'];
				echo '</td></tr>';
				echo "\n";
			}
			echo "\t\t" . '</table>' . "\n";
			break;
		case 'show_aggregate_revenue_by_product':
			$results = call_ro_procedure($task, NULL);
			if ($results === FALSE)
			{
				break;
			}
			echo "\t\t" . '<table>' . "\n";
			echo "\t\t\t";
			echo '<tr><th>';
			echo 'Product#';
			echo '</th><th>';
			echo 'Description';
			echo '</th><th>';
			echo 'Product category';
			echo '</th><th>';
			echo 'Aggregated revenue';
			echo '</th></tr>';
			echo "\n";
			foreach ($results as $row)
			{
				echo "\t\t\t";
				echo '<tr><td>';
				echo $row['product'];
				echo '</td><td>';
				echo $row['description'];
				echo '</td><td>';
				echo $row['product_category'];
				echo '</td><td>';
				echo '$' . $row['amount_paid'];
				echo '</td></tr>';
				echo "\n";
			}
			echo "\t\t" . '</table>' . "\n";
			break;
		case 'show_aggregate_sales_by_product_category':
			$results = call_ro_procedure($task, NULL);
			if ($results === FALSE)
			{
				break;
			}
			echo "\t\t" . '<table>' . "\n";
			echo "\t\t\t";
			echo '<tr><th>';
			echo 'Product category';
			echo '</th><th>';
			echo 'Aggregated sales';
			echo '</th></tr>';
			echo "\n";
			foreach ($results as $row)
			{
				echo "\t\t\t";
				echo '<tr><td>';
				echo $row['product_category'];
				echo '</td><td>';
				echo $row['product_quantity'];
				echo '</td></tr>';
				echo "\n";
			}
			echo "\t\t" . '</table>' . "\n";
			break;
		case 'show_aggregate_revenue_by_product_category':
			$results = call_ro_procedure($task, NULL);
			if ($results === FALSE)
			{
				break;
			}
			echo "\t\t" . '<table>' . "\n";
			echo "\t\t\t";
			echo '<tr><th>';
			echo 'Product category';
			echo '</th><th>';
			echo 'Aggregated revenue';
			echo '</th></tr>';
			echo "\n";
			foreach ($results as $row)
			{
				echo "\t\t\t";
				echo '<tr><td>';
				echo $row['product_category'];
				echo '</td><td>';
				echo '$' . $row['amount_paid'];
				echo '</td></tr>';
				echo "\n";
			}
			echo "\t\t" . '</table>' . "\n";
			break;
		case 'show_aggregate_sales_by_store':
			$results = call_ro_procedure($task, NULL);
			if ($results === FALSE)
			{
				break;
			}
			echo "\t\t" . '<table>' . "\n";
			echo "\t\t\t";
			echo '<tr><th>';
			echo 'Store#';
			echo '</th><th>';
			echo 'Address';
			echo '</th><th>';
			echo 'Region#';
			echo '</th><th>';
			echo 'Region name';
			echo '</th><th>';
			echo 'Aggregated sales';
			echo '</th></tr>';
			echo "\n";
			foreach ($results as $row)
			{
				echo "\t\t\t";
				echo '<tr><td>';
				echo $row['store'];
				echo '</td><td>';
				echo $row['address'];
				echo '</td><td>';
				echo $row['region'];
				echo '</td><td>';
				echo $row['region_name'];
				echo '</td><td>';
				echo $row['product_quantity'];
				echo '</td></tr>';
				echo "\n";
			}
			echo "\t\t" . '</table>' . "\n";
			break;
		case 'show_aggregate_revenue_by_store':
			$results = call_ro_procedure($task, NULL);
			if ($results === FALSE)
			{
				break;
			}
			echo "\t\t" . '<table>' . "\n";
			echo "\t\t\t";
			echo '<tr><th>';
			echo 'Store#';
			echo '</th><th>';
			echo 'Address';
			echo '</th><th>';
			echo 'Region#';
			echo '</th><th>';
			echo 'Region name';
			echo '</th><th>';
			echo 'Aggregated revenue';
			echo '</th></tr>';
			echo "\n";
			foreach ($results as $row)
			{
				echo "\t\t\t";
				echo '<tr><td>';
				echo $row['store'];
				echo '</td><td>';
				echo $row['address'];
				echo '</td><td>';
				echo $row['region'];
				echo '</td><td>';
				echo $row['region_name'];
				echo '</td><td>';
				echo '$' . $row['amount_paid'];
				echo '</td></tr>';
				echo "\n";
			}
			echo "\t\t" . '</table>' . "\n";
			break;
		case 'show_aggregate_sales_by_region':
			$results = call_ro_procedure($task, NULL);
			if ($results === FALSE)
			{
				break;
			}
			echo "\t\t" . '<table>' . "\n";
			echo "\t\t\t";
			echo '<tr><th>';
			echo 'Region#';
			echo '</th><th>';
			echo 'Name';
			echo '</th><th>';
			echo 'Aggregated sales';
			echo '</th></tr>';
			echo "\n";
			foreach ($results as $row)
			{
				echo "\t\t\t";
				echo '<tr><td>';
				echo $row['region'];
				echo '</td><td>';
				echo $row['name'];
				echo '</td><td>';
				echo $row['product_quantity'];
				echo '</td></tr>';
				echo "\n";
			}
			echo "\t\t" . '</table>' . "\n";
			break;
		case 'show_aggregate_revenue_by_region':
			$results = call_ro_procedure($task, NULL);
			if ($results === FALSE)
			{
				break;
			}
			echo "\t\t" . '<table>' . "\n";
			echo "\t\t\t";
			echo '<tr><th>';
			echo 'Region#';
			echo '</th><th>';
			echo 'Name';
			echo '</th><th>';
			echo 'Aggregated revenue';
			echo '</th></tr>';
			echo "\n";
			foreach ($results as $row)
			{
				echo "\t\t\t";
				echo '<tr><td>';
				echo $row['region'];
				echo '</td><td>';
				echo $row['name'];
				echo '</td><td>';
				echo '$' . $row['amount_paid'];
				echo '</td></tr>';
				echo "\n";
			}
			echo "\t\t" . '</table>' . "\n";
			break;
		case 'show_aggregate_sales_by_home_customer_marriage_status':
			$results = call_ro_procedure($task, NULL);
			if ($results === FALSE)
			{
				break;
			}
			echo "\t\t" . '<table>' . "\n";
			echo "\t\t\t";
			echo '<tr><th>';
			echo 'Home customer marriage status';
			echo '</th><th>';
			echo 'Aggregated sales';
			echo '</th></tr>';
			echo "\n";
			foreach ($results as $row)
			{
				echo "\t\t\t";
				echo '<tr><td>';
				echo $row['marriage_status'];
				echo '</td><td>';
				echo $row['product_quantity'];
				echo '</td></tr>';
				echo "\n";
			}
			echo "\t\t" . '</table>' . "\n";
			break;
		case 'show_aggregate_revenue_by_home_customer_marriage_status':
			$results = call_ro_procedure($task, NULL);
			if ($results === FALSE)
			{
				break;
			}
			echo "\t\t" . '<table>' . "\n";
			echo "\t\t\t";
			echo '<tr><th>';
			echo 'Home customer marriage status';
			echo '</th><th>';
			echo 'Aggregated revenue';
			echo '</th></tr>';
			echo "\n";
			foreach ($results as $row)
			{
				echo "\t\t\t";
				echo '<tr><td>';
				echo $row['marriage_status'];
				echo '</td><td>';
				echo '$' . $row['amount_paid'];
				echo '</td></tr>';
				echo "\n";
			}
			echo "\t\t" . '</table>' . "\n";
			break;
		case 'show_aggregate_sales_by_home_customer_gender':
			$results = call_ro_procedure($task, NULL);
			if ($results === FALSE)
			{
				break;
			}
			echo "\t\t" . '<table>' . "\n";
			echo "\t\t\t";
			echo '<tr><th>';
			echo 'Home customer gender';
			echo '</th><th>';
			echo 'Aggregated sales';
			echo '</th></tr>';
			echo "\n";
			foreach ($results as $row)
			{
				echo "\t\t\t";
				echo '<tr><td>';
				echo $row['gender'];
				echo '</td><td>';
				echo $row['product_quantity'];
				echo '</td></tr>';
				echo "\n";
			}
			echo "\t\t" . '</table>' . "\n";
			break;
		case 'show_aggregate_revenue_by_home_customer_gender':
			$results = call_ro_procedure($task, NULL);
			if ($results === FALSE)
			{
				break;
			}
			echo "\t\t" . '<table>' . "\n";
			echo "\t\t\t";
			echo '<tr><th>';
			echo 'Home customer gender';
			echo '</th><th>';
			echo 'Aggregated revenue';
			echo '</th></tr>';
			echo "\n";
			foreach ($results as $row)
			{
				echo "\t\t\t";
				echo '<tr><td>';
				echo $row['gender'];
				echo '</td><td>';
				echo '$' . $row['amount_paid'];
				echo '</td></tr>';
				echo "\n";
			}
			echo "\t\t" . '</table>' . "\n";
			break;
		case 'show_aggregate_sales_by_business_customer_business_category':
			$results = call_ro_procedure($task, NULL);
			if ($results === FALSE)
			{
				break;
			}
			echo "\t\t" . '<table>' . "\n";
			echo "\t\t\t";
			echo '<tr><th>';
			echo 'Business customer business category';
			echo '</th><th>';
			echo 'Aggregated sales';
			echo '</th></tr>';
			echo "\n";
			foreach ($results as $row)
			{
				echo "\t\t\t";
				echo '<tr><td>';
				echo $row['business_category'];
				echo '</td><td>';
				echo $row['product_quantity'];
				echo '</td></tr>';
				echo "\n";
			}
			echo "\t\t" . '</table>' . "\n";
			break;
		case 'show_aggregate_revenue_by_business_customer_business_category':
			$results = call_ro_procedure($task, NULL);
			if ($results === FALSE)
			{
				break;
			}
			echo "\t\t" . '<table>' . "\n";
			echo "\t\t\t";
			echo '<tr><th>';
			echo 'Business customer business category';
			echo '</th><th>';
			echo 'Aggregated revenue';
			echo '</th></tr>';
			echo "\n";
			foreach ($results as $row)
			{
				echo "\t\t\t";
				echo '<tr><td>';
				echo $row['business_category'];
				echo '</td><td>';
				echo '$' . $row['amount_paid'];
				echo '</td></tr>';
				echo "\n";
			}
			echo "\t\t" . '</table>' . "\n";
			break;
		case 'show_aggregate_available_positions_by_store':
			$results = call_ro_procedure($task, NULL);
			if ($results === FALSE)
			{
				break;
			}
			echo "\t\t" . '<table>' . "\n";
			echo "\t\t\t";
			echo '<tr><th>';
			echo 'Store#';
			echo '</th><th>';
			echo 'Address';
			echo '</th><th>';
			echo 'Region#';
			echo '</th><th>';
			echo 'Region name';
			echo '</th><th>';
			echo 'Available positions';
			echo '</th></tr>';
			echo "\n";
			foreach ($results as $row)
			{
				echo "\t\t\t";
				echo '<tr><td>';
				echo $row['store'];
				echo '</td><td>';
				echo $row['address'];
				echo '</td><td>';
				echo $row['region'];
				echo '</td><td>';
				echo $row['region_name'];
				echo '</td><td>';
				echo $row['available_positions'];
				echo '</td></tr>';
				echo "\n";
			}
			echo "\t\t" . '</table>' . "\n";
			break;
	}
}

?>
	</div>
	<form action="" method="post">
		<fieldset>
			<legend>FIND CUSTOMERS</legend>
			<input type="text" name="search" placeholder="search" />
			<button name="task" value="find_customers" type="submit">Find customers</button>
		</fieldset>
	</form>
	<form action="" method="post">
		<fieldset>
			<legend>FIND EMPLOYEES</legend>
			<input type="text" name="search" placeholder="search" />
			<button name="task" value="find_employees" type="submit">Find employees</button>
		</fieldset>
	</form>
	<form action="" method="post">
		<fieldset>
			<legend>MAKE PURCHASE</legend>
			<table>
				<tr>
					<td>Employee#</td>
					<td><input name="salesperson" type="number" /></td>
				</tr>
				<tr>
					<td>Customer#</td>
					<td><input name="customer" type="number" /></td>
				</tr>
			</table>
			<table>
				<tr><th>ID</th><th>Description</th><th>Product category</th><th>Price</th><th>Inventory amount</th><th>Quantity</th></tr>
<?php

foreach($products as $row)
{
	$ID = $row['ID'];
	echo "\t\t\t\t" . '<tr><td>';
	echo $ID;
	echo '</td><td>';
	echo $row['description'];
	echo '</td><td>';
	echo $row['product_category'];
	echo '</td><td>';
	echo '$' . $row['price'];
	echo '</td><td>';
	echo $row['inventory_amount'];
	echo '</td><td>';
	echo '<input name="product_' . $ID . '" type="number" />';
	echo '</td></tr>' . "\n";
}

?>
			</table>
			<button name="task" value="insert_transaction_group" type="submit">Submit</button>
		</fieldset>
	</form>
	<form action="" method="post">
		<fieldset>
			<legend>ADD CUSTOMER</legend>
			<table>
				<tr>
					<td>First name: </td>
					<td><input name="first_name" type="text" /></td>
				</tr>
				<tr>
					<td>Last name: </td>
					<td><input name="last_name" type="text" /></td>
				</tr>
				<tr>
					<td>Street / PO Box: </td>
					<td><input name="street_po_box" type="text" /></td>
				</tr>
				<tr>
					<td>City: </td>
					<td><input name="city" type="text" /></td>
				</tr>
				<tr>
					<td>State (two letter): </td>
					<td><input name="state" type="text" maxlength="5" /></td>
				</tr>
				<tr>
					<td>ZIP Code: </td>
					<td><input name="ZIP_Code" type="number" maxlength="5" /></td>
				</tr>
				<tr>
					<td>Telephone: </td>
					<td><input name="telephone" type="number" maxlength="10" /></td>
				</tr>
				<tr>
					<td>Email: </td>
					<td><input name="email" type="text" /></td>
				</tr>
				<tr>
					<td>Annual income: </td>
					<td><input name="annual_income" type="number" /></td>
				</tr>
				<tr>
					<td>Is corporation? </td>
					<td>
						<input name="is_corporation" type="radio" value="0" />No
						<input name="is_corporation" type="radio" value="1" />Yes
					</td>
				</tr>
				<tr>
					<th colspan="2">If is not corporation…</th>
				</tr>
				<tr>
					<td>Marriage status</td>
					<td>
						<select name="marriage_status">
<?php

foreach($marriage_statuses as $row)
{
	$marriage_status = $row['marriage_status'];
	echo "\t\t\t\t\t\t\t" . '<option value="' . $marriage_status . '">' . $marriage_status . '</option>' . "\n";
}

?>
						</select>
					</td>
				</tr>
				<tr>
					<td>Gender</td>
					<td>
						<select name="gender">
<?php

foreach($genders as $row)
{
	$gender = $row['gender'];
	echo "\t\t\t\t\t\t\t" . '<option value="' . $gender . '">' . $gender . '</option>' . "\n";
}

?>
						</select>
					</td>
				</tr>
				<tr>
					<td>Birth date</td>
					<td>
						<input name="birth_date" type="date" />
					</td>
				</tr>
				<tr>
					<th colspan="2">If is corporation…</th>
				</tr>
				<tr>
					<td>Business category</td>
					<td>
						<select name="business_category">
<?php

foreach($business_categories as $row)
{
	$business_category = $row['business_category'];
	echo "\t\t\t\t\t\t\t" . '<option value="' . $business_category . '">' . $business_category . '</option>' . "\n";
}

?>
						</select>
					</td>
				</tr>
			</table>
			<button name="task" value="insert_customer" type="submit">Submit</button>
		</fieldset>
	</form>
	<form action="" method="post">
		<fieldset>
			<legend>ADD SALESPERSON</legend>
			<table>
				<tr>
					<td>First name: </td>
					<td><input name="first_name" type="text" /></td>
				</tr>
				<tr>
					<td>Last name: </td>
					<td><input name="last_name" type="text" /></td>
				</tr>
				<tr>
					<td>Street / PO Box: </td>
					<td><input name="street_po_box" type="text" /></td>
				</tr>
				<tr>
					<td>City: </td>
					<td><input name="city" type="text" /></td>
				</tr>
				<tr>
					<td>State (two letter): </td>
					<td><input name="state" type="text" maxlength="2" /></td>
				</tr>
				<tr>
					<td>ZIP Code: </td>
					<td><input name="ZIP_Code" type="number" maxlength="5" /></td>
				</tr>
				<tr>
					<td>Telephone: </td>
					<td><input name="telephone" type="number" maxlength="10" /></td>
				</tr>
				<tr>
					<td>Annual salary: </td>
					<td><input name="annual_salary" type="number" /></td>
				</tr>
				<tr>
					<td>Store: </td>
					<td>
						<select name="store_ID">
<?php

foreach($stores as $row)
{
	$ID = $row['ID'];
	echo "\t\t\t\t\t\t\t" . '<option value="' . $ID . '">' . $row['address'] . ' (' . 'Store#' . $ID . ')' . '</option>' . "\n";
}

?>
						</select>
					</td>
				</tr>
				<tr>
					<td>Job title: </td>
					<td><input name="job_title" type="text" /></td>
				</tr>
			</table>
			<button name="task" value="insert_salesperson" type="submit">Submit</button>
		</fieldset>
	</form>
	<form action="" method="post">
		<fieldset>
			<legend>CHANGE STORE MANAGER</legend>
			<table>
				<tr>
					<td>Store: </td>
					<td>
						<select id="update_store_manager_store_ID" name="store_ID">
<?php

foreach($stores as $row)
{
	$ID = $row['ID'];
	echo "\t\t\t\t\t\t\t" . '<option value="' . $ID . '">' . $row['address'] . ' (' . 'Store#' . $ID . ')' . '</option>' . "\n";
}

?>
						</select>
					</td>
				</tr>
				<tr>
					<td>Employee#</td>
					<td><input name="employee_ID" type="number" /></td>
				</tr>
			</table>
			<button name="task" value="update_store_manager" type="submit">Submit</button>
		</fieldset>
	</form>
	<form action="" method="post">
		<fieldset>
			<legend>CHANGE REGION MANAGER</legend>
			<table>
				<tr>
					<td>Region: </td>
					<td>
						<select name="region_ID">
<?php

foreach($regions as $row)
{
	$ID = $row['ID'];
	echo "\t\t\t\t\t\t\t" . '<option value="' . $ID . '">' . $row['name'] . ' (' . 'Region#' . $ID . ')' . '</option>' . "\n";
}

?>
						</select>
					</td>
				</tr>
				<tr>
					<td>Employee#</td>
					<td><input name="employee_ID" type="number" /></td>
				</tr>
			</table>
			<button name="task" value="update_region_manager" type="submit">Submit</button>
		</fieldset>
	</form>
	<form action="" method="post">
		<fieldset>
			<legend>ADD PRODUCT</legend>
			<table>
				<tr>
					<td>Name</td>
					<td><input name="name" type="text" /></td>
				</tr>
				<tr>
					<td>Size (magnitude)</td>
					<td><input name="size_magnitude" type="text" /></td>
				</tr>
				<tr>
					<td>Size (unit)</td>
					<td><input name="size_unit" type="text" /></td>
				</tr>
				<tr>
					<td>Price</td>
					<td><input name="price" type="text" /></td>
				</tr>
				<tr>
					<td>Product category</td>
					<td>
						<select name="product_category">
<?php

foreach($product_categories as $row)
{
	$product_category = $row['product_category'];
	echo "\t\t\t\t\t\t\t" . '<option value="' . $product_category . '">' . $product_category . '</option>' . "\n";
}

?>
						</select>
					</td>
				</tr>
			</table>
			<button name="task" value="insert_product" type="submit">Submit</button>
		</fieldset>
	</form>
	<form action="" method="post">
		<fieldset>
			<legend>STOCK PRODUCT</legend>
			<table>
				<tr>
					<td>Product#</td>
					<td><input name="ID" type="number" /></td>
				</tr>
				<tr>
					<td>Inventory amount increment</td>
					<td><input name="inventory_amount_increment" type="number" /></td>
				</tr>
			</table>
			<button name="task" value="increment_product_inventory_amount" type="submit">Submit</button>
		</fieldset>
	</form>
	<form action="" method="post">
		<fieldset>
			<legend>SHOW AGGREGATE</legend>
			<table>
				<tr><td><strong>Show aggregate [column] by [row]</strong></td><td>Sales</td><td>Revenue</td></tr>
				<tr>
					<td>Product</td>
					<td><button name="task" value="show_aggregate_sales_by_product" type="submit">Go</button></td>
					<td><button name="task" value="show_aggregate_revenue_by_product" type="submit">Go</button></td>
				</tr>
				<tr>
					<td>Product category</td>
					<td><button name="task" value="show_aggregate_sales_by_product_category" type="submit">Go</button></td>
					<td><button name="task" value="show_aggregate_revenue_by_product_category" type="submit">Go</button></td>
				</tr>
				<tr>
					<td>Store</td>
					<td><button name="task" value="show_aggregate_sales_by_store" type="submit">Go</button></td>
					<td><button name="task" value="show_aggregate_revenue_by_store" type="submit">Go</button></td>
				</tr>
				<tr>
					<td>Region</td>
					<td><button name="task" value="show_aggregate_sales_by_region" type="submit">Go</button></td>
					<td><button name="task" value="show_aggregate_revenue_by_region" type="submit">Go</button></td>
				</tr>
				<tr>
					<td>Home customer marriage status</td>
					<td><button name="task" value="show_aggregate_sales_by_home_customer_marriage_status" type="submit">Go</button></td>
					<td><button name="task" value="show_aggregate_revenue_by_home_customer_marriage_status" type="submit">Go</button></td>
				</tr>
				<tr>
					<td>Home customer gender</td>
					<td><button name="task" value="show_aggregate_sales_by_home_customer_gender" type="submit">Go</button></td>
					<td><button name="task" value="show_aggregate_revenue_by_home_customer_gender" type="submit">Go</button></td>
				</tr>
				<tr>
					<td>Business customer business category</td>
					<td><button name="task" value="show_aggregate_sales_by_business_customer_business_category" type="submit">Go</button></td>
					<td><button name="task" value="show_aggregate_revenue_by_business_customer_business_category" type="submit">Go</button></td>
				</tr>
			</table>
			Show available salesperson positions by store:
			<button name="task" value="show_aggregate_available_positions_by_store" type="submit">Go</button>
		</fieldset>
	</form>
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
