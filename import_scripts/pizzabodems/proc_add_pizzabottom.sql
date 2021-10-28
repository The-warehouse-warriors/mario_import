CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_add_pizzabottom`(IN _name varchar(45), _size varchar(45), _description varchar(254), _price decimal(7,3), available tinyint)
BEGIN
INSERT INTO pizzabottom (Name, Size, Descrition, Active, Price, Tax_ID, CreatedOn, CreatedBy, LastUpdate, UdateBy, Deleted)
		VALUES(_name, _size, _description, _available, _price, 9, CURRENT_TIMESTAMP, 'System', CURRENT_TIMESTAMP, 'System', 0);
END