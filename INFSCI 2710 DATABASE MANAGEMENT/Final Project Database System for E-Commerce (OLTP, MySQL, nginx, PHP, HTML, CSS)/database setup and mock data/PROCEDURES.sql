-- 2015-04-18 Leon Lai <Leon.Lai@pitt.edu>

USE 2154_INFSCI_2710_1080_project;

CREATE USER 'ro'@'localhost';
GRANT EXECUTE ON PROCEDURE find_customers                       TO 'ro'@'localhost';
GRANT EXECUTE ON PROCEDURE list_business_categories             TO 'ro'@'localhost';
GRANT EXECUTE ON PROCEDURE list_marriage_statuses               TO 'ro'@'localhost';
GRANT EXECUTE ON PROCEDURE list_genders                         TO 'ro'@'localhost';
GRANT EXECUTE ON PROCEDURE list_regions                         TO 'ro'@'localhost';
GRANT EXECUTE ON PROCEDURE list_stores                          TO 'ro'@'localhost';
GRANT EXECUTE ON PROCEDURE list_for_public_stores               TO 'ro'@'localhost';
GRANT EXECUTE ON PROCEDURE find_employees                       TO 'ro'@'localhost';
GRANT EXECUTE ON PROCEDURE list_product_categories              TO 'ro'@'localhost';
GRANT EXECUTE ON PROCEDURE list_products                        TO 'ro'@'localhost';
GRANT EXECUTE ON PROCEDURE list_for_public_products             TO 'ro'@'localhost';
GRANT EXECUTE ON PROCEDURE list_for_public_products_in_category TO 'ro'@'localhost';
GRANT EXECUTE ON PROCEDURE find_products                        TO 'ro'@'localhost';
GRANT EXECUTE ON PROCEDURE find_for_public_products             TO 'ro'@'localhost';
GRANT EXECUTE ON PROCEDURE show_aggregate_sales_by_product TO 'ro'@'localhost';
GRANT EXECUTE ON PROCEDURE show_aggregate_revenue_by_product TO 'ro'@'localhost';
GRANT EXECUTE ON PROCEDURE show_aggregate_sales_by_product_category TO 'ro'@'localhost';
GRANT EXECUTE ON PROCEDURE show_aggregate_revenue_by_product_category TO 'ro'@'localhost';
GRANT EXECUTE ON PROCEDURE show_aggregate_sales_by_store TO 'ro'@'localhost';
GRANT EXECUTE ON PROCEDURE show_aggregate_revenue_by_store TO 'ro'@'localhost';
GRANT EXECUTE ON PROCEDURE show_aggregate_sales_by_region TO 'ro'@'localhost';
GRANT EXECUTE ON PROCEDURE show_aggregate_revenue_by_region TO 'ro'@'localhost';
GRANT EXECUTE ON PROCEDURE show_aggregate_sales_by_home_customer_marriage_status TO 'ro'@'localhost';
GRANT EXECUTE ON PROCEDURE show_aggregate_revenue_by_home_customer_marriage_status TO 'ro'@'localhost';
GRANT EXECUTE ON PROCEDURE show_aggregate_sales_by_home_customer_gender TO 'ro'@'localhost';
GRANT EXECUTE ON PROCEDURE show_aggregate_revenue_by_home_customer_gender TO 'ro'@'localhost';
GRANT EXECUTE ON PROCEDURE show_aggregate_sales_by_business_customer_business_category TO 'ro'@'localhost';
GRANT EXECUTE ON PROCEDURE show_aggregate_revenue_by_business_customer_business_category TO 'ro'@'localhost';
GRANT EXECUTE ON PROCEDURE show_aggregate_available_positions_by_store TO 'ro'@'localhost';

CREATE USER 'rw'@'localhost';
GRANT EXECUTE ON PROCEDURE insert_customer                    TO 'rw'@'localhost';
GRANT EXECUTE ON PROCEDURE update_region_manager              TO 'rw'@'localhost';
GRANT EXECUTE ON PROCEDURE update_store_manager               TO 'rw'@'localhost';
GRANT EXECUTE ON PROCEDURE insert_salesperson                 TO 'rw'@'localhost';
GRANT EXECUTE ON PROCEDURE insert_product                     TO 'rw'@'localhost';
GRANT EXECUTE ON PROCEDURE increment_product_inventory_amount TO 'rw'@'localhost';

