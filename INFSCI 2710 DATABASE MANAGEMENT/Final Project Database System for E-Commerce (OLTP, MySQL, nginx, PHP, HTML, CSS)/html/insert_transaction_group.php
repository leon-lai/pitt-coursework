<?php

/* 2015-04-18 Leon Lai <Leon.Lai@pitt.edu> */

function insert_transaction_group($arguments)
{
	if (! (isset($arguments['salesperson']) && $arguments['salesperson'] !== '' && isset($arguments['customer']) && $arguments['customer'] !== ''))
	{
		echo 'FAILED: Employee ID or customer ID not specified.' . "\n";
		return FALSE;
	}

	$salesperson = $arguments['salesperson'];
	$customer = $arguments['customer'];
	$product_quantities = array();
	foreach(array_keys($arguments) as $key)
	{
		if (strncmp($key, 'product_', strlen('product_')) === 0 && ! empty($arguments[$key]))
		{
			$product_quantities[str_replace('product_', '', $key)] = $arguments[$key];
		}
	}

	if (count($product_quantities) === 0)
	{
		echo 'FAILED: No product quantities specified.' . "\n";
		return FALSE;
	}

	$mysqli = new mysqli('localhost', 'insert_transaction_group', '', '2154_INFSCI_2710_1080_project');

	if ($mysqli->connect_errno)
	{
		echo 'FAILED: ' . $mysqli->connect_error . '.' . "\n";
		return FALSE;
	}

	if
	(  ! $mysqli->query('SET autocommit = 0;')
	|| ! $mysqli->query('START TRANSACTION;')
	)
	{
		echo 'FAILED: ' . $mysqli->error . "\n";
		return FALSE;
	}
	if
	(  ! $mysqli->query('INSERT INTO transaction_groups (date, salesperson, customer) VALUES (CURDATE(), ' . $mysqli->real_escape_string($salesperson) . ', ' . $mysqli->real_escape_string($customer) . ');')
	|| ! $mysqli->query('SET @transaction_group = LAST_INSERT_ID();')
	)
	{
		echo 'FAILED: ' . $mysqli->error . "\n";
		$mysqli->query('ROLLBACK;');
		return FALSE;
	}
	foreach(array_keys($product_quantities) as $product)
	{
		$product_quantity = $product_quantities[$product];
		if
		(  ! $mysqli->query('SET @product = ' . $mysqli->real_escape_string($product) . ', @product_quantity = ' . $mysqli->real_escape_string($product_quantity) . ';')
		|| ! $mysqli->query('SET @amount_paid = (SELECT price FROM products WHERE ID = @product) * @product_quantity;')
		|| ! $mysqli->query('UPDATE products SET inventory_amount = inventory_amount - @product_quantity WHERE ID = @product;')
		|| ! $mysqli->query('INSERT INTO transactions (product, product_quantity, amount_paid, transaction_group) VALUES (@product, @product_quantity, @amount_paid, @transaction_group);')
		)
		{
			echo 'FAILED: ' . $mysqli->error . "\n";
			$mysqli->query('ROLLBACK;');
			return FALSE;
		}
	}
	if
	(  ! $mysqli->query('COMMIT;')
	)
	{
		echo 'FAILED: ' . $mysqli->error . "\n";
		$mysqli->query('ROLLBACK;');
		return FALSE;
	}

	$mysqli_result_2 = $mysqli->query('SELECT @transaction_group AS transaction_group_ID;');
	$mysqli_result_3 = $mysqli->query('SELECT SUM(amount_paid) AS amount_paid FROM transactions WHERE transaction_group = @transaction_group;');

	if (! $mysqli_result_2 || ! $mysqli_result_3)
	{
		echo 'FAILED: ' . $mysqli->error . "\n";
		return FALSE;
	}

	return array($mysqli_result_2->fetch_all(MYSQLI_ASSOC), $mysqli_result_3->fetch_all(MYSQLI_ASSOC));
}

?>
