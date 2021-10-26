DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_derive_Coupons_From_OrderData_And_Insert`()
BEGIN
	INSERT IGNORE
INTO marios_pizza.coupon(Code, DiscountPercentage, Discountprice, CouponFormula, Description, Active, StartDate, EndDate, CreatedOn, CreatedBy, LastUpdate, UpdateBy, Deleted)
SELECT uuid_v4() AS Code
	,NULL AS DiscountPercentage
	,NULL AS DiscountPrice
	,NULL AS CouponFormula
	,srcTable.*
FROM (
	SELECT `Gebruikte Coupon` AS Description
		,1 AS Active
		,'2021-10-01 00:00:01' AS StartDate
		,NULL AS EndDate
		,CURRENT_TIMESTAMP AS CreatedOn
		,'System - import' AS CreatedBy
		,CURRENT_TIMESTAMP AS LastUpdate
		,'System - import' AS UpdateBy
		,0 AS Deleted
	FROM marios_pizza.marioorderdata01
	WHERE `Gebruikte Coupon` > ''
	GROUP BY `Gebruikte Coupon`
	) AS srcTable
    ;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_derive_DeliverType_from_OrderData`()
BEGIN
	INSERT INTO marios_pizza.deliverytype (Type, Active, CreatedOn, CreatedBy, LastUpdate, UpdateBy, Deleted)
	SELECT AfleverType	AS Type
					, 1 as Active
					, CURRENT_TIMESTAMP as CreatedOn
					, 'System - import' as CreatedBy
					, CURRENT_TIMESTAMP as LastUpdate
					, 'System - import' as UpdateBy
					, 0 as Deleted
                    FROM marios_pizza.marioorderdata01
                    GROUP BY AfleverType
    ;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_derive_Nonpizza_products_from_mariooverigeproducten`()
BEGIN
	SET FOREIGN_KEY_CHECKS=0;
	TRUNCATE marios_pizza.`addressinfo`;
	SET FOREIGN_KEY_CHECKS=1;
    
	INSERT INTO marios_pizza.nonpizza (Name, Description, Active, Tax_ID, SubCategory_ID, CreatedOn, CreatedBy, LastUpdate, UpdateBy, Deleted)
	SELECT srcTable.productnaam AS Name
			, srcTable.productomschrijvingFiltered AS Description
            , 1 AS Active
            , 1 AS Tax_ID
            , srcTable.subcategorieID AS SubCategory_ID
            , CURRENT_TIMESTAMP AS CreatedOn
			, 'System - import' AS CreatedBy
			, CURRENT_TIMESTAMP AS LastUpdate
			, 'System - import' AS UpdateBy
			, 0 AS Deleted
    FROM marios_pizza.mariooverigeproducten srcTable
;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_derive_OrderItems_From_OrderData`()
BEGIN
INSERT INTO marios_pizza.orderitem (OrderID, Pizza_ID, NonPizza_ID, OrderName, Amount, TotalPrice, Tax, CreatedOn, CreatedBy, LastUpdate, UpdateBy, Deleted)
	SELECT srcTable.OrderID as OrderID
		, srcTable.ProductID as Pizza_ID
        , srcTable.nonProductID as NonPizza_ID
        , srcTable.Product AS OrderName
        , srcTable.Aantal as Amount
        , srcTable.regelprijs as TotalPrice
        , 0 as Tax
		, CURRENT_TIMESTAMP AS CreatedOn
		, 'System - import' AS CreatedBy
		, CURRENT_TIMESTAMP AS LastUpdate
		, 'System - import' AS UpdateBy
		, 0 as Deleted
	FROM marios_pizza.marioorderdata01 AS srcTable
    WHERE srcTable.OrderID IS NOT NULL
	;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_derive_Orders_From_MarioData`()
BEGIN
	INSERT INTO marios_pizza.order (OrderStatus, DeliveryPlan, DeliveryTime, DeliveryPrice, Customer_Id, DeliveryType_ID, Shop_ID, OrderDate, TotalOrderPrice, CreatedOn, CreatedBy, LastUpdate, UpdateBy, Deleted)
   SELECT  		CASE	
						WHEN srcTable.AfleverMoment > '' THEN 0
                        WHEN srcTable.AfleverMoment IS NULL OR srcTable.AfleverMoment = ''  THEN 1
					END AS OrderStatus
					, func_dateTime_to_TimeStamp(AfleverDatum,Aflevermoment) AS DeliveryPlan
					, func_dateTime_to_TimeStamp(AfleverDatum,Aflevermoment) AS DeliveryTime
                    , CONVERT(Bezorgkosten, FLOAT) AS DeliveryPrice
                    , CustomerID AS Customer_Id
                    , DeliveryTypeID AS DeliveryType_ID
                    , WinkelID AS Shop_ID
                    , func_dateTime_to_TimeStamp(Besteldatum,'00:00') AS OrderDate
                    , TotaalprijsDecimal AS TotalOrderPrice
					, CURRENT_TIMESTAMP AS CreatedOn
					, 'System - import' AS CreatedBy
					, CURRENT_TIMESTAMP AS LastUpdate
					, 'System - import' AS UpdateBy
					, 0 as Deleted
					FROM marios_pizza.marioorderdata01 srcTable
                    WHERE Afleverdatum not like '%,%'
					GROUP BY Email, AfleverDatum, Aflevermoment
     ;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_Fill_category`()
