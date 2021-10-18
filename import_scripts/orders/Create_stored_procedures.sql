DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_Update_Order_Customer_ID`()
BEGIN
	UPDATE marios_pizza.marioorderdata01 ord
	JOIN marios_pizza.customer cust USING (Email)
	SET ord.CustomerID = cust.ID;
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
		,'2021-10-06 18:29:54' AS CreatedOn
		,'System - import' AS CreatedBy
		,'2021-10-06 18:29:54' AS LastUpdate
		,'System - import' AS UpdateBy
		,0 AS Deleted
	FROM marios_pizza.marioorderdata01 AS srcTable
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
