# Clear table
TRUNCATE new_schema.marioorderdata01;

LOAD DATA INFILE 'C:/Fontys/Code/MarioOrderData01_Modified.csv'
	INTO TABLE new_schema.marioorderdata01
	FIELDS TERMINATED BY ';' 
	LINES TERMINATED BY '\n'
	IGNORE 1 LINES;

SELECT * FROM new_schema.marioorderdata01;

# replace store names with location IDs 
# marios_pizza.shop
UPDATE new_schema.marioorderdata01 tempDB
	SET Winkelnaam =  ( SELECT ID
							FROM marios_pizza.shop destDB
							WHERE destDB.Name = tempDB.Winkelnaam
						)
	WHERE Winkelnaam IN ( SELECT Name 
							FROM marios_pizza.shop destDB)
    ;

SELECT * FROM new_schema.marioorderdata01;

# replace customer with customer ID (Upsert - https://thispointer.com/insert-into-a-mysql-table-or-update-if-exists/)
INSERT IGNORE INTO Marios_pizza.customer (Name, Birthdate, Email, Phone1, Phone2, CreatedOn, CreatedBy, LastUpdate, UpdateBy, Deleted)
SELECT Klantnaam as Name, null as Birthdate, Email, TelefoonNr as Phone1, null as Phone2, '2021-10-06 18:29:54' as CreatedOn,'System - import' as CreatedBy,'2021-10-06 18:29:54' as LastUpdate,'System - import' as UpdateBy ,0 as Deleted FROM new_schema.marioorderdata01 AS srcTable
;

SELECT * FROM marios_pizza.customer;

# Updating temp table with customer IDs, dureation: 1119.063 sec
UPDATE new_schema.marioorderdata01 srcTable
	SET Klantnaam =  ( SELECT ID
							FROM marios_pizza.customer as destTable
							WHERE destTable.Name = srcTable.Klantnaam
						)
	WHERE Klantnaam IN ( SELECT Name 
							FROM marios_pizza.customer as destTable)
    ;

SELECT * FROM new_schema.marioorderdata01;
SELECT * FROM marios_pizza.customer;

# Cleaning up data that is already stored:
UPDATE new_schema.marioorderdata01 srcTable
	SET TelefoonNr = null,
		Email = null;
        
# replacing addresses with IDs
# First start filling the marios_pizza.addressinfo from new_schema.marioorderdata01 srcTable
# ID, HouseNumber, Address, Zipcode, City, CreatedOn, CreatedBy, LastUpdate, UpdateBy, Deleted
SELECT * FROM marios_pizza.addressinfo;
SELECT * FROM new_schema.marioorderdata01 LIMIT 10;

# TODO: Update ZipCode
INSERT IGNORE INTO Marios_pizza.addressinfo (HouseNumber, Address, Zipcode, City, CreatedOn, CreatedBy, LastUpdate, UpdateBy, Deleted)
	SELECT DISTINCT regexp_substr(Adres, '[0-9]+$') AS HouseNumber, 
					LEFT(Adres, LENGTH(Adres) - LOCATE(' ', REVERSE(Adres))+1) AS Address,
                    null as Zipcode,
                    Woonplaats as City,
                    '2021-10-06 18:29:54' as CreatedOn,
                    'System - import' as CreatedBy,
                    '2021-10-06 18:29:54' as LastUpdate,
                    'System - import' as UpdateBy ,
                    0 as Deleted
				FROM new_schema.marioorderdata01 AS srcTable
				;

# correlation update temp table
SELECT * FROM marios_pizza.addressinfo;
UPDATE new_schema.marioorderdata01 as destTable
	SET Adres =  ( SELECT ID
							FROM marios_pizza.addressinfo as srcTable
							WHERE srcTable.Address = LEFT(destTable.Adres, LENGTH(destTable.Adres) - LOCATE(' ', REVERSE(destTable.Adres))+1)
                            AND
                            srcTable.City = destTable.Woonplaats
                            AND
							srcTable.HouseNumber = regexp_substr(destTable.Adres, '[0-9]+$')
						),
		Woonplaats = null					
    ;
SELECT * FROM new_schema.marioorderdata01 LIMIT 10; # 294 sec

# Customer address info koppel tabel
# ID, Customer_ID, AddressInfo_ID, CreatedOn, CreatedBy, LastUpdate, UpdateBy, Deleted
SELECT * FROM marios_pizza.customer_addressinfo;
SELECT * FROM new_schema.marioorderdata01 LIMIT 10;