BEGIN
			SET FOREIGN_KEY_CHECKS=0;
	TRUNCATE marios_pizza.category;
	SET FOREIGN_KEY_CHECKS=1;


	INSERT INTO marios_pizza.category (Name, Description, Active, CreatedOn, CreatedBy, LastUpdate, UpdateBy, Deleted)
VALUES ('Specials & Pasta\'s','' , 1, CURRENT_TIMESTAMP, 'System - import', CURRENT_TIMESTAMP, 'System - import', 0)
		,('Drinks & Desserts','' , 1, CURRENT_TIMESTAMP, 'System - import', CURRENT_TIMESTAMP, 'System - import', 0)
		,('Pizza\'s','' , 1, CURRENT_TIMESTAMP, 'System - import', CURRENT_TIMESTAMP, 'System - import', 0)
;

UPDATE marios_pizza.category
SET Description =  REGEXP_REPLACE(Name, '[\]\\[!@#$%.&*`~^_{}:;<>\'/\\|()-]+', '')
;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_Fill_pizza`()
BEGIN
	SET FOREIGN_KEY_CHECKS=0;
	TRUNCATE marios_pizza.pizza;
	SET FOREIGN_KEY_CHECKS=1;

INSERT INTO marios_pizza.pizza (Name, Sauce_ID, PizzaBottom_ID, IsCustom, SubCategory_ID, Active, Description, Price, CreatedOn, CreatedBy, LastUpdate, UpdateBy, Deleted)
SELECT destTable.productnaam AS Name
		, sauceTable.ID AS Sauce_ID
        , 2 as PizzaBottom_ID
        , 0 AS IsCustom
        , destTable.subcategorie AS SubCategory_ID
        , 1 AS Active
        , destTable.productomschrijving AS Description
        , destTable.prijs AS Price
        , CURRENT_TIMESTAMP AS CreatedOn
        , 'System - import' AS CreatedBy
        , CURRENT_TIMESTAMP AS LastUpdate
        , 'System - import' AS UpdateBy
        , 0 AS Deleted
 FROM marios_pizza.mariopizza_ingredienten AS destTable
 JOIN marios_pizza.sauce AS sauceTable ON destTable.pizzasaus_standaard = sauceTable.Name
 JOIN marios_pizza.ingredient AS ingredientTable ON destTable.ingredientnaam = ingredientTable.Name
 JOIN marios_pizza.subcategory AS subcatTable ON destTable.subcategorie = subcatTable.ID
 GROUP BY destTable.Productnaam
 ; 

END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_Fill_pizza_ingredient`()
BEGIN
	SET FOREIGN_KEY_CHECKS=0;
	TRUNCATE marios_pizza.pizza_ingredient;
	SET FOREIGN_KEY_CHECKS=1;

	INSERT INTO marios_pizza.pizza_ingredient (Pizza_ID, Ingredient_ID, Price, CreatedOn, CreatedBy, LastUpdate, UpdateBy, Deleted)
	SELECT 	pizzaTable.ID AS Pizza_ID
		, ingredientTable.ID AS Ingredient_ID
        , pizzaTable.Price as Price
        , CURRENT_TIMESTAMP AS CreatedOn
        , 'System - import' AS CreatedBy
        , CURRENT_TIMESTAMP AS LastUpdate
        , 'System - import' AS UpdateBy
        , 0 AS Deleted
	FROM marios_pizza.mariopizza_ingredienten AS destTable
	JOIN marios_pizza.sauce AS sauceTable ON destTable.pizzasaus_standaard = sauceTable.Name
	JOIN marios_pizza.ingredient AS ingredientTable ON destTable.ingredientnaam = ingredientTable.Name
	JOIN marios_pizza.subcategory AS subcatTable ON destTable.subcategorie = subcatTable.ID
	JOIN marios_pizza.pizza AS pizzaTable ON destTable.productnaam = pizzaTable.Name
	ORDER BY destTable.productnaam
	;

