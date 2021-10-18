SET @startOver = 0;
SET @truncateOnly = 0;

# Clear table
TRUNCATE marios_pizza.marioorderdata01;

# LOAD CSV File in temp table
LOAD DATA INFILE 'C:/Fontys/Code/MarioOrderData01_Modified.csv'
	INTO TABLE marios_pizza.marioorderdata01
	FIELDS TERMINATED BY ';' 
	LINES TERMINATED BY '\n'
	IGNORE 1 LINES;

# Create extra column WinkelID
SELECT * FROM marios_pizza.marioorderdata01;

# Update StoreID
CALL `proc_update_WinkelID`();

# Empty customer table, only needed for re-imports and testing
	SET FOREIGN_KEY_CHECKS=0;
	TRUNCATE marios_pizza.customer;
	SET FOREIGN_KEY_CHECKS=1;


# Insert customers from order file, group by email and insert into customer table, unique on email address
CALL `proc_Insert_New_Customers`();

# Create extra column CustomerID

# Update order column, CustomerID
CALL `proc_Update_Order_Customer_ID`();


# Create extra column AddressID
# Update customer address table with address from orderdata table, GROUP BY Woonplaats, Adres: 12 sec -> 0.2
CALL `proc_insertCustomerAddress`();

# Updating linked table Customer_AddressInfo 
CALL `proc_insert_customer_address_info_from_marioorderdata`();

# Update AddressID in marioorderdata01 table
CALL `proc_update_CustomerAddressID_on_marioorderdata01`();

# Add column CouponID


SELECT * FROM marios_pizza.marioorderdata01;
# Derive Coupons from OrderData
CALL `proc_derive_Coupons_From_OrderData_And_Insert`();

# Update MarioOrderData table with Coupon ID
CALL `proc_update_CouponID_on_MarioOrderData`();

# Add extra column DeliveryTypeID


# Derive delivery type from order data
CALL `proc_derive_DeliverType_from_OrderData`();

# Update DeliveryTypeID in order data
CALL `proc_update_DeliverTypeID_on_OrderData`();

# Derive orders from orderdata
CALL `proc_derive_Orders_From_MarioData`();

	INSERT INTO marios_pizza.order (OrderStatus, DeliveryPlan, DeliveryTime, DeliveryPrice, Customer_Id, DeliveryType_ID, Shop_ID, OrderDate, TotalOrderPrice, CreatedOn, CreatedBy, LastUpdate, UpdateBy, Deleted)
    SELECT  		CASE	
						WHEN srcTable.AfleverMoment > '' THEN 0
                        WHEN srcTable.AfleverMoment IS NULL OR srcTable.AfleverMoment = ''  THEN 1
					END AS OrderStatus
					, func_dateTime_to_TimeStamp(AfleverDatum,Aflevermoment) AS DeliveryPlan
					, func_dateTime_to_TimeStamp(AfleverDatum,Aflevermoment) AS DeliveryTime
                    ,
                    CASE
						WHEN Bezorgkosten REGEXP '^[[:digit:]]+\\.{0,1}[[:digit:]]*$' = 1 THEN CONVERT(func_Strip_non_Digit(REPLACE(Bezorgkosten,',','.')) , DECIMAL(7,3))
						WHEN Bezorgkosten REGEXP '^[[:digit:]]+\\.{0,1}[[:digit:]]*$' = 0 THEN CONVERT(func_Strip_non_Digit(REPLACE(Bezorgkosten,'.',',')) , DECIMAL(7,3))
                    END AS DeliveryPrice
                    , CustomerID AS Customer_Id
                    , DeliveryTypeID AS DeliveryType_ID
                    , WinkelID AS Shop_ID
                    , func_dateTime_to_TimeStamp(Besteldatum,'00:00') AS OrderDate
                    , 
					CASE
						WHEN Totaalprijs REGEXP '^[[:digit:]]+\\.{0,1}[[:digit:]]*$' = 1 THEN CONVERT(func_Strip_non_Digit(REPLACE(Totaalprijs,',','.')) , DECIMAL(7,3))
						WHEN Totaalprijs REGEXP '^[[:digit:]]+\\.{0,1}[[:digit:]]*$' = 0 THEN CONVERT(func_Strip_non_Digit(REPLACE(Totaalprijs,'.',',')) , DECIMAL(7,3))
                    END AS TotalOrderPrice
					, CURRENT_TIMESTAMP AS CreatedOn
					, 'System - import' AS CreatedBy
					, CURRENT_TIMESTAMP AS LastUpdate
					, 'System - import' AS UpdateBy
					, 0 as Deleted
					FROM marios_pizza.marioorderdata01 srcTable
					GROUP BY Email, AfleverDatum, Aflevermoment
    ;


# Add column orderID


