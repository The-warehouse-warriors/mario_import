SELECT srcTable.OrderID as OrderID
		, srcTable.ProductID as Pizza_ID
        , srcTable.ProductID as NonPizza_ID
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
	LIMIT 10;
new_procedureDELIMITER $$
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_derive_OrderItems_From_OrderData`()
BEGIN
INSERT INTO marios_pizza.orderitem (OrderID, Pizza_ID, NonPizza_ID, OrderName, Amount, TotalPrice, Tax, CreatedOn, CreatedBy, LastUpdate, UpdateBy, Deleted)
	SELECT srcTable.OrderID as OrderID
		, srcTable.ProductID as Pizza_ID
        , srcTable.ProductID as NonPizza_ID
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
					GROUP BY Email, AfleverDatum, Aflevermoment
     ;
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
	TRUNCATE marios_pizza.`addressinfo`;
	TRUNCATE marios_pizza.`category`;
	TRUNCATE marios_pizza.`coupon`;
	TRUNCATE marios_pizza.`customer`;
	TRUNCATE marios_pizza.`customer_addressinfo`;
	TRUNCATE marios_pizza.`deliverytype`;
	TRUNCATE marios_pizza.`differentopeningtime`;
	TRUNCATE marios_pizza.`ingredient`;
	TRUNCATE marios_pizza.`item_property`;
	TRUNCATE marios_pizza.`marioorderdata01`;
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
	TRUNCATE marios_pizza.`subcategory`;
	TRUNCATE marios_pizza.`tax`;
	SET FOREIGN_KEY_CHECKS=1;
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
		
;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_update_WinkelID`()
BEGIN
	UPDATE marios_pizza.marioorderdata01 tempDB
	SET WinkelID =  ( SELECT ID
							FROM marios_pizza.shop destDB
							WHERE destDB.Name = tempDB.Winkelnaam
						)
	WHERE Winkelnaam IN ( SELECT Name 
							FROM marios_pizza.shop destDB)
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
    