CREATE USER 'insert_transaction_group'@'localhost';
GRANT SELECT ON products           TO 'insert_transaction_group'@'localhost';
GRANT UPDATE ON products           TO 'insert_transaction_group'@'localhost';
GRANT INSERT ON transaction_groups TO 'insert_transaction_group'@'localhost';
GRANT SELECT ON transactions       TO 'insert_transaction_group'@'localhost';
GRANT INSERT ON transactions       TO 'insert_transaction_group'@'localhost';



---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------



CREATE PROCEDURE find_customers
( single_word VARCHAR(256)
)
SELECT ID
     , first_name
     , last_name
     , CONCAT( IFNULL(street_po_box,'')
       , ', ', IFNULL(city,'')
       , ', ', IFNULL(state,'')
       , '  ', IFNULL(ZIP_Code,'') ) AS address
     , telephone
     , email
     , annual_income
     , is_corporation
     , CONCAT( 'marriage_status=', IFNULL(marriage_status,'')
                    , ', gender=', IFNULL(gender,'')
                , ', birth_date=', IFNULL(birth_date,'') ) AS other_attributes
FROM customers
JOIN home_customers
ON customers.ID = home_customers.customer
WHERE
	LOWER(CONCAT(
		'#', IFNULL(ID,'')
		, ' ', IFNULL(first_name,'')
		, ' ', IFNULL(last_name,'')
		, ' ', IFNULL(street_po_box,'')
		, ', ', IFNULL(city,'')
		, ', ', IFNULL(state,'')
		, '  ', IFNULL(ZIP_Code,'')
		, ' ', IFNULL(telephone,'')
		, ' ', IFNULL(email,'')
		, ' ', IFNULL(annual_income,'')
		, ' ', 'HOME'
		, ' ', 'marriage_status=', IFNULL(marriage_status,'')
		, ', gender=', IFNULL(gender,'')
		, ', birth_date=', IFNULL(birth_date,'')
		, ' '
	)) LIKE LOWER(CONCAT('%', single_word, '%'))
UNION
SELECT ID
     , first_name
     , last_name
     , CONCAT( IFNULL(street_po_box,'')
       , ', ', IFNULL(city,'')
       , ', ', IFNULL(state,'')
       , '  ', IFNULL(ZIP_Code,'') ) AS address
     , telephone
     , email
     , annual_income
     , is_corporation
     , CONCAT('business_category=', IFNULL(business_category,'')) AS other_attributes
FROM customers
JOIN business_customers
ON customers.ID = business_customers.customer
WHERE
	LOWER(CONCAT(
		'#', IFNULL(ID,'')
		, ' ', IFNULL(first_name,'')
		, ' ', IFNULL(last_name,'')
		, ' ', IFNULL(street_po_box,'')
		, ', ', IFNULL(city,'')
		, ', ', IFNULL(state,'')
		, '  ', IFNULL(ZIP_Code,'')
		, ' ', IFNULL(telephone,'')
		, ' ', IFNULL(email,'')
		, ' ', IFNULL(annual_income,'')
		, ' ', 'BUSINESS'
		, ' ', 'business_category=', IFNULL(business_category,'')
		, ' '
	)) LIKE LOWER(CONCAT('%', single_word, '%'));

CREATE PROCEDURE list_business_categories
()
SELECT business_category
FROM business_categories
ORDER BY business_category;

CREATE PROCEDURE list_marriage_statuses
()
SELECT marriage_status
FROM marriage_statuses
ORDER BY marriage_status;

CREATE PROCEDURE list_genders
()
SELECT gender
FROM genders
ORDER BY gender;

CREATE PROCEDURE list_regions
()
SELECT ID, name
FROM regions
ORDER BY ID;

CREATE PROCEDURE list_stores
()
SELECT ID
     , name
     , CONCAT( IFNULL(street_po_box,'')
       , ', ', IFNULL(city,'')
       , ', ', IFNULL(state,'')
       , '  ', IFNULL(ZIP_Code,'') ) AS address
     , telephone
     , email
     , max_number_of_salespersons
     , region
