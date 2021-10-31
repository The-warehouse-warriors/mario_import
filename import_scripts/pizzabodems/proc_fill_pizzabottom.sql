CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_fill_pizzabottom`()
BEGIN
	DECLARE _ID int;
	DECLARE _name varchar(45);
    DECLARE _size varchar(45);
    DECLARE _description varchar(254);
    DECLARE _price decimal(7,3);
    DECLARE _available tinyint;
    DECLARE finished INTEGER DEFAULT 0;
	DECLARE cur CURSOR FOR SELECT pb.ID, 
								  temporarypizzabottoms.naam, 
                                  temporarypizzabottoms.diameter, 
                                  temporarypizzabottoms.omschrijving, 
                                  temporarypizzabottoms.toeslag, 
                                  temporarypizzabottoms.beschikbaar 
                                  FROM temporarypizzabottoms left join pizzabottom AS pb ON temporarypizzabottoms.naam = pb.Name;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;
    
    OPEN cur;

    getIdJoin: LOOP
    #WHILE(cur != NULL)
		#DO
        #SELECT('Entered While loop');
		FETCH FROM cur INTO _ID, _name, _size, _description, _price, _available;
        IF finished = 1 
			THEN LEAVE getIdJoin;
        END IF;
		IF  _ID is NULL
			THEN
				CALL proc_add_pizzabottom(_name, _size, _description, _price, _available);
		ELSE 
			BEGIN
				CALL proc_return_pizzabottom_values(_ID, @name, @size, @description, @price, @active);
				IF _size <> @size
					THEN 
						UPDATE pizzabottom SET Size = _size,  LastUpdated = CURRENT_TIMESTAMP, UpdatedBy = 'System' where ID = _ID;
				END IF;
                IF _description <> @description
					THEN 
						UPDATE pizzabottom SET Description = _description,  LastUpdated = CURRENT_TIMESTAMP, UpdatedBy = 'System' where ID = _ID;
				END IF;
				IF _price <> @price
					THEN 
						UPDATE pizzabottom SET Price = _price,  LastUpdated = CURRENT_TIMESTAMP, UpdatedBy = 'System' where ID = _ID;
				END IF;
				IF _available <> @active
					THEN 
						UPDATE pizzabottom SET Available = _available,  LastUpdated = CURRENT_TIMESTAMP, UpdatedBy = 'System' where ID = _ID;
				END IF;
			END;
		END IF;
     END LOOP getIdJoin;   
	#END WHILE;
    CLOSE cur;
END