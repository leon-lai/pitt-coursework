-- 2015-04-13 Leon Lai <Leon.Lai@pitt.edu>
--
-- Application Requirements: Data
--    Customers:
--        customer ID
--        name
--        address (street, city, state, zip code)
--        kind (home/business)
--        If business, then...
--            business category
--            company gross annual income
--            etc.
--        If home, then...
--            marriage status
--            gender
--            age
--            income
--    Products:
--        product ID
--        name
--        inventory amount
--        price
--        product kind with respect to some classification
--    Transactions: record of product purchased, including...
--        order number
--        date
--        salesperson name
--        product information (price, quantity, etc.)
--        customer information
--    Salespersons:
--        name
--        address
--        e-mail
--        job title
--        store assigned
--        salary
--    Store:
--        store ID
--        address
--        manager
--        number of salespersons
--        region
--    Region:
--        region ID
--        region name
--        region manager

CREATE DATABASE IF NOT EXISTS 2154_INFSCI_2710_1080_project;
USE 2154_INFSCI_2710_1080_project;

-- * customers
--   * business customers
--   * home customers
-- * products
-- * transaction groups
-- * transactions
-- * stores
-- * regions
-- * employees
--   * store managers
--   * region managers
--   * salespersons

-- https://stackoverflow.com/questions/15249730
-- https://dev.mysql.com/doc/refman/5.6/en/create-table.html
-- MySQL parses but ignores “inline REFERENCES specifications” (as defined
-- in the SQL standard) where the references are defined as part of the
-- column specification. MySQL accepts REFERENCES clauses only when
-- specified as part of a separate FOREIGN KEY specification.
-- http://stackoverflow.com/questions/2115497
-- https://dev.mysql.com/doc/refman/5.6/en/create-table.html
-- The CHECK clause is parsed but ignored by all storage engines.

CREATE TABLE customers
( ID             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY
, first_name     VARCHAR(256) NOT NULL
, last_name      VARCHAR(256)
, street_po_box  VARCHAR(256)
, city           VARCHAR(256)
, state          CHAR(2)
, ZIP_Code       MEDIUMINT(5) UNSIGNED ZEROFILL
, telephone      BIGINT(10) UNSIGNED ZEROFILL
, email          VARCHAR(256) NOT NULL
, annual_income  DECIMAL(63,2)
, is_corporation SMALLINT(1) NOT NULL
, CHECK (is_corporation IN (0,1))
);

DELIMITER ;;
CREATE TRIGGER customers_before_insert
BEFORE INSERT
ON customers FOR EACH ROW
BEGIN
	-- Check constraint reformulated as trigger
	IF NEW.is_corporation NOT IN (0,1)
	THEN
		SIGNAL SQLSTATE '23000'
		SET MESSAGE_TEXT = 'Invalid is_corporation';
	END IF;
END;;
DELIMITER ;

DELIMITER ;;
CREATE TRIGGER customers_before_update
BEFORE UPDATE
ON customers FOR EACH ROW
BEGIN
	-- Check constraint reformulated as trigger
	IF NEW.is_corporation NOT IN (0,1)
	THEN
		SIGNAL SQLSTATE '23000'
		SET MESSAGE_TEXT = 'Invalid is_corporation';
	END IF;
END;;
DELIMITER ;

CREATE TABLE business_categories
( business_category VARCHAR(64) PRIMARY KEY
);

CREATE TABLE business_customers
( customer       BIGINT UNSIGNED PRIMARY KEY
, business_category VARCHAR(64) NOT NULL
, FOREIGN KEY (customer) REFERENCES customers (ID)
, FOREIGN KEY (business_category) REFERENCES business_categories (business_category)
, CHECK (customer in (SELECT ID FROM customers WHERE is_corporation = b'1'))
);

DELIMITER ;;
CREATE TRIGGER business_customers_before_insert
BEFORE INSERT
ON business_customers FOR EACH ROW
BEGIN
	-- Check constraint reformulated as trigger
	IF NEW.customer NOT IN (SELECT ID FROM customers WHERE is_corporation = b'1')
	THEN
		SIGNAL SQLSTATE '23000'
		SET MESSAGE_TEXT = 'Invalid customer ID: not a business customer';
	END IF;
END;;
DELIMITER ;

DELIMITER ;;
CREATE TRIGGER business_customers_before_update
BEFORE UPDATE
ON business_customers FOR EACH ROW
BEGIN
	-- Check constraint reformulated as trigger
	IF NEW.customer NOT IN (SELECT ID FROM customers WHERE is_corporation = b'1')
	THEN
		SIGNAL SQLSTATE '23000'
		SET MESSAGE_TEXT = 'Invalid customer ID: not a business customer';
	END IF;
END;;
DELIMITER ;

CREATE TABLE marriage_statuses
( marriage_status VARCHAR(64) PRIMARY KEY
);

CREATE TABLE genders
( gender VARCHAR(64) PRIMARY KEY
);

CREATE TABLE home_customers
( customer     BIGINT UNSIGNED PRIMARY KEY
, marriage_status VARCHAR(64) NOT NULL
, gender          VARCHAR(64) NOT NULL
, birth_date      DATE
, FOREIGN KEY (customer) REFERENCES customers (ID)
, FOREIGN KEY (marriage_status) REFERENCES marriage_statuses (marriage_status)
, FOREIGN KEY (gender) REFERENCES genders (gender)
, CHECK (customer in (SELECT ID FROM customers WHERE is_corporation = b'0'))
);

DELIMITER ;;
CREATE TRIGGER home_customers_before_insert
BEFORE INSERT
ON home_customers FOR EACH ROW
BEGIN
	-- Check constraint reformulated as trigger
	IF NEW.customer NOT IN (SELECT ID FROM customers WHERE is_corporation = b'0')
	THEN
		SIGNAL SQLSTATE '23000'
		SET MESSAGE_TEXT = 'Invalid customer ID: not a home customer';
	END IF;
END;;
DELIMITER ;

DELIMITER ;;
CREATE TRIGGER home_customers_before_update
BEFORE UPDATE
ON home_customers FOR EACH ROW
BEGIN
	-- Check constraint reformulated as trigger
	IF NEW.customer NOT IN (SELECT ID FROM customers WHERE is_corporation = b'0')
	THEN
		SIGNAL SQLSTATE '23000'
		SET MESSAGE_TEXT = 'Invalid customer ID: not a home customer';
	END IF;
END;;
DELIMITER ;

CREATE TABLE regions
( ID            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY
, name          VARCHAR(256) NOT NULL
);

CREATE TABLE stores
( ID                         BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY
, name                       VARCHAR(256)
, street_po_box              VARCHAR(256)
, city                       VARCHAR(256)
, state                      CHAR(2)
, ZIP_Code                   MEDIUMINT(5) UNSIGNED ZEROFILL
, telephone                  BIGINT(10) UNSIGNED ZEROFILL
, email                      VARCHAR(256)
, max_number_of_salespersons BIGINT UNSIGNED NOT NULL
, region                     BIGINT UNSIGNED NOT NULL
, FOREIGN KEY (region) REFERENCES regions (ID)
);

CREATE TABLE employees
( ID            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY
, first_name    VARCHAR(256) NOT NULL
, last_name     VARCHAR(256)
, street_po_box VARCHAR(256)
, city          VARCHAR(256)
, state         CHAR(2)
, ZIP_Code      MEDIUMINT(5) UNSIGNED ZEROFILL
, telephone     BIGINT(10) UNSIGNED ZEROFILL
, email         VARCHAR(256) NOT NULL
, annual_salary DECIMAL(63,2) NOT NULL
, employee_type VARCHAR(14) NOT NULL
, CHECK (employee_type IN ('region manager','store manager','salesperson'))
);

DELIMITER ;;
CREATE TRIGGER employees_before_insert
BEFORE INSERT
ON employees FOR EACH ROW
BEGIN
	-- Check constraint reformulated as trigger
	IF NEW.employee_type NOT IN ('region manager','store manager','salesperson')
	THEN
		SIGNAL SQLSTATE '23000'
		SET MESSAGE_TEXT = 'Invalid employee_type';
	END IF;
END;;
DELIMITER ;

DELIMITER ;;
CREATE TRIGGER employees_before_update
BEFORE UPDATE
ON employees FOR EACH ROW
BEGIN
	-- Check constraint reformulated as trigger
	IF NEW.employee_type NOT IN ('region manager','store manager','salesperson')
	THEN
		SIGNAL SQLSTATE '23000'
		SET MESSAGE_TEXT = 'Invalid employee_type';
	END IF;
END;;
DELIMITER ;

CREATE TABLE region_managers
( employee BIGINT UNSIGNED UNIQUE
, region   BIGINT UNSIGNED PRIMARY KEY
, FOREIGN KEY (region) REFERENCES regions (ID)
, FOREIGN KEY (employee) REFERENCES employees (ID)
);

CREATE TABLE store_managers
( employee  BIGINT UNSIGNED UNIQUE
, store     BIGINT UNSIGNED PRIMARY KEY
, FOREIGN KEY (store) REFERENCES stores (ID)
, FOREIGN KEY (employee) REFERENCES employees (ID)
);

CREATE TABLE salespersons
( employee BIGINT UNSIGNED PRIMARY KEY
, store    BIGINT UNSIGNED
, job_title   VARCHAR(256) NOT NULL
, FOREIGN KEY (employee) REFERENCES employees (ID)
, FOREIGN KEY (store) REFERENCES stores (ID)
, CHECK (mysql_ignores_me_anyways)
);

