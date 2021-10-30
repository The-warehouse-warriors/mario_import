CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_return_pizzabottom_values`(
	IN BottomID int, 
    OUT name varchar(45), 
    size varchar(45), 
    description varchar(255), 
    price decimal(7,3), 
    active tinyint)
BEGIN
	#DECLARE _name varchar(45);
    #DECLARE _size varchar(45);
    #DECLARE _description varchar(254);
    #DECLARE _price decimal(7,3);
    #DECLARE _active tinyint;
    #DECLARE finished INTEGER DEFAULT 0;
	#DECLARE cur CURSOR FOR 
SELECT naam, diameter, omschrijving, toeslag, beschikbaar FROM pizzabottom WHERE ID = BottomID;


END