FROM stores
ORDER BY state, city;

CREATE PROCEDURE list_for_public_stores
()
SELECT name
     , CONCAT( IFNULL(street_po_box,'')
       , ', ', IFNULL(city,'')
       , ', ', IFNULL(state,'')
       , '  ', IFNULL(ZIP_Code,'') ) AS address
     , telephone
     , email
FROM stores
ORDER BY state, city;

CREATE PROCEDURE find_employees
( single_word VARCHAR(256)
)
SELECT ID
     , first_name
     , last_name
     , CONCAT( IFNULL(street_po_box,'')
       , ', ', IFNULL(city,'')
       , ', ', IFNULL(state,'')
       , '  ', IFNULL(ZIP_Code,'') ) AS address
     , telephone
     , email
     , annual_salary
     , employee_type
     , CONCAT('region=', IFNULL(region,'')) AS other_attributes
FROM employees
JOIN region_managers
ON employees.ID = region_managers.employee
WHERE
	LOWER(CONCAT(
		'#', IFNULL(ID,'')
		, ' ', IFNULL(first_name,'')
		, ' ', IFNULL(last_name,'')
		, ' ', IFNULL(street_po_box,'')
		, ', ', IFNULL(city,'')
		, ', ', IFNULL(state,'')
		, '  ', IFNULL(ZIP_Code,'')
		, ' ', IFNULL(telephone,'')
		, ' ', IFNULL(email,'')
		, ' ', IFNULL(annual_salary,'')
		, ' ', IFNULL(employee_type,'')
		, ' ', 'Region#', IFNULL(region,'')
		, ' '
	)) LIKE LOWER(CONCAT('%', single_word, '%'))
UNION
SELECT ID
     , first_name
     , last_name
     , CONCAT( IFNULL(street_po_box,'')
       , ', ', IFNULL(city,'')
       , ', ', IFNULL(state,'')
       , '  ', IFNULL(ZIP_Code,'') ) AS address
     , telephone
     , email
     , annual_salary
     , employee_type
     , CONCAT('store=', IFNULL(store,'')) AS other_attributes
FROM employees
JOIN store_managers
ON employees.ID = store_managers.employee
WHERE
	LOWER(CONCAT(
		'#', IFNULL(ID,'')
		, ' ', IFNULL(first_name,'')
		, ' ', IFNULL(last_name,'')
		, ' ', IFNULL(street_po_box,'')
		, ', ', IFNULL(city,'')
		, ', ', IFNULL(state,'')
		, '  ', IFNULL(ZIP_Code,'')
		, ' ', IFNULL(telephone,'')
		, ' ', IFNULL(email,'')
		, ' ', IFNULL(annual_salary,'')
		, ' ', IFNULL(employee_type,'')
		, ' ', 'Store#', IFNULL(store,'')
		, ' '
	)) LIKE LOWER(CONCAT('%', single_word, '%'))
UNION
SELECT ID
     , first_name
     , last_name
     , CONCAT( IFNULL(street_po_box,'')
       , ', ', IFNULL(city,'')
       , ', ', IFNULL(state,'')
       , '  ', IFNULL(ZIP_Code,'') ) AS address
     , telephone
     , email
     , annual_salary
     , employee_type
     , CONCAT( 'store=', IFNULL(store,'')
       , ', job_title=', IFNULL(job_title,'') ) AS other_attributes
FROM employees
JOIN salespersons
ON employees.ID = salespersons.employee
WHERE
	LOWER(CONCAT(
		'#', IFNULL(ID,'')
		, ' ', IFNULL(first_name,'')
		, ' ', IFNULL(last_name,'')
		, ' ', IFNULL(street_po_box,'')
		, ', ', IFNULL(city,'')
		, ', ', IFNULL(state,'')
		, '  ', IFNULL(ZIP_Code,'')
		, ' ', IFNULL(telephone,'')
		, ' ', IFNULL(email,'')
		, ' ', IFNULL(annual_salary,'')
		, ' ', IFNULL(employee_type,'')
		, ' ', 'Store#', IFNULL(store,'')
		, ', job_title=', IFNULL(job_title,'')
		, ' '
	)) LIKE LOWER(CONCAT('%', single_word, '%'));

