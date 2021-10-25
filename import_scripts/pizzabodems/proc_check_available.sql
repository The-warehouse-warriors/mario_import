CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_check_available`()
BEGIN
    DECLARE _available_string varchar(45);
    DECLARE _available_boolean TINYINT;
    DECLARE finished INTEGER DEFAULT 0;
    DECLARE _wrong_value INTEGER DEFAULT 0;
	DECLARE cur CURSOR FOR SELECT beschikbaar FROM temporarypizzabottoms;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET _wrong_value = 1;
    OPEN cur;
    
    checkAvailable: LOOP
		FETCH FROM cur INTO _available_string;
        IF finished = 1 
			THEN LEAVE checkAvailable;
        END IF;
        
        CASE _available_string.lower()
			WHEN 'ja' THEN UPDATE temporarypizzabottoms SET beschikbaar = 0 WHERE beschikbaar = 'Ja';
            WHEN 'nee' THEN UPDATE temporarypizzabottoms SET beschikbaar = 1 WHERE beschikbaar = 'Nee';
            WHEN 0 THEN SET _available_boolean = 0;
            WHEN 1 THEN SET _available_boolean = 1;
            ELSE DELETE FROM temporarypizzabottoms WHERE beschikbaar = _available_string;
		END CASE;
	END LOOP checkAvailable;
END