# Clear table
TRUNCATE marios_pizza.marioorderdata01;

LOAD DATA INFILE 'C:/Fontys/Code/MarioOrderData01_Modified.csv'
	INTO TABLE marios_pizza.marioorderdata01
	FIELDS TERMINATED BY ';' 
	LINES TERMINATED BY '\n'
	IGNORE 1 LINES;

SELECT * FROM marios_pizza.marioorderdata01;

CALL `proc_update_WinkelID`();

SET FOREIGN_KEY_CHECKS=0;
TRUNCATE marios_pizza.customer;
SET FOREIGN_KEY_CHECKS=1;

CALL `proc_Insert_New_Customers`();

CALL `proc_Update_Order_Customer_ID`();