END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_Fill_pizzaBottom`()
BEGIN
	SET FOREIGN_KEY_CHECKS=0;
	TRUNCATE marios_pizza.pizzabottom;
	SET FOREIGN_KEY_CHECKS=1;

	INSERT INTO marios_pizza.pizzabottom (Name, Size, Active, Price, Tax_ID, PizzaBottomType_ID, CreatedOn, CreatedBy, LastUpdate, UpdateBy, Deleted)
		VALUES ('Medium Cheesy Crust', 25, 1, 2.00, 1,1, CURRENT_TIMESTAMP, 'System - import', CURRENT_TIMESTAMP, 'System - import', 0)
		,('Medium', 25, 1, 0.00, 1, 2, CURRENT_TIMESTAMP, 'System - import', CURRENT_TIMESTAMP, 'System - import', 0)
        ,('Large', 35, 1, 4.00, 1, 3, CURRENT_TIMESTAMP, 'System - import', CURRENT_TIMESTAMP, 'System - import', 0)
        ,('Family XXL', 40, 1, 5.00, 1, 4, CURRENT_TIMESTAMP, 'System - import', CURRENT_TIMESTAMP, 'System - import', 0)
        ,('Italian', 30, 1, 1.00, 1, 5, CURRENT_TIMESTAMP, 'System - import', CURRENT_TIMESTAMP, 'System - import', 0)
        ,('Medium Fresh Pan', 25, 1, 1.00, 1, 6, CURRENT_TIMESTAMP, 'System - import', CURRENT_TIMESTAMP, 'System - import', 0)
;

END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_Fill_pizzaBottomType_Table`()
BEGIN
	SET FOREIGN_KEY_CHECKS=0;
	TRUNCATE marios_pizza.pizzabottomtype;
	SET FOREIGN_KEY_CHECKS=1;
    
	INSERT ignore INTO marios_pizza.pizzabottomtype (Name, Description, Active, CreatedOn, CreatedBy, LastUpdate, UpdateBy, Deleted)
	VALUES 	('Medium Cheesy Crust', 'Ambachtelijk uitgeslagen bodem van vers deeg (25 cm). De rand van deze pizza is gevuld met smakelijke gesmolten kaas met kruiden.', 1, CURRENT_TIMESTAMP, 'System - import', CURRENT_TIMESTAMP, 'System - import', 0)
			,(	'Medium', 'Deze klassieke bodem van Domino’s worden ambachtelijk uitgeslagen van ons verse deeg. Met de hand gevormd tot een perfecte bodem.', 1, CURRENT_TIMESTAMP, 'System - import', CURRENT_TIMESTAMP, 'System - import', 0)
			,(	'Large', 'Deze klassieke bodem van Domino’s worden ambachtelijk uitgeslagen van ons verse deeg. Met de hand gevormd tot een perfecte bodem.', 1, CURRENT_TIMESTAMP, 'System - import', CURRENT_TIMESTAMP, 'System - import', 0)
			,(	'Family XXL', 'Deze klassieke bodem van Domino’s worden ambachtelijk uitgeslagen van ons verse deeg. Met de hand gevormd tot een perfecte bodem.', 1, CURRENT_TIMESTAMP, 'System - import', CURRENT_TIMESTAMP, 'System - import', 0)
			,(	'Italian', 'Traditioneel dun uitgeslagen 30 centimeter bodem van vers Domino’s deeg. Lekker dun en krokant gebakken. Met oregano.', 1, CURRENT_TIMESTAMP, 'System - import', CURRENT_TIMESTAMP, 'System - import', 0)
			,(	'Medium Fresh Pan', 'De panpizza van Domino’s is een dikke, luchtige bodem van 25 centimeter met een knapperig korstje van boter en kruiden. In een pannetje gebakken.', 1, CURRENT_TIMESTAMP, 'System - import', CURRENT_TIMESTAMP, 'System - import', 0)
        ;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_Fill_sauce`()
BEGIN
	SET FOREIGN_KEY_CHECKS=0;
	TRUNCATE marios_pizza.sauce;
	SET FOREIGN_KEY_CHECKS=1;

	INSERT INTO marios_pizza.sauce (Name, Description, Price, Active, Tax_ID, CreatedOn, CreatedBy, LastUpdate, UpdateBy, Deleted)
	VALUES ('Tomatensaus', '', 0.00, 1, 1, CURRENT_TIMESTAMP, 'System - import', CURRENT_TIMESTAMP, 'System - import', 0)
		, ('Creme Fraiche', '', 0.00, 1, 1, CURRENT_TIMESTAMP, 'System - import', CURRENT_TIMESTAMP, 'System - import', 0)
		, ('Barbecue Saus', '', 0.00, 1, 1, CURRENT_TIMESTAMP, 'System - import', CURRENT_TIMESTAMP, 'System - import', 0)
; 

END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_Fill_subcategory`()
BEGIN
		SET FOREIGN_KEY_CHECKS=0;
	TRUNCATE marios_pizza.subcategory;
	SET FOREIGN_KEY_CHECKS=1;

INSERT INTO marios_pizza.subcategory (Name, Description, Active, Categorie_ID, CreatedOn, CreatedBy, LastUpdate, UpdateBy, Deleted)
VALUES ('Famous Artisan Pizza’s','',1,3, CURRENT_TIMESTAMP, 'System - import', CURRENT_TIMESTAMP, 'System - import', 0)
,("Top Taste Pizza's",'',1,3, CURRENT_TIMESTAMP, 'System - import', CURRENT_TIMESTAMP, 'System - import', 0)
,('BBQ Specials','',1,3, CURRENT_TIMESTAMP, 'System - import', CURRENT_TIMESTAMP, 'System - import', 0)
,("Pasta's",'',1,1, CURRENT_TIMESTAMP, 'System - import', CURRENT_TIMESTAMP, 'System - import', 0)
,('Kip, Wedges & Sausjes','',1,1, CURRENT_TIMESTAMP, 'System - import', CURRENT_TIMESTAMP, 'System - import', 0)
,('Broodproducten','',1,1, CURRENT_TIMESTAMP, 'System - import', CURRENT_TIMESTAMP, 'System - import', 0)
,('Salade','',1,1, CURRENT_TIMESTAMP, 'System - import', CURRENT_TIMESTAMP, 'System - import', 0)
,('Desserts','',1,2, CURRENT_TIMESTAMP, 'System - import', CURRENT_TIMESTAMP, 'System - import', 0)
,('Drinks','',1,2, CURRENT_TIMESTAMP, 'System - import', CURRENT_TIMESTAMP, 'System - import', 0)
;