CREATE PROCEDURE list_product_categories
()
SELECT product_category
FROM product_categories
ORDER BY product_category;

CREATE PROCEDURE list_products
()
SELECT ID
     , CONCAT(IFNULL(name,'')
       , ' ', IFNULL(size_magnitude,'')
       ,      IFNULL(size_unit,'')) as description
     , product_category
     , price
     , inventory_amount
FROM products
ORDER BY product_category, name, size_unit, size_magnitude;

CREATE PROCEDURE list_for_public_products
()
SELECT CONCAT(IFNULL(name,'')
       , ' ', IFNULL(size_magnitude,'')
       ,      IFNULL(size_unit,'')) as description
     , product_category
     , price
     , CASE
       WHEN inventory_amount = 1 THEN 'One left.'
       WHEN inventory_amount = 0 THEN 'Out of stock.'
       ELSE ''
       END
       AS remarks
FROM products
RIGHT JOIN product_categories USING (product_category)
ORDER BY product_category, name, size_unit, size_magnitude;

CREATE PROCEDURE list_for_public_products_in_category
( v_product_category VARCHAR(64)
)
SELECT CONCAT(IFNULL(name,'')
       , ' ', IFNULL(size_magnitude,'')
       ,      IFNULL(size_unit,'')) as description
     , price
     , CASE
       WHEN inventory_amount = 1 THEN 'One left.'
       WHEN inventory_amount = 0 THEN 'Out of stock.'
       ELSE ''
       END
       AS remarks
FROM products
WHERE product_category = v_product_category
ORDER BY name, size_unit, size_magnitude;

CREATE PROCEDURE find_products
( single_word VARCHAR(256)
)
SELECT ID
     , CONCAT(IFNULL(name,'')
       , ' ', IFNULL(size_magnitude,'')
       ,      IFNULL(size_unit,'')) as description
     , product_category
     , price
     , inventory_amount
FROM products
WHERE
	LOWER(CONCAT(
		'#', IFNULL(ID,'')
		, ' ', IFNULL(name,'')
		, ' ', IFNULL(size_magnitude,'')
		, ' ', IFNULL(size_unit,'')
		, ' ', IFNULL(size_magnitude,''), IFNULL(size_unit,'')
		, ' ', IFNULL(product_category,'')
	)) LIKE LOWER(CONCAT('%', single_word, '%'))
ORDER BY product_category, name, size_unit, size_magnitude;

CREATE PROCEDURE find_for_public_products
( single_word VARCHAR(4096)
)
SELECT CONCAT(IFNULL(name,'')
       , ' ', IFNULL(size_magnitude,'')
       ,      IFNULL(size_unit,'')) as description
     , product_category
     , price
     , CASE
       WHEN inventory_amount = 1 THEN 'One left.'
       WHEN inventory_amount = 0 THEN 'Out of stock.'
       ELSE ''
       END
       AS remarks
FROM products
WHERE
	LOWER(CONCAT(
		IFNULL(name,'')
		, ' ', IFNULL(size_magnitude,'')
		, ' ', IFNULL(size_unit,'')
		, ' ', IFNULL(size_magnitude,''), IFNULL(size_unit,'')
		, ' ', IFNULL(product_category,'')
	)) LIKE LOWER(CONCAT('%', single_word, '%'))
ORDER BY product_category, name, size_unit, size_magnitude;



---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------



