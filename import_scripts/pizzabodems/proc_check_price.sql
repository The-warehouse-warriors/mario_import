CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_check_price`()
BEGIN
    DECLARE _price_string varchar(45);
    DECLARE _price_decimal DECIMAL(7,3);
    DECLARE finished INTEGER DEFAULT 0;
    DECLARE _wrong_value INTEGER DEFAULT 0;
	DECLARE cur CURSOR FOR SELECT toeslag FROM temporarypizzabottoms;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET _wrong_value = 1;
    OPEN cur;
    
    checkPrice: LOOP
		FETCH FROM cur INTO _price_string;
        IF finished = 1 
			THEN LEAVE checkPrice;
        END IF;
		
        SET _price_decimal = _price_string;
        IF _wrong_value = 1 
			THEN DELETE FROM temporarypizzabottoms WHERE toeslag = _price_string;
        END IF;
	END LOOP checkPrice;
END