DELIMITER ;;
CREATE TRIGGER salespersons_before_insert
BEFORE INSERT
ON salespersons FOR EACH ROW
BEGIN
	-- Check constraint reformulated as trigger
	--                                    (old)
	IF
		(SELECT COUNT(employee) FROM salespersons WHERE store = NEW.store)
		>=
		(SELECT max_number_of_salespersons FROM stores WHERE ID = NEW.store)
	THEN
		SIGNAL SQLSTATE '23000'
		SET MESSAGE_TEXT = 'Too many salespersons for this store';
	END IF;
END;;
DELIMITER ;

DELIMITER ;;
CREATE TRIGGER salespersons_before_update
BEFORE UPDATE
ON salespersons FOR EACH ROW
BEGIN
	-- Check constraint reformulated as trigger
	--                                    (old)
	IF
		(SELECT COUNT(employee) FROM salespersons WHERE store = NEW.store)
		>=
		(SELECT max_number_of_salespersons FROM stores WHERE ID = NEW.store)
	THEN
		SIGNAL SQLSTATE '23000'
		SET MESSAGE_TEXT = 'Too many salespersons for this store';
	END IF;
END;;
DELIMITER ;

CREATE TABLE product_categories
( product_category VARCHAR(64) PRIMARY KEY
);

CREATE TABLE products
( ID               BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY
, name             VARCHAR(256) NOT NULL
, size_magnitude   DOUBLE UNSIGNED NOT NULL
, size_unit        VARCHAR(8) NOT NULL
, price            DECIMAL(63,2) NOT NULL
, inventory_amount BIGINT UNSIGNED NOT NULL
, product_category VARCHAR(64) NOT NULL
, FOREIGN KEY (product_category) REFERENCES product_categories (product_category)
, CHECK (price >= 0)
, CHECK (inventory_amount >= 0)
);

DELIMITER ;;
CREATE TRIGGER products_before_insert
BEFORE INSERT
ON products FOR EACH ROW
BEGIN
	-- Check constraint reformulated as trigger
	IF NEW.price < 0
	THEN
		SIGNAL SQLSTATE '23000'
		SET MESSAGE_TEXT = 'Negative price';
	ELSEIF NEW.inventory_amount < 0
	THEN
		SIGNAL SQLSTATE '23000'
		SET MESSAGE_TEXT = 'Negative inventory_amount';
	END IF;
END;;
DELIMITER ;

DELIMITER ;;
CREATE TRIGGER products_before_update
BEFORE UPDATE
ON products FOR EACH ROW
BEGIN
	-- Check constraint reformulated as trigger
	IF NEW.price < 0
	THEN
		SIGNAL SQLSTATE '23000'
		SET MESSAGE_TEXT = 'Negative price';
	ELSEIF NEW.inventory_amount < 0
	THEN
		SIGNAL SQLSTATE '23000'
		SET MESSAGE_TEXT = 'Negative inventory_amount';
	END IF;
END;;
DELIMITER ;

CREATE TABLE transaction_groups
( ID          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY
, date        DATETIME NOT NULL
, salesperson BIGINT UNSIGNED NOT NULL
, customer    BIGINT UNSIGNED NOT NULL
, FOREIGN KEY (salesperson) REFERENCES salespersons (employee)
, FOREIGN KEY (customer) REFERENCES customers (ID)
);

CREATE TABLE transactions
( ID                BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY
, product           BIGINT UNSIGNED NOT NULL
, product_quantity  BIGINT UNSIGNED NOT NULL
, amount_paid       DECIMAL(63,2) NOT NULL
, transaction_group BIGINT UNSIGNED NOT NULL
, FOREIGN KEY (product) REFERENCES products (ID)
, FOREIGN KEY (transaction_group) REFERENCES transaction_groups (ID)
, CHECK (product_quantity >= 0)
);

DELIMITER ;;
CREATE TRIGGER transactions_before_insert
BEFORE INSERT
ON transactions FOR EACH ROW
BEGIN
	-- Check constraint reformulated as trigger
	IF NEW.product_quantity < 0
	THEN
		SIGNAL SQLSTATE '23000'
		SET MESSAGE_TEXT = 'Negative product_quantity';
	END IF;
END;;
DELIMITER ;

DELIMITER ;;
CREATE TRIGGER transactions_before_update
BEFORE UPDATE
ON transactions FOR EACH ROW
BEGIN
	SIGNAL SQLSTATE '23000'
	SET MESSAGE_TEXT = 'transactions is insert-only';
END;;
DELIMITER ;

DELIMITER ;;
CREATE TRIGGER transactions_before_delete
BEFORE DELETE
ON transactions FOR EACH ROW
BEGIN
	SIGNAL SQLSTATE '23000'
	SET MESSAGE_TEXT = 'transactions is insert-only';
END;;
DELIMITER ;