UPDATE marios_pizza.subcategory
SET Description =  REGEXP_REPLACE(Name, '[\]\\[!@#$%.&*`~^_{}:;’<>\'/\\|()-]+', '');
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_insert_customer_address_info_from_marioorderdata`()
BEGIN
	INSERT IGNORE
INTO marios_pizza.customer_addressinfo (Customer_ID, AddressInfo_ID, CreatedOn, CreatedBy, LastUpdate, UpdateBy, Deleted)
SELECT destTable.CustomerID AS Customer_ID
	,srcTable.ID AS AddressInfo_ID
	,CURRENT_TIMESTAMP AS CreatedOn
	,'System - import' AS CreatedBy
	,CURRENT_TIMESTAMP AS LastUpdate
	,'System - import' AS UpdateBy
	,0 AS Deleted
FROM marios_pizza.marioorderdata01 AS destTable
JOIN marios_pizza.addressinfo AS srcTable ON LEFT(destTable.Adres, LENGTH(destTable.Adres) - LOCATE(' ', REVERSE(destTable.Adres)) + 1) = srcTable.Address
	AND destTable.Woonplaats = srcTable.City
	AND regexp_substr(destTable.Adres, '[0-9]+$') = srcTable.HouseNumber
GROUP BY Email;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_Insert_New_Customers`()
BEGIN
	INSERT IGNORE
	INTO Marios_pizza.customer(Name, Birthdate, Email, Phone1, Phone2, CreatedOn, CreatedBy, LastUpdate, UpdateBy, Deleted)
	SELECT Klantnaam AS Name
		,NULL AS Birthdate
		,Email
		,TelefoonNr AS Phone1
		,NULL AS Phone2
		,CURRENT_TIMESTAMP AS CreatedOn
		,'System - import' AS CreatedBy
		,CURRENT_TIMESTAMP AS LastUpdate
		,'System - import' AS UpdateBy
		,0 AS Deleted
	FROM marios_pizza.marioorderdata01 AS srcTable
    GROUP BY Email
    ;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_insertCustomerAddress`()
BEGIN
INSERT IGNORE INTO Marios_pizza.addressinfo(HouseNumber, Address, Zipcode, City, CreatedOn, CreatedBy, LastUpdate, UpdateBy, Deleted)
SELECT regexp_substr(Adres, '[0-9]+$') AS HouseNumber
	,LEFT(Adres, LENGTH(Adres) - LOCATE(' ', REVERSE(Adres)) + 1) AS Address
	,NULL AS Zipcode
	,Woonplaats AS City
	,CURRENT_TIMESTAMP AS CreatedOn
	,'System - import' AS CreatedBy
	,CURRENT_TIMESTAMP AS LastUpdate
	,'System - import' AS UpdateBy
	,0 AS Deleted
FROM marios_pizza.marioorderdata01 AS srcTable
GROUP BY Woonplaats
	,Adres;

END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_truncate_all_tables`()
BEGIN
	SET FOREIGN_KEY_CHECKS=0;
	TRUNCATE marios_pizza.`addressinfo`;
	TRUNCATE marios_pizza.`category`;
	TRUNCATE marios_pizza.`city`;
	TRUNCATE marios_pizza.`coupon`;
	TRUNCATE marios_pizza.`customer`;
	TRUNCATE marios_pizza.`customer_addressinfo`;
	TRUNCATE marios_pizza.`deliverytype`;
	TRUNCATE marios_pizza.`differentopeningtime`;
	TRUNCATE marios_pizza.`ingredient`;
	TRUNCATE marios_pizza.`item_property`;
	TRUNCATE marios_pizza.`marioorderdata01`;
	TRUNCATE marios_pizza.`municipality`;
	TRUNCATE marios_pizza.`nonpizza`;
	TRUNCATE marios_pizza.`openingtime`;
	TRUNCATE marios_pizza.`order`;
	TRUNCATE marios_pizza.`order_coupon`;
	TRUNCATE marios_pizza.`orderitem`;
	TRUNCATE marios_pizza.`pizza`;
	TRUNCATE marios_pizza.`pizza_ingredient`;
	TRUNCATE marios_pizza.`pizzabottom`;
	TRUNCATE marios_pizza.`pizzabottomtype`;
	TRUNCATE marios_pizza.`property`;
	TRUNCATE marios_pizza.`sauce`;
	TRUNCATE marios_pizza.`servicearea`;
	TRUNCATE marios_pizza.`shop`;
	TRUNCATE marios_pizza.`street`;
	TRUNCATE marios_pizza.`subcategory`;
	TRUNCATE marios_pizza.`tax`;
	SET FOREIGN_KEY_CHECKS=1;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_truncate_partial_tables`()
BEGIN
	SET FOREIGN_KEY_CHECKS=0;
	TRUNCATE marios_pizza.`coupon`;
	TRUNCATE marios_pizza.`customer`;
	TRUNCATE marios_pizza.`customer_addressinfo`;
	TRUNCATE marios_pizza.`deliverytype`;
	TRUNCATE marios_pizza.`marioorderdata01`;
	TRUNCATE marios_pizza.`order`;
	TRUNCATE marios_pizza.`order_coupon`;
	TRUNCATE marios_pizza.`orderitem`;
    TRUNCATE marios_pizza.`addressinfo`;
	SET FOREIGN_KEY_CHECKS=1;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_update_CategoryID_mariooverigeproducten`()
BEGIN
	UPDATE marios_pizza.mariooverigeproducten destTable
		JOIN marios_pizza.category AS catTable ON categorie = catTable.Name
		SET destTable.categorieID = catTable.ID
	;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_update_CouponID_on_MarioOrderData`()
BEGIN
	UPDATE marios_pizza.marioorderdata01 AS destTable
	SET `CouponID` =  ( SELECT ID
							FROM marios_pizza.coupon srcTable
							WHERE srcTable.Description = destTable.`Gebruikte Coupon` AND destTable.`Gebruikte Coupon` > ''
						)
    ;    
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_update_CustomerAddressID_on_marioorderdata01`()
BEGIN
UPDATE marios_pizza.marioorderdata01 ordData
JOIN marios_pizza.customer AS cust ON ordData.CustomerID = cust.ID
JOIN marios_pizza.customer_addressinfo AS custAddressInfo ON cust.ID = custAddressInfo.Customer_ID
JOIN marios_pizza.addressinfo AS addressInfo ON custAddressInfo.AddressInfo_ID = addressInfo.ID
SET ordData.AddressID = addressinfo.ID
    ;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_update_DeliverTypeID_on_OrderData`()
BEGIN
UPDATE marios_pizza.marioorderdata01 AS destTable    
JOIN marios_pizza.deliverytype srcTable ON destTable.AfleverType = srcTable.Type
SET destTable.DeliveryTypeID = srcTable.ID
;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_Update_Order_Customer_ID`()
BEGIN
	UPDATE marios_pizza.marioorderdata01 ord
	JOIN marios_pizza.customer cust USING (Email)
	SET ord.CustomerID = cust.ID;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_update_OrderID_on_MarioOrderData`()
BEGIN
	UPDATE marios_pizza.marioorderdata01 destTable    
		JOIN marios_pizza.order srcTable ON destTable.CustomerID = srcTable.Customer_Id 
		SET destTable.OrderID = srcTable.ID
        # 'woensdag 5 juni 2019' - '2019-06-05 00:00:00'
		WHERE func_dateTime_to_TimeStamp(destTable.Besteldatum,'00:00') = srcTable.OrderDate
        AND
		# 'woensdag 5 juni 2019' (aflevermoment) '20:05'- '2019-06-05 20:05:00'
		func_dateTime_to_TimeStamp(destTable.AfleverDatum,destTable.Aflevermoment) = srcTable.DeliveryTime
		AND
		destTable.WinkelID = srcTable.Shop_ID
        AND destTable.AfleverDatum not like '%,%'
		
;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_update_ProductID_with_NonPizzaIDs_on_marioorderdata`()
BEGIN
UPDATE marios_pizza.marioorderdata01 AS destTable
JOIN marios_pizza.nonpizza AS nonpizzaTable ON destTable.Product = nonpizzaTable.Name
SET destTable.nonProductID = nonpizzaTable.ID
;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_update_ProductID_with_PizzaIDs_on_marioorderdata`()
BEGIN
	UPDATE marios_pizza.marioorderdata01 AS destTable
	JOIN marios_pizza.pizza AS pizzaTable ON destTable.Product = pizzaTable.Name
	SET destTable.ProductID = pizzaTable.ID
	;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_update_productnaamID_from_mariooverigeproducten`()
BEGIN
	UPDATE marios_pizza.mariooverigeproducten AS destTable
    JOIN marios_pizza.nonpizza AS srcTable ON destTable.productnaam = srcTable.Name
    SET destTable.productnaamID = srcTable.ID
    ;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_update_subcategorieID_mariooverigeproducten`()
BEGIN
	UPDATE marios_pizza.mariooverigeproducten AS destTable
    JOIN marios_pizza.subcategory AS subcatTable ON destTable.subcategorie = subcatTable.Name
    SET destTable.subcategorieID = subcatTable.ID
;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_update_WinkelID`()
BEGIN
	UPDATE marios_pizza.marioorderdata01 destTable
    JOIN marios_pizza.shop srcTable ON destTable.Winkelnaam = srcTable.Name
    SET destTable.WinkelID = srcTable.ID
    ;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_updateWinkelnaam`()
BEGIN
  DECLARE CURSOR_Id INT;
  DECLARE CURSOR_Winkelnaam VARCHAR(255);
  DECLARE done INT DEFAULT FALSE;
  DECLARE cursor_Order CURSOR FOR SELECT ID, Name FROM marios_pizza.city;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
  OPEN cursor_Order;
  loop_through_rows: LOOP
    FETCH cursor_Order INTO CURSOR_Id, CURSOR_Winkelnaam;
    IF done THEN
      LEAVE loop_through_rows;
    END IF;
    UPDATE new_schema.marioorderdata01 SET Winkelnaam = CURSOR_Id WHERE Name = CURSOR_Winkelnaam;
  END LOOP;
  CLOSE cursor_Order;
END$$
DELIMITER ;
