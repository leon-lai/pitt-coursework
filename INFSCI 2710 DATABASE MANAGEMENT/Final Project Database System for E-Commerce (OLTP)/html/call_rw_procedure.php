<?php

/* 2015-04-13 Leon Lai <Leon.Lai@pitt.edu> */

function call_rw_procedure($procedure, $arguments)
{
	$mysqli = new mysqli('localhost', 'rw', '', '2154_INFSCI_2710_1080_project');

	if ($mysqli->connect_errno)
	{
		echo 'FAILED: ' . $mysqli->connect_error . '.' . "\n";
		return FALSE;
	}

	$query = 'CALL ' . $procedure . '(';
	if ($arguments !== null)
	{
		foreach($arguments as $argument)
		{
			if ($argument === NULL)
			{
				$query .= 'NULL,';
			}
			else
			{
				$query .= '\'' . $mysqli->real_escape_string($argument) . '\',';
			}
		}
	}
	$query .= '@O)';

	$mysqli_result = $mysqli->query($query);

	if (!$mysqli_result)
	{
		echo 'FAILED: ' . $mysqli->error . "\n";
		return FALSE;
	}

	$mysqli_result_2 = $mysqli->query('SELECT @O AS O');

	if (!$mysqli_result_2)
	{
		echo 'FAILED: ' . $mysqli->error . "\n";
		return FALSE;
	}

	return $mysqli_result_2->fetch_all(MYSQLI_ASSOC);
}

?>
