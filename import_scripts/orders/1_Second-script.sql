SET FOREIGN_KEY_CHECKS=0;
TRUNCATE marios_pizza.municipality;
SET FOREIGN_KEY_CHECKS=1;

SELECT * FROM marios_pizza.municipality;

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

# last step before final one
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