DELIMITER ;;
CREATE PROCEDURE insert_customer
( first_name     VARCHAR(256)
, last_name      VARCHAR(256)
, street_po_box  VARCHAR(256)
, city           VARCHAR(256)
, state          CHAR(2)
, ZIP_Code       MEDIUMINT(5) UNSIGNED ZEROFILL
, telephone      BIGINT(10) UNSIGNED ZEROFILL
, email          VARCHAR(256)
, annual_income  DECIMAL(63,2)
, is_corporation SMALLINT(1)
, business_category VARCHAR(16)
, marriage_status VARCHAR(16)
, gender          VARCHAR(16)
, birth_date      DATE
, OUT O BIGINT UNSIGNED
)
BEGIN
	SET autocommit = 0;
	START TRANSACTION;
	INSERT INTO customers
	( first_name
	, last_name
	, street_po_box
	, city
	, state
	, ZIP_Code
	, telephone
	, email
	, annual_income
	, is_corporation
	)
	VALUES
	( first_name
	, last_name
	, street_po_box
	, city
	, state
	, ZIP_Code
	, telephone
	, email
	, annual_income
	, is_corporation
	);
	CASE is_corporation
	WHEN 0 THEN
		INSERT INTO home_customers
		( customer
		, marriage_status
		, gender
		, birth_date
		)
		VALUES
		( LAST_INSERT_ID()
		, marriage_status
		, gender
		, birth_date
		);
	WHEN 1 THEN
		INSERT INTO business_customers
		( customer
		, business_category
		)
		VALUES
		( LAST_INSERT_ID()
		, business_category
		);
	ELSE
		SIGNAL SQLSTATE '23000'
		SET MESSAGE_TEXT = 'Invalid value for is_corporation';
	END CASE;
	COMMIT;
	SELECT LAST_INSERT_ID() INTO O;
END;;
DELIMITER ;

DELIMITER ;;
CREATE PROCEDURE update_region_manager
( v_region   BIGINT UNSIGNED
, v_employee BIGINT UNSIGNED
, OUT O BIGINT UNSIGNED
)
BEGIN
	SELECT employee INTO O
	FROM region_managers
	WHERE region = v_region;
	INSERT INTO region_managers
	( region
	, employee
	)
	VALUES
	( v_region
	, v_employee
	)
	ON DUPLICATE KEY UPDATE employee = v_employee;
END;;
DELIMITER ;

DELIMITER ;;
CREATE PROCEDURE update_store_manager
( v_store    BIGINT UNSIGNED
, v_employee BIGINT UNSIGNED
, OUT O BIGINT UNSIGNED
)
BEGIN
	SELECT employee INTO O
	FROM store_managers
	WHERE store = v_store;
	INSERT INTO store_managers
	( store
	, employee
	)
	VALUES
	( v_store
	, v_employee
	)
	ON DUPLICATE KEY UPDATE employee = v_employee;
END;;
DELIMITER ;

DELIMITER ;;
CREATE PROCEDURE insert_salesperson
( first_name    VARCHAR(256)
, last_name     VARCHAR(256)
, street_po_box VARCHAR(256)
, city          VARCHAR(256)
, state         CHAR(2)
, ZIP_Code      MEDIUMINT(5) UNSIGNED ZEROFILL
, telephone     BIGINT(10) UNSIGNED ZEROFILL
, annual_salary DECIMAL(63,2)
, store    BIGINT UNSIGNED
, job_title   VARCHAR(256)
, OUT O BIGINT UNSIGNED
)
BEGIN
	SET autocommit = 0;
	START TRANSACTION;
	INSERT INTO employees
	( first_name
	, last_name
	, street_po_box
	, city
	, state
	, ZIP_Code
	, telephone
	, email
	, annual_salary
	, employee_type
	)
	VALUES
	( first_name
	, last_name
	, street_po_box
	, city
	, state
	, ZIP_Code
	, telephone
	, CONCAT(IFNULL(first_name,'')
	  , '.', IFNULL(last_name,'')
	  , '@ditigalsales.com')
	, annual_salary
	, 'salesperson'
	);
	INSERT INTO salespersons
	( employee
	, store
	, job_title
	)
	VALUES
	( LAST_INSERT_ID()
	, store
	, job_title
	);
	COMMIT;
	SELECT LAST_INSERT_ID() INTO O;
END;;
DELIMITER ;

DELIMITER ;;
CREATE PROCEDURE insert_product
( name             VARCHAR(256)
, size_magnitude   DOUBLE UNSIGNED
, size_unit        VARCHAR(8)
, price            DECIMAL(63,2)
, product_category VARCHAR(64)
, OUT O BIGINT UNSIGNED
)
BEGIN
	INSERT INTO products
	( name
	, size_magnitude
	, size_unit
	, price
	, inventory_amount
	, product_category
	)
	VALUES
	( name
	, size_magnitude
	, size_unit
	, price
	, 0
	, product_category
	);
	SELECT LAST_INSERT_ID() INTO O;
END;;
DELIMITER ;

DELIMITER ;;
CREATE PROCEDURE increment_product_inventory_amount
( v_ID BIGINT UNSIGNED
, inventory_amount_increment BIGINT UNSIGNED
, OUT O BIGINT UNSIGNED
)
BEGIN
	UPDATE products
	SET inventory_amount = inventory_amount + inventory_amount_increment
	WHERE ID = v_ID;
	SELECT inventory_amount INTO O
	FROM products
	WHERE ID = v_ID;
END;;
DELIMITER ;



---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------



CREATE PROCEDURE show_aggregate_sales_by_product
()
SELECT product
     , CONCAT(IFNULL(name,'')
       , ' ', IFNULL(size_magnitude,'')
       ,      IFNULL(size_unit,'')) as description
     , product_category
     , product_quantity
FROM products
JOIN (
	SELECT product, SUM(product_quantity) AS product_quantity
	FROM transactions
	GROUP BY product
) AS Q ON products.ID = Q.product
ORDER BY product_quantity DESC;

CREATE PROCEDURE show_aggregate_revenue_by_product
()
SELECT product
     , CONCAT(IFNULL(name,'')
       , ' ', IFNULL(size_magnitude,'')
       ,      IFNULL(size_unit,'')) as description
     , product_category
     , amount_paid
FROM products
JOIN (
	SELECT product, SUM(amount_paid) AS amount_paid
	FROM transactions
	GROUP BY product
) AS Q ON products.ID = Q.product
ORDER BY amount_paid DESC;

CREATE PROCEDURE show_aggregate_sales_by_product_category
()
SELECT product_category, SUM(product_quantity) AS product_quantity
FROM transactions
JOIN products ON transactions.product = products.ID
GROUP BY product_category
ORDER BY product_quantity DESC;

CREATE PROCEDURE show_aggregate_revenue_by_product_category
()
SELECT product_category, SUM(amount_paid) AS amount_paid
FROM transactions
JOIN products ON transactions.product = products.ID
GROUP BY product_category
ORDER BY amount_paid DESC;

CREATE PROCEDURE show_aggregate_sales_by_store
()
SELECT store
     , CONCAT( IFNULL(street_po_box,'')
       , ', ', IFNULL(city,'')
       , ', ', IFNULL(state,'')
       , '  ', IFNULL(ZIP_Code,'') ) AS address
     , region
     , regions.name AS region_name
     , product_quantity
FROM stores
JOIN (
	SELECT store, SUM(product_quantity) AS product_quantity
	FROM transactions
	JOIN transaction_groups ON transactions.transaction_group = transaction_groups.ID
	JOIN salespersons ON transaction_groups.salesperson = salespersons.employee
	GROUP BY store
) AS Q ON stores.ID = Q.store
JOIN regions ON stores.region = regions.ID
ORDER BY product_quantity DESC;

CREATE PROCEDURE show_aggregate_revenue_by_store
()
SELECT store
     , CONCAT( IFNULL(street_po_box,'')
       , ', ', IFNULL(city,'')
       , ', ', IFNULL(state,'')
       , '  ', IFNULL(ZIP_Code,'') ) AS address
     , region
     , regions.name AS region_name
     , amount_paid
FROM stores
JOIN (
	SELECT store, SUM(amount_paid) AS amount_paid
	FROM transactions
	JOIN transaction_groups ON transactions.transaction_group = transaction_groups.ID
	JOIN salespersons ON transaction_groups.salesperson = salespersons.employee
	GROUP BY store
) AS Q ON stores.ID = Q.store
JOIN regions ON stores.region = regions.ID
ORDER BY amount_paid DESC;

CREATE PROCEDURE show_aggregate_sales_by_region
()
SELECT region
     , name
     , product_quantity
