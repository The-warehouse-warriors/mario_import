CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_fill_pizzabottom`()
BEGIN
	DECLARE _ID int;
	DECLARE _name varchar(45);
    DECLARE _size varchar(45);
    DECLARE _description varchar(254);
    DECLARE _price decimal(7,3);
    DECLARE _available tinyint;
	DECLARE db_cursor CURSOR FOR SELECT ID, naam, diameter, omschrijving, toeslag, beschikbaar FROM temporarypizzabottoms left join pizzabottom ON temporarypizzabottoms.naam = pizzabottom.Name;
    
    SELECT CONCAT('Variables declared: ', db_cursor);
    
    OPEN db_cursor;
    WHILE(db_cursor != NULL)
    
		DO
        SELECT('Entered While loop');
		FETCH FROM db_cursor INTO _ID, _name, _size, _description, _price, _available;
		IF  _ID = NULL
			THEN
				CALL add_pizzabottom(_name, _size, _description, _price, _available);
		ELSE 
			BEGIN
				IF _size != pizzabottom.Size
					THEN 
						UPDATE pizzabottom SET Size = _size,  LastUpdated = CURRENT_TIMESTAMP, UpdatedBy = 'System' where pizzabottom.ID = _ID;
				END IF;
                IF _description != pizzabottom.Description
					THEN 
						UPDATE pizzabottom SET Description = _description,  LastUpdated = CURRENT_TIMESTAMP, UpdatedBy = 'System' where pizzabottom.ID = _ID;
				END IF;
				IF _price != pizzabottom.Price
					THEN 
						UPDATE pizzabottom SET Price = _price,  LastUpdated = CURRENT_TIMESTAMP, UpdatedBy = 'System' where pizzabottom.ID = _ID;
				END IF;
				IF _available != pizzabottom.Available
					THEN 
						UPDATE pizzabottom SET Available = _available,  LastUpdated = CURRENT_TIMESTAMP, UpdatedBy = 'System' where pizzabottom.ID = _ID;
				END IF;
			END;
		END IF;
	END WHILE;
    CLOSE db_cursor;
END