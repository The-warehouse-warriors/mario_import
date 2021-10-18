CREATE DEFINER=`root`@`localhost` PROCEDURE `fill_pizzabottom`()
BEGIN
	DECLARE _ID int;
	DECLARE _name varchar(45);
    DECLARE _size varchar(45);
	DECLARE db_cursor CURSOR FOR SELECT ID, naam, diameter FROM temporarypizzabottoms left join pizzabottom ON temporarypizzabottoms.naam = pizzabottom.Name;
    
    WHILE(db_cursor != NULL)
		DO
		FETCH NEXT FROM db_cursor INTO _ID, _name, _size;
		IF  _ID = NULL
			THEN
				CALL add_pizzabottom(_name, _size);
		ELSE 
			BEGIN
				IF _size != pizzabottom.Size
					THEN 
						UPDATE pizzabottom SET Size = _size where pizzabottom.ID = _ID;
				ELSE 
					DO nothing;
				END IF;
			END;
		END IF;
	END WHILE;
END