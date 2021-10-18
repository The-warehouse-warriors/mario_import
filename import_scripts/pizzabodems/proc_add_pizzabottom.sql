CREATE DEFINER=`root`@`localhost` PROCEDURE `add_pizzabottom`(IN name varchar(45), size varchar(45))
BEGIN
INSERT INTO pizzabottom (Name, Size, Active, Tax_ID, PizzaBottomType_ID, CreatedOn, CreatedBy, LastUpdate, UdateBy, Deleted)
		VALUES(name, size, 1, 9, 0, CURRENT_TIMESTAMP, 'System', CURRENT_TIMESTAMP, 'System', 0);
END