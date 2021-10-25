CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_check_size`()
BEGIN
    DECLARE _size_string varchar(45);
    DECLARE _size_integer INTEGER;
    DECLARE finished INTEGER DEFAULT 0;
    DECLARE _wrong_value INTEGER DEFAULT 0;
	DECLARE cur CURSOR FOR SELECT diameter FROM temporarypizzabottoms;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET _wrong_value = 1;
    OPEN cur;
    
    checkSize: LOOP
		FETCH FROM cur INTO _size_string;
        IF finished = 1 
			THEN LEAVE checkSize;
        END IF;
		
        SET _size_integer = _size_string;
        IF _wrong_value = 1 
			THEN DELETE FROM temporarypizzabottoms WHERE diameter = _size_string;
        END IF;
	END LOOP checkSize;
END