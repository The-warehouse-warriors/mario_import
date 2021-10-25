#SET FOREIGN_KEY_CHECKS=0;
#TRUNCATE marios_pizza.municipality;
#SET FOREIGN_KEY_CHECKS=1;

#SELECT * FROM marios_pizza.municipality;

# Load Data 'C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\MarioOrderData01_10000.csv'  
# Mysql uses different path seperators '/' instead of '\'
# Original file: LOAD DATA INFILE 'C:/Fontys/Code/MarioOrderData01_Modified.csv'
# Using adjusted csv file: C:/Fontys/Code/MarioOrderData01_Modified.csvingredientingredient
#LOAD DATA INFILE 'C:/Fontys/Code/exports/municipality_export.csv'
#	INTO TABLE marios_pizza.municipality 
#	FIELDS TERMINATED BY ';'
#    OPTIONALLY ENCLOSED BY '"'
#	LINES TERMINATED BY '\n'
#   IGNORE 1 LINES;
    
#LOAD DATA INFILE 'C:/Fontys/Code/exports/city.csv'
#	INTO TABLE marios_pizza.city 
#	FIELDS TERMINATED BY ';'
#   OPTIONALLY ENCLOSED BY '"'
#	LINES TERMINATED BY '\n'
#    IGNORE 1 LINES;
    
#LOAD DATA INFILE 'C:/Fontys/Code/exports/marios_pizza_street.csv'
#	INTO TABLE marios_pizza.street
#	FIELDS TERMINATED BY ','
#	LINES TERMINATED BY '\n';

# last step before final one
#SET FOREIGN_KEY_CHECKS=0;
#LOAD DATA INFILE 'C:/Fontys/Code/exports/marios_pizza_shop.csv'
#	INTO TABLE marios_pizza.`shop` 
#	FIELDS TERMINATED BY ','
#	OPTIONALLY ENCLOSED BY '"'
#	LINES TERMINATED BY '\n';
#SET FOREIGN_KEY_CHECKS=1;

#SET FOREIGN_KEY_CHECKS=0;   
#LOAD DATA INFILE 'C:/Fontys/Code/exports/marios_pizza_servicearea.csv'
#	INTO TABLE marios_pizza.servicearea 
#	FIELDS TERMINATED BY ','
#	LINES TERMINATED BY '\n'
#   IGNORE 1 LINES;
#SET FOREIGN_KEY_CHECKS=1;
#

#SET FOREIGN_KEY_CHECKS=0;   
#LOAD DATA INFILE 'C:/Fontys/Code/exports/Ingredienten.csv'
#	INTO TABLE marios_pizza.ingredient 
#	FIELDS TERMINATED BY ','
#	LINES TERMINATED BY '\n'
#   IGNORE 1 LINES
#   ;
#SET FOREIGN_KEY_CHECKS=1;

#LOAD DATA INFILE 'C:/Fontys/Code/exports/tax.csv'
#	INTO TABLE marios_pizza.tax 
#	FIELDS TERMINATED BY ','
#	LINES TERMINATED BY '\n'
#   IGNORE 1 LINES
#   ;

# LOAD temp data into pizzaBottomType table
CALL proc_Fill_pizzaBottomType_Table();

# LOAD temp data into pizzaBottom table
CALL proc_Fill_pizzaBottom();

# LOAD temp data into category
CALL proc_Fill_category();

# LOAD temp data into subcategory
CALL proc_Fill_subcategory();

# LOAD temp data into sauce
CALL proc_Fill_sauce();

# LOAD temp data into pizza
CALL `proc_Fill_pizza`();

# LOAD temp data into pizza_ingredient
CALL `proc_Fill_pizza_ingredient`();

# LOAD OverigeProducten
TRUNCATE marios_pizza.mariooverigeproducten;

LOAD DATA INFILE 'C:/Fontys/Code/MarioData/Overigeproducten.csv'
	INTO TABLE marios_pizza.mariooverigeproducten 
	FIELDS TERMINATED BY ';'
	LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   	(ID
		,categorie
		,categorieUnique
		,categorieID
		,subcategorie
		,subcategorieUnique
		,subcategorieID
		,productnaam
		,productnaamUnique
		,productnaamID
		,productomschrijving
		,productomschrijvingFiltered
		,prijs
		,@prijsDecimal
		,spicy
		,spicyTrueFalse
		,vegetarisch
		,vegetarischTrueFalse
		)
		SET prijsDecimal=if(@prijsDecimal = '', NULL, @prijsDecimal)
	;

# Update categoryID in table mariooverigeproducten
CALL `proc_update_CategoryID_mariooverigeproducten` ();

# Update subcategoryID in table mariooverigeproducten
CALL `proc_update_subcategorieID_mariooverigeproducten`();

# Derive Nonpizza products from mariooverigeproducten
CALL `proc_derive_Nonpizza_products_from_mariooverigeproducten`();

# Update productID in table mariooverigeproducten
CALL `proc_update_productnaamID_from_mariooverigeproducten` ();

# Update StoreID     # 9.7 sec
CALL `proc_update_WinkelID`();

# Empty customer table, only needed for re-imports and testing
	SET FOREIGN_KEY_CHECKS=0;
	TRUNCATE marios_pizza.customer;
	SET FOREIGN_KEY_CHECKS=1;


SET @startOver = 0;
SET @truncateOnly = 1;

# Clearing tables
CALL `proc_truncate_partial_tables`();

# LOAD CSV File in temp table
LOAD DATA INFILE 'C:/Fontys/Code/MarioOrderData01_Modified1.csv'
	INTO TABLE marios_pizza.marioorderdata01
	FIELDS TERMINATED BY ';' 
	LINES TERMINATED BY '\n'
	IGNORE 1 LINES
	(`MyUnknownColumn`, @WinkelID, `Winkelnaam`, @CustomerID, `Klantnaam`
        , `TelefoonNr`, `Email`, @AddressID, `Adres`, `Woonplaats`
        , @OrderID, `Besteldatum`, @DeliveryTypeID, `AfleverType`
        , `AfleverDatum`, `AfleverMoment`, @ProductID, @nonProductID, `Product`, @PizzaBodemID, `PizzaBodem`
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
    , nonProductID=if(@nonProductID = '', NULL, @nonProductID)
    , PizzaBodemID=if(@PizzaBodemID = '', NULL, @PizzaBodemID)
    , PizzaSausID=if(@PizzaSausID = '', NULL, @PizzaSausID)
    ;

LOAD DATA INFILE 'C:/Fontys/Code/MarioOrderData01_Modified2.csv'
	INTO TABLE marios_pizza.marioorderdata01
	FIELDS TERMINATED BY ';' 
	LINES TERMINATED BY '\n'
	IGNORE 1 LINES
	(`MyUnknownColumn`, @WinkelID, `Winkelnaam`, @CustomerID, `Klantnaam`
        , `TelefoonNr`, `Email`, @AddressID, `Adres`, `Woonplaats`
        , @OrderID, `Besteldatum`, @DeliveryTypeID, `AfleverType`
        , `AfleverDatum`, `AfleverMoment`, @ProductID, @nonProductID, `Product`, @PizzaBodemID, `PizzaBodem`
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
    , nonProductID=if(@nonProductID = '', NULL, @nonProductID)
    , PizzaBodemID=if(@PizzaBodemID = '', NULL, @PizzaBodemID)
    , PizzaSausID=if(@PizzaSausID = '', NULL, @PizzaSausID)
    ;

LOAD DATA INFILE 'C:/Fontys/Code/MarioOrderData01_Modified3.csv'
	INTO TABLE marios_pizza.marioorderdata01
	FIELDS TERMINATED BY ';' 
	LINES TERMINATED BY '\n'
	IGNORE 1 LINES
	(`MyUnknownColumn`, @WinkelID, `Winkelnaam`, @CustomerID, `Klantnaam`
        , `TelefoonNr`, `Email`, @AddressID, `Adres`, `Woonplaats`
        , @OrderID, `Besteldatum`, @DeliveryTypeID, `AfleverType`
        , `AfleverDatum`, `AfleverMoment`, @ProductID, @nonProductID, `Product`, @PizzaBodemID, `PizzaBodem`
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
    , nonProductID=if(@nonProductID = '', NULL, @nonProductID)
    , PizzaBodemID=if(@PizzaBodemID = '', NULL, @PizzaBodemID)
    , PizzaSausID=if(@PizzaSausID = '', NULL, @PizzaSausID)
    ;

LOAD DATA INFILE 'C:/Fontys/Code/MarioOrderData01_Modified4.csv'
	INTO TABLE marios_pizza.marioorderdata01
	FIELDS TERMINATED BY ';' 
	LINES TERMINATED BY '\n'
	IGNORE 1 LINES
	(`MyUnknownColumn`, @WinkelID, `Winkelnaam`, @CustomerID, `Klantnaam`
        , `TelefoonNr`, `Email`, @AddressID, `Adres`, `Woonplaats`
        , @OrderID, `Besteldatum`, @DeliveryTypeID, `AfleverType`
        , `AfleverDatum`, `AfleverMoment`, @ProductID, @nonProductID, `Product`, @PizzaBodemID, `PizzaBodem`
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
    , nonProductID=if(@nonProductID = '', NULL, @nonProductID)
    , PizzaBodemID=if(@PizzaBodemID = '', NULL, @PizzaBodemID)
    , PizzaSausID=if(@PizzaSausID = '', NULL, @PizzaSausID)
    ;

# setting ID correct
SET @num := 0;
UPDATE marios_pizza.marioorderdata01 
	SET MyUnknownColumn = @num := (@num+1);

# Create extra column WinkelID
SELECT * FROM marios_pizza.marioorderdata01
WHERE ORDERID is null limit 10;

# Update StoreID     # 9.7 sec
CALL `proc_update_WinkelID`();

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

# Update productID in marioorderdata with PizzaIDs : Duration: 8.8s
CALL `proc_update_ProductID_with_PizzaIDs_on_marioorderdata` ();

# Update productID in marioorderdata with NonPizzaIDs : Duration: 5,234s
CALL `proc_update_ProductID_with_NonPizzaIDs_on_marioorderdata`();

# Derive order items from MarioOrderData
CALL `proc_derive_OrderItems_From_OrderData`();