# Updating temptable with ID of customer address
INSERT INTO marios_pizza.customer_addressinfo (Customer_ID, AddressInfo_ID, CreatedOn, CreatedBy, LastUpdate, UpdateBy, Deleted)
	SELECT DISTINCT Klantnaam as Customer_ID
						, Adres as AddressInfo_ID
						, '2021-10-06 18:29:54' as CreatedOn
						, 'System - import' as CreatedBy
						, '2021-10-06 18:29:54' as LastUpdate
						, 'System - import' as UpdateBy
						, 0 as Deleted
                           FROM new_schema.marioorderdata01;
	
SELECT *
	FROM marios_pizza.customer_addressinfo;

# Coupons aanmaken
# Determing if a value is null or empty or something else
# We only want values that have a value
SELECT *
	FROM new_schema.marioorderdata01
    LIMIT 10
    ;

# Show only fields that have a value other then null or ''
# Select only unique coupons
SELECT DISTINCT `Gebruikte Coupon`, CONVERT(`Gebruikte Coupon` USING ASCII) AS filterOudWeirdCharacters
	FROM new_schema.marioorderdata01
	WHERE `Gebruikte Coupon` > ''
	LIMIT 100
    ;

# Function for UUID
-- Change delimiter so that the function body doesn't end the function declaration
DELIMITER //

CREATE FUNCTION uuid_v4()
    RETURNS CHAR(36) NO SQL
BEGIN
    -- Generate 8 2-byte strings that we will combine into a UUIDv4
    SET @h1 = LPAD(HEX(FLOOR(RAND() * 0xffff)), 4, '0');
    SET @h2 = LPAD(HEX(FLOOR(RAND() * 0xffff)), 4, '0');
    SET @h3 = LPAD(HEX(FLOOR(RAND() * 0xffff)), 4, '0');
    SET @h6 = LPAD(HEX(FLOOR(RAND() * 0xffff)), 4, '0');
    SET @h7 = LPAD(HEX(FLOOR(RAND() * 0xffff)), 4, '0');
    SET @h8 = LPAD(HEX(FLOOR(RAND() * 0xffff)), 4, '0');

    -- 4th section will start with a 4 indicating the version
    SET @h4 = CONCAT('4', LPAD(HEX(FLOOR(RAND() * 0x0fff)), 3, '0'));

    -- 5th section first half-byte can only be 8, 9 A or B
    SET @h5 = CONCAT(HEX(FLOOR(RAND() * 4 + 8)),
                LPAD(HEX(FLOOR(RAND() * 0x0fff)), 3, '0'));

    -- Build the complete UUID
    RETURN LOWER(CONCAT(
        @h1, @h2, '-', @h3, '-', @h4, '-', @h5, '-', @h6, @h7, @h8
    ));
END
//
-- Switch back the delimiter
DELIMITER ;

SELECT * FROM marios_pizza.coupon;

# Importing coupons to coupon table
INSERT INTO marios_pizza.coupon (Code, DiscountPercentage, Discountprice, Description, Active, StartDate, EndDate, CreatedOn, CreatedBy, LastUpdate, UpdateBy, Deleted)
	SELECT  uuid_v4() as Code
			, null as DiscountPercentage
            , null as DiscountPrice
            , null as CouponFormula
            , srcTable.* 
				FROM (SELECT DISTINCT `Gebruikte Coupon` AS Description 
					, 1 as Active
					, '2021-10-01 00:00:01' as StartDate
                    , null as EndDate
					, '2021-10-10 18:29:54' as CreatedOn
					, 'System - import' as CreatedBy
					, '2021-10-10 18:29:54' as LastUpdate
					, 'System - import' as UpdateBy
					, 0 as Deleted
                       FROM new_schema.marioorderdata01	WHERE `Gebruikte Coupon` > ''  ) as srcTable
	;

SELECT * FROM marios_pizza.coupon;

# Formula correcting
# 25% korting
SELECT DiscountPercentage FROM marios_pizza.coupon WHERE Code = 'f70c5f96-f8c9-40f9-924b-bd2cc781ae05';

# 3de pizza gratis
SELECT COUNT(*) FROM marios_pizza.coupon ;

# Update temp table with coupon IDs
SELECT *
	FROM new_schema.marioorderdata01
    LIMIT 10
    ;

UPDATE new_schema.marioorderdata01 AS destTable
	SET `Gebruikte Coupon` =  ( SELECT ID
							FROM marios_pizza.coupon srcTable
							WHERE srcTable.Description = destTable.`Gebruikte Coupon` AND destTable.`Gebruikte Coupon` > ''
						)
    ;    

SELECT * FROM new_schema.marioorderdata01 WHERE `Gebruikte Coupon` > '';
    
# Aflevertype
SELECT AfleverType FROM new_schema.marioorderdata01;
SELECT * FROM marios_pizza.deliverytype;

INSERT INTO marios_pizza.deliverytype (Type, Active, CreatedOn, CreatedBy, LastUpdate, UpdateBy, Deleted)
	SELECT DISTINCT AfleverType	AS Type
					, 1 as Active
					, '2021-10-10 18:29:54' as CreatedOn
					, 'System - import' as CreatedBy
					, '2021-10-10 18:29:54' as LastUpdate
					, 'System - import' as UpdateBy
					, 0 as Deleted
                    FROM new_schema.marioorderdata01
    ;

SELECT * FROM marios_pizza.deliverytype;
SELECT * FROM new_schema.marioorderdata01;

# Update temp source table
UPDATE new_schema.marioorderdata01 AS destTable
	SET `AfleverType` =  ( SELECT srcTable.ID
							FROM marios_pizza.deliverytype srcTable
							WHERE destTable.`AfleverType` = srcTable.`Type` AND destTable.`AfleverType` > ''
						)
    ;    

# test case query
SELECT srcTable.ID
	FROM marios_pizza.deliverytype srcTable, new_schema.marioorderdata01 destTable
	WHERE destTable.`AfleverType` = srcTable.`Type` AND destTable.`AfleverType` > ''
    ;

# Orders
# ID, OrderStatus, DeliveryPlan, DeliveryTime, DeliveryPrice, Customer_Id, DeliveryType_ID, Shop_ID, OrderDate, TotalOrderPrice, CreatedOn, CreatedBy, LastUpdate, UpdateBy, Deleted

# This results should be orders
SELECT *
	FROM new_schema.marioorderdata01 srcTable
    WHERE Klantnaam IN (12)
    GROUP BY Klantnaam, AfleverDatum, Aflevermoment
    ORDER BY Klantnaam
    ;

# For each customer and each order make an order
# (OrderStatus, DeliveryPlan, DeliveryTime, DeliveryPrice, Customer_Id, DeliveryType_ID, Shop_ID, OrderDate, TotalOrderPrice, CreatedOn, CreatedBy, LastUpdate, UpdateBy, Deleted)
INSERT INTO marios_pizza.order
	SELECT  		CASE	
						WHEN srcTable.AfleverMoment > '' THEN 0
                        WHEN srcTable.AfleverMoment IS NULL OR srcTable.AfleverMoment = ''  THEN 1
					END AS OrderStatus
					, null AS DeliveryPlan
					, str_to_date(@datum, '%d %M %Y %T') AS DeliveryTime
					, '2021-10-10 18:29:54' as CreatedOn
					, 'System - import' as CreatedBy
					, '2021-10-10 18:29:54' as LastUpdate
					, 'System - import' as UpdateBy
					, 0 as Deleted
					FROM new_schema.marioorderdata01 srcTable
					WHERE Klantnaam IN (12)
					GROUP BY Klantnaam, AfleverDatum, Aflevermoment
    ;

SELECT cast(concat('donderdag 13 april 2017', ' ', '19:17') as datetime) AS Jemoeder;

SET lc_time_names = 'nl_NL';
SELECT ID, srcTable.AfleverDatum, srcTable.AfleverMoment, SUBSTRING_INDEX(srcTable.AfleverDatum, ' ',-3), CONCAT(SUBSTRING_INDEX(srcTable.AfleverDatum, ' ',-3), ' ', srcTable.AfleverMoment, ':00'), str_to_date(CONCAT(SUBSTRING_INDEX(srcTable.AfleverDatum, ' ',-3), ' ', srcTable.AfleverMoment, ':00'), '%d %M %Y %T') FROM new_schema.marioorderdata01 srcTable;
SET lc_time_names = 'en_US';

SET lc_time_names = 'nl_NL';
SELECT DATE_FORMAT('5 july 2019 20:05', '%d %M %Y %T');

SET lc_time_names = 'nl_NL';
SET @datum = '13 april 2017 19:17';
SELECT @@LC_Time_names;
SELECT SUBSTRING_INDEX(@datum, ' ',-3) AS newValue;
SELECT str_to_date(@datum, '%d %M %Y %T') AS Mama;

SET lc_time_names = 'en_US';

# sum regelprijs is totaalprijs - Coupon korting, coupon korting is niet altijd ingevuld maar klant heeft dan wel korting
SELECT *
	FROM new_schema.marioorderdata01 srcTable
    WHERE Klantnaam = 12


# Order regels











