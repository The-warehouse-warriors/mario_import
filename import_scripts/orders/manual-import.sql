#SET FOREIGN_KEY_CHECKS=0;
#TRUNCATE marios_pizza.municipality;
#SET FOREIGN_KEY_CHECKS=1;

#SELECT * FROM marios_pizza.municipality;

# Load Data 'C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\MarioOrderData01_10000.csv'  
# Mysql uses different path seperators '/' instead of '\'
# Original file: LOAD DATA INFILE 'C:/Fontys/Code/MarioOrderData01_Modified.csv'
# Using adjusted csv file: C:/Fontys/Code/MarioOrderData01_Modified.csvingredientingredient
LOAD DATA INFILE 'C:/Fontys/Code/exports/municipality_export.csv'
	INTO TABLE marios_pizza.municipality 
	FIELDS TERMINATED BY ';'
    OPTIONALLY ENCLOSED BY '"'
	LINES TERMINATED BY '\n'
   IGNORE 1 LINES;
    
LOAD DATA INFILE 'C:/Fontys/Code/exports/city.csv'
	INTO TABLE marios_pizza.city 
	FIELDS TERMINATED BY ';'
   OPTIONALLY ENCLOSED BY '"'
	LINES TERMINATED BY '\n'
    IGNORE 1 LINES;
   
LOAD DATA INFILE 'C:/Fontys/Code/exports/marios_pizza_street.csv'
	INTO TABLE marios_pizza.street
	FIELDS TERMINATED BY ','
	LINES TERMINATED BY '\n';

 last step before final one
SET FOREIGN_KEY_CHECKS=0;
LOAD DATA INFILE 'C:/Fontys/Code/exports/marios_pizza_shop.csv'
	INTO TABLE marios_pizza.`shop` 
	FIELDS TERMINATED BY ','
	OPTIONALLY ENCLOSED BY '"'
	LINES TERMINATED BY '\n';
SET FOREIGN_KEY_CHECKS=1;

SET FOREIGN_KEY_CHECKS=0;   
LOAD DATA INFILE 'C:/Fontys/Code/exports/marios_pizza_servicearea.csv'
	INTO TABLE marios_pizza.servicearea 
	FIELDS TERMINATED BY ','
	LINES TERMINATED BY '\n'
   IGNORE 1 LINES;
SET FOREIGN_KEY_CHECKS=1;



SET @startOver = 0;
SET @truncateOnly = 1;

CALL `proc_truncate_partial_tables`();

# Clear table
TRUNCATE marios_pizza.marioorderdata01;

# LOAD CSV File in temp table
LOAD DATA INFILE 'C:/Fontys/Code/MarioOrderData01_Modified.csv'
	INTO TABLE marios_pizza.marioorderdata01
	FIELDS TERMINATED BY ';' 
	LINES TERMINATED BY '\n'
	IGNORE 1 LINES
	(`MyUnknownColumn`, @WinkelID, `Winkelnaam`, @CustomerID, `Klantnaam`
        , `TelefoonNr`, `Email`, @AddressID, `Adres`, `Woonplaats`
        , @OrderID, `Besteldatum`, @DeliveryTypeID, `AfleverType`
        , `AfleverDatum`, `AfleverMoment`, @ProductID, `Product`, @PizzaBodemID, `PizzaBodem`
        , @PizzaSausID, `PizzaSaus`, `Prijs`, `Bezorgkosten`, @BezorgkostenDecimal
        , `Aantal`, `Extra IngrediÃƒÂ«nten`, `Prijs Extra IngrediÃƒÂ«nten`
        , `Regelprijs`, @RegelprijsDecimal, `Totaalprijs`, @TotaalprijsDecimal
        , @CouponID, `Gebruikte Coupon`,`Coupon Korting`, `Te Betalen`
        , @TeBetalenDecimal)
    set WinkelID=if(@WinkelID = '', NULL, @WinkelID)
    , CustomerID=if(@CustomerID = '', NULL, @CustomerID)
    , AddressID=if(@AddressID = '', NULL, @AddressID)
    , OrderID=if(@OrderID = '', NULL, @OrderID)
    , DeliveryTypeID=if(@DeliveryTypeID = '', NULL, @DeliveryTypeID)
    , BezorgkostenDecimal=if(@BezorgkostenDecimal = '', NULL, @BezorgkostenDecimal)
    , RegelprijsDecimal=if(@RegelprijsDecimal = '', NULL, @RegelprijsDecimal)
    , CouponID=if(@CouponID = '', NULL, @CouponID)
    , TeBetalenDecimal=if(@TeBetalenDecimal = '', NULL, @NULL)
    , TotaalprijsDecimal=if(@TotaalprijsDecimal = '', NULL, @TotaalprijsDecimal)
    , ProductID=if(@ProductID = '', NULL, @ProductID)
    , PizzaBodemID=if(@PizzaBodemID = '', NULL, @PizzaBodemID)
    , PizzaSausID=if(@PizzaSausID = '', NULL, @PizzaSausID)
    ;

# Create extra column WinkelID
SELECT * FROM marios_pizza.marioorderdata01;

# Update StoreID     # 9.7 sec
CALL `proc_update_WinkelID`();

# Empty customer table, only needed for re-imports and testing
	SET FOREIGN_KEY_CHECKS=0;
	TRUNCATE marios_pizza.customer;
	SET FOREIGN_KEY_CHECKS=1;


# Insert customers from order file, group by email and insert into customer table, unique on email address
CALL `proc_Insert_New_Customers`();

# Update order column, CustomerID
CALL `proc_Update_Order_Customer_ID`();

# Update customer address table with address from orderdata table, GROUP BY Woonplaats, Adres: 12 sec -> 0.2
CALL `proc_insertCustomerAddress`();

# Updating linked table Customer_AddressInfo 
CALL `proc_insert_customer_address_info_from_marioorderdata`();

# Update AddressID in marioorderdata01 table
CALL `proc_update_CustomerAddressID_on_marioorderdata01`();

# Derive Coupons from OrderData
CALL `proc_derive_Coupons_From_OrderData_And_Insert`();

# Update MarioOrderData table with Coupon ID
CALL `proc_update_CouponID_on_MarioOrderData`();

# Derive delivery type from order data
CALL `proc_derive_DeliverType_from_OrderData`();

# Update DeliveryTypeID in order data
CALL `proc_update_DeliverTypeID_on_OrderData`();

# Derive orders from orderdata
CALL `proc_derive_Orders_From_MarioData`();

# Update MarioOrderData with order ID
CALL `proc_update_OrderID_on_MarioOrderData`();

# Derive order items from MarioOrderData
CALL `proc_derive_OrderItems_From_OrderData`();
