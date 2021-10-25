CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_fill_pizzabottom`()
BEGIN
	DECLARE _ID int;
	DECLARE _name varchar(45);
    DECLARE _size varchar(45);
    DECLARE _description varchar(254);
    DECLARE _price decimal(7,3);
    DECLARE _available tinyint;
    DECLARE finished INTEGER DEFAULT 0;
	DECLARE cur CURSOR FOR SELECT pb.ID, tmp.naam, tmp.diameter, tmp.omschrijving, tmp.toeslag, tmp.beschikbaar FROM temporarypizzabottoms AS tmp left join pizzabottom AS pb ON tmp.naam = pb.Name;
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
     END LOOP getIdJoin;   
	#END WHILE;
    CLOSE cur;
END