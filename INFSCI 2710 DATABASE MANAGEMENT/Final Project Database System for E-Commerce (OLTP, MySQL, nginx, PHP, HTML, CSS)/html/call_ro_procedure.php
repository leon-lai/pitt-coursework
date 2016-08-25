<?php

/* 2015-04-13 Leon Lai <Leon.Lai@pitt.edu> */

function call_ro_procedure($procedure, $arguments)
{
	$mysqli = new mysqli('localhost', 'ro', '', '2154_INFSCI_2710_1080_project');

	if ($mysqli->connect_errno)
	{
		echo 'FAILED: ' . $mysqli->connect_error . '.' . "\n";
		return FALSE;
	}

	$query = 'CALL ' . $procedure . '(';
	if ($arguments !== null)
	{
		$query_arguments = '';
		for ($index = 0; $index < count($arguments); $index++)
		{
			$arguments[$index] = $mysqli->real_escape_string($arguments[$index]);
		}
		$query .= '\'' . implode('\',\'', $arguments) . '\'';
	}
	$query .= ')';

	$mysqli_result = $mysqli->query($query);

	if (!$mysqli_result)
	{
		echo 'FAILED: ' . $mysqli->error . "\n";
		return FALSE;
	}

	return $mysqli_result->fetch_all(MYSQLI_ASSOC);
}

?>