FROM regions
JOIN (
	SELECT region, SUM(product_quantity) AS product_quantity
	FROM transactions
	JOIN transaction_groups ON transactions.transaction_group = transaction_groups.ID
	JOIN salespersons ON transaction_groups.salesperson = salespersons.employee
	JOIN stores ON salespersons.store = stores.ID
	GROUP BY region
) AS Q ON regions.ID = Q.region
ORDER BY product_quantity DESC;

CREATE PROCEDURE show_aggregate_revenue_by_region
()
SELECT region
     , name
     , amount_paid
FROM regions
JOIN (
	SELECT region, SUM(amount_paid) AS amount_paid
	FROM transactions
	JOIN transaction_groups ON transactions.transaction_group = transaction_groups.ID
	JOIN salespersons ON transaction_groups.salesperson = salespersons.employee
	JOIN stores ON salespersons.store = stores.ID
	GROUP BY region
) AS Q ON regions.ID = Q.region
ORDER BY amount_paid DESC;

CREATE PROCEDURE show_aggregate_sales_by_home_customer_marriage_status
()
SELECT marriage_status, SUM(product_quantity) AS product_quantity
FROM transactions
JOIN transaction_groups ON transactions.transaction_group = transaction_groups.ID
JOIN customers ON transaction_groups.customer = customers.ID
JOIN home_customers ON customers.ID = home_customers.customer
GROUP BY marriage_status
ORDER BY product_quantity DESC;

CREATE PROCEDURE show_aggregate_revenue_by_home_customer_marriage_status
()
SELECT marriage_status, SUM(amount_paid) AS amount_paid
FROM transactions
JOIN transaction_groups ON transactions.transaction_group = transaction_groups.ID
JOIN customers ON transaction_groups.customer = customers.ID
JOIN home_customers ON customers.ID = home_customers.customer
GROUP BY marriage_status
ORDER BY amount_paid DESC;

CREATE PROCEDURE show_aggregate_sales_by_home_customer_gender
()
SELECT gender, SUM(product_quantity) AS product_quantity
FROM transactions
JOIN transaction_groups ON transactions.transaction_group = transaction_groups.ID
JOIN customers ON transaction_groups.customer = customers.ID
JOIN home_customers ON customers.ID = home_customers.customer
GROUP BY gender
ORDER BY product_quantity DESC;

CREATE PROCEDURE show_aggregate_revenue_by_home_customer_gender
()
SELECT gender, SUM(amount_paid) AS amount_paid
FROM transactions
JOIN transaction_groups ON transactions.transaction_group = transaction_groups.ID
JOIN customers ON transaction_groups.customer = customers.ID
JOIN home_customers ON customers.ID = home_customers.customer
GROUP BY gender
ORDER BY amount_paid DESC;

CREATE PROCEDURE show_aggregate_sales_by_business_customer_business_category
()
SELECT business_category, SUM(product_quantity) AS product_quantity
FROM transactions
JOIN transaction_groups ON transactions.transaction_group = transaction_groups.ID
JOIN customers ON transaction_groups.customer = customers.ID
JOIN business_customers ON customers.ID = business_customers.customer
GROUP BY business_category
ORDER BY product_quantity DESC;

CREATE PROCEDURE show_aggregate_revenue_by_business_customer_business_category
()
SELECT business_category, SUM(amount_paid) AS amount_paid
FROM transactions
JOIN transaction_groups ON transactions.transaction_group = transaction_groups.ID
JOIN customers ON transaction_groups.customer = customers.ID
JOIN business_customers ON customers.ID = business_customers.customer
GROUP BY business_category
ORDER BY amount_paid DESC;

CREATE PROCEDURE show_aggregate_available_positions_by_store
()
SELECT store
     , CONCAT( IFNULL(street_po_box,'')
       , ', ', IFNULL(city,'')
       , ', ', IFNULL(state,'')
       , '  ', IFNULL(ZIP_Code,'') ) AS address
     , region
     , regions.name AS region_name
     , max_number_of_salespersons - number_of_salespersons AS available_positions
FROM stores
JOIN (
	SELECT store, COUNT(*) AS number_of_salespersons
	FROM salespersons
	GROUP BY store
) AS Q ON stores.ID = Q.store
JOIN regions ON stores.region = regions.ID
ORDER BY state, city;
