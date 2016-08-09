CREATE TABLE Account
( account    VARCHAR(256) PRIMARY KEY
, password_hash CHAR(128) NOT NULL
);
CREATE TABLE Item
( item       BIGINT       PRIMARY KEY  GENERATED ALWAYS AS IDENTITY
, name       VARCHAR(256) NOT NULL
, weight     DOUBLE       NOT NULL
, unit       VARCHAR(16)  NOT NULL
, price_usd  DECIMAL(9,2) NOT NULL
, exp_date   DATE         NOT NULL
);
CREATE TABLE Item_on_shelf
( item       BIGINT       PRIMARY KEY  REFERENCES Item
);
CREATE TABLE Item_in_cart
( item       BIGINT       PRIMARY KEY  REFERENCES Item
, account    VARCHAR(256) NOT NULL     REFERENCES Account
);
CREATE TABLE Item_checked_out
( item       BIGINT       PRIMARY KEY  REFERENCES Item
);
CREATE TABLE Item_x
( item       BIGINT       PRIMARY KEY  REFERENCES Item
);
CREATE TABLE Reservn
( reservn    BIGINT       PRIMARY KEY  GENERATED ALWAYS AS IDENTITY
, account    VARCHAR(256) NOT NULL     REFERENCES Account
, cue_date   TIMESTAMP    NOT NULL
, due_date   TIMESTAMP    NOT NULL     --CHECK (due_date >= cue_date)
, address    VARCHAR(256)
);
CREATE TABLE Reservn_checked_out
( reservn    BIGINT       PRIMARY KEY  REFERENCES Reservn
);
CREATE TABLE Reservn_unchecked_out
( reservn    BIGINT       PRIMARY KEY  REFERENCES Reservn
);
CREATE TABLE Reservn_x
( reservn    BIGINT       PRIMARY KEY  REFERENCES Reservn
);
CREATE TABLE Reservn_Item
( reservn    BIGINT       NOT NULL     REFERENCES Reservn
, item       BIGINT       NOT NULL     REFERENCES Item
, PRIMARY KEY (reservn, item)
);
Insert into Item(name, weight, unit, price_usd, exp_date) values('bananas'           ,  2.13, 'lb', 1.07, '2016-02-12');
Insert into Item(name, weight, unit, price_usd, exp_date) values('bananas'           ,  2.03, 'lb', 1.02, '2016-02-14');
Insert into Item(name, weight, unit, price_usd, exp_date) values('carrots'           ,  4.93, 'lb', 3.45, '2016-03-09');
Insert into Item(name, weight, unit, price_usd, exp_date) values('carrots'           ,  5.01, 'lb', 3.51, '2016-03-16');
Insert into Item(name, weight, unit, price_usd, exp_date) values('carrots'           , 10.01, 'lb', 7.01, '2016-03-09');
Insert into Item(name, weight, unit, price_usd, exp_date) values('chicken breasts'   ,  2.01, 'lb', 5.03, '2016-02-09');
Insert into Item(name, weight, unit, price_usd, exp_date) values('chicken breasts'   ,  2.09, 'lb', 5.23, '2016-02-09');
Insert into Item(name, weight, unit, price_usd, exp_date) values('chicken breasts'   ,  2.03, 'lb', 5.08, '2016-02-09');
Insert into Item(name, weight, unit, price_usd, exp_date) values('chicken breasts'   ,  1.93, 'lb', 4.83, '2016-02-09');
Insert into Item(name, weight, unit, price_usd, exp_date) values('chicken breasts'   ,  2.21, 'lb', 5.53, '2016-02-09');
Insert into Item(name, weight, unit, price_usd, exp_date) values('chicken breasts'   ,  2.05, 'lb', 5.13, '2016-02-09');
Insert into Item(name, weight, unit, price_usd, exp_date) values('eggs (12)'         ,  1.69, 'lb', 1.69, '2016-03-02');
Insert into Item(name, weight, unit, price_usd, exp_date) values('eggs (12)'         ,  1.70, 'lb', 1.69, '2016-03-04');
Insert into Item(name, weight, unit, price_usd, exp_date) values('eggs (18)'         ,  2.55, 'lb', 2.54, '2016-03-04');
Insert into Item(name, weight, unit, price_usd, exp_date) values('eggs (12)'         ,  1.70, 'lb', 1.69, '2016-03-09');
Insert into Item(name, weight, unit, price_usd, exp_date) values('milk (reduced-fat)',  8.60, 'lb', 3.79, '2016-02-14');
Insert into Item(name, weight, unit, price_usd, exp_date) values('milk (reduced-fat)',  8.60, 'lb', 3.79, '2016-02-15');
Insert into Item(name, weight, unit, price_usd, exp_date) values('milk (skim)'       ,  8.60, 'lb', 3.79, '2016-02-15');
Insert into Item(name, weight, unit, price_usd, exp_date) values('onions'            ,  2.41, 'lb', 3.62, '2016-03-20');
Insert into Item(name, weight, unit, price_usd, exp_date) values('onions'            ,  2.53, 'lb', 3.80, '2016-03-20');
Insert into Item(name, weight, unit, price_usd, exp_date) values('oranges (12)'      ,  4.37, 'lb', 6.56, '2016-02-22');
Insert into Item(name, weight, unit, price_usd, exp_date) values('oranges (12)'      ,  4.52, 'lb', 6.78, '2016-02-20');
Insert into Item(name, weight, unit, price_usd, exp_date) values('rice'              , 10.00, 'lb', 5.00, '2020-01-15');
Insert into Item(name, weight, unit, price_usd, exp_date) values('rice'              ,  9.98, 'lb', 5.00, '2020-08-25');
Insert into Item(name, weight, unit, price_usd, exp_date) values('tomatoes'          ,  2.51, 'lb', 5.02, '2016-02-14');
Insert into Item(name, weight, unit, price_usd, exp_date) values('tomatoes'          ,  2.47, 'lb', 4.94, '2016-02-14');
Insert into Item(name, weight, unit, price_usd, exp_date) values('tomatoes'          ,  2.53, 'lb', 5.06, '2016-02-14');
Insert into Item_on_shelf select item from Item;
Insert into Account values('leon', '3c9909afec25354d551dae21590bb26e38d53f2173b8d3dc3eee4c047e7ab1c1eb8b85103e3be7ba613b31bb5c9c36214dc9f14a42fd7a2fdb84856bca5c44c2');