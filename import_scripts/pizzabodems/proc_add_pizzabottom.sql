CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_add_pizzabottom`(IN name varchar(45), size varchar(45), description varchar(254), price decimal(7,3), available tinyint)
BEGIN
INSERT INTO pizzabottom (Name, Size, Descrition, Active, Price, Tax_ID, CreatedOn, CreatedBy, LastUpdate, UdateBy, Deleted)
		VALUES(name, size, description, available, price, 9, CURRENT_TIMESTAMP, 'System', CURRENT_TIMESTAMP, 'System', 0);
END