DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `func_dateTime_to_TimeStamp`(
		strDate VARCHAR(30)
        , strTime VARCHAR(30)
) RETURNS datetime
BEGIN
	# Required: SET GLOBAL log_bin_trust_function_creators = 1;
    # Function usage: func_dateTime_to_TimeStamp('maandag 29 juni 2019','11:16')
	DECLARE resultDateTime VARCHAR(255);
    DECLARE strTempDay VARCHAR(10);
    DECLARE strTempVarMonth VARCHAR(15);
    DECLARE strTempYear VARCHAR(4);
    DECLARE strTempTime VARCHAR(8);
    DECLARE tempString VARCHAR(20);
    
    # Input strDate: 			woensdag 5 juni 2019
    # Input strTime: 			20:05
    # Result resultDateTime:	2021-10-10 18:29:54
    
    # Chop off 'day'
    SET tempString = (SELECT SUBSTRING_INDEX(strDate, ' ',-3) );
    
    # Filter daynumber
    SET strTempDay = SUBSTRING_INDEX(SUBSTRING_INDEX(tempString, ' ', 1), ' ', -1);
    
    # Filter monthname
    SET strTempVarMonth = SUBSTRING_INDEX(SUBSTRING_INDEX(tempString, ' ', 2), ' ', -1);
    IF STRCMP(strTempVarMonth, 'Januari') = 0 THEN 
		SET strTempVarMonth = '01';
    ELSEIF STRCMP(strTempVarMonth, 'Februari') = 0 THEN 
		SET strTempVarMonth = '02';
	ELSEIF STRCMP(strTempVarMonth, 'Maart') = 0 THEN 
		SET strTempVarMonth = '03';
	ELSEIF STRCMP(strTempVarMonth, 'April') = 0 THEN 
		SET strTempVarMonth = '04';
	ELSEIF STRCMP(strTempVarMonth, 'Mei') = 0 THEN 
		SET strTempVarMonth = '05';
	ELSEIF STRCMP(strTempVarMonth, 'Juni') = 0 THEN 
		SET strTempVarMonth = '06';
	ELSEIF STRCMP(strTempVarMonth, 'Juli') = 0 THEN 
		SET strTempVarMonth = '07';
	ELSEIF STRCMP(strTempVarMonth, 'Augustus') = 0 THEN 
		SET strTempVarMonth = '08';
	ELSEIF STRCMP(strTempVarMonth, 'September') = 0 THEN 
		SET strTempVarMonth = '09';
	ELSEIF STRCMP(strTempVarMonth, 'Oktober') = 0 THEN 
		SET strTempVarMonth = '10';
	ELSEIF STRCMP(strTempVarMonth, 'November') = 0 THEN 
		SET strTempVarMonth = '11';
	ELSEIF STRCMP(strTempVarMonth, 'December') = 0 THEN 
		SET strTempVarMonth = '12';
	ELSE
		SET strTempVarMonth = strTempVarMonth;
	END IF;
        
    # Filter Year
	SET strTempYear = SUBSTRING_INDEX(tempString, ' ',-1);
    
    # Filter time
    IF (strTime REGEXP '^[[:digit:]]+\\:{0,1}[[:digit:]]*$') = 0 THEN
		SET strTime = '00:00';
    ELSE 
		SET strTime = strTime;
	END IF;
    
    # Putting results together
    SET resultDateTime = (SELECT CONCAT(strTempYear, '-',strTempVarMonth, '-', strTempDay, ' ', strTime, ':00'));
    
    RETURN STR_TO_DATE(resultDateTime, '%Y-%m-%d %H:%i:%s');
    #RETURN LOWER(resultDateTime);
    
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `func_Strip_non_Digit`(input VARCHAR(255)) RETURNS varchar(255) CHARSET utf8mb3
BEGIN
   DECLARE output   VARCHAR(255) DEFAULT '';
   DECLARE iterator INT          DEFAULT 1;
   WHILE iterator < (LENGTH(input) + 1) DO
      IF SUBSTRING(input, iterator, 1) IN (',', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' ) THEN
         SET output = CONCAT(output, SUBSTRING(input, iterator, 1));
      END IF;
      SET iterator = iterator + 1;
   END WHILE;   
   RETURN output;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `func_Strip_non_Digit_return_decimal`(input VARCHAR(255)) RETURNS decimal(10,0)
BEGIN
# need SET GLOBAL log_bin_trust_function_creators = 1;
   DECLARE output  Decimal(7,3) DEFAULT 0;
   DECLARE temp VARCHAR(255);
   DECLARE iterator INT          DEFAULT 1;
   WHILE iterator < (LENGTH(input) + 1) DO
      IF SUBSTRING(input, iterator, 1) IN (',', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' ) THEN
         SET temp = CONCAT(output, SUBSTRING(input, iterator, 1));
      END IF;
      SET iterator = iterator + 1;
   END WHILE;   

	SET output = CONVERT(temp, DECIMAL(7,3));
#   RETURN output;
	RETURN output;

END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `func_temp_dateTime_to_TimeStamp`(
		strDate VARCHAR(30)
        , strTime VARCHAR(30)
) RETURNS varchar(255) CHARSET utf8mb3
BEGIN
	# Required: SET GLOBAL log_bin_trust_function_creators = 1;
    # Function usage: func_dateTime_to_TimeStamp('maandag 29 juni 2019','11:16')
	DECLARE resultDateTime VARCHAR(255);
    DECLARE strTempDay VARCHAR(10);
    DECLARE strTempVarMonth VARCHAR(15);
    DECLARE strTempYear VARCHAR(4);
    DECLARE strTempTime VARCHAR(8);
    DECLARE tempString VARCHAR(20);
    
    # Input strDate: 			woensdag 5 juni 2019
    # Input strTime: 			20:05
    # Result resultDateTime:	2021-10-10 18:29:54
    
    # Chop off 'day'
    SET tempString = (SELECT SUBSTRING_INDEX(strDate, ' ',-3) );
    
    # Filter daynumber
    SET strTempDay = SUBSTRING_INDEX(SUBSTRING_INDEX(tempString, ' ', 1), ' ', -1);
    
    # Filter monthname
    SET strTempVarMonth = SUBSTRING_INDEX(SUBSTRING_INDEX(tempString, ' ', 2), ' ', -1);
    IF STRCMP(strTempVarMonth, 'Januari') = 0 THEN 
		SET strTempVarMonth = '01';
    ELSEIF STRCMP(strTempVarMonth, 'Februari') = 0 THEN 
		SET strTempVarMonth = '02';
	ELSEIF STRCMP(strTempVarMonth, 'Maart') = 0 THEN 
		SET strTempVarMonth = '03';
	ELSEIF STRCMP(strTempVarMonth, 'April') = 0 THEN 
		SET strTempVarMonth = '04';
	ELSEIF STRCMP(strTempVarMonth, 'Mei') = 0 THEN 
		SET strTempVarMonth = '05';
	ELSEIF STRCMP(strTempVarMonth, 'Juni') = 0 THEN 
		SET strTempVarMonth = '06';
	ELSEIF STRCMP(strTempVarMonth, 'Juli') = 0 THEN 
		SET strTempVarMonth = '07';
	ELSEIF STRCMP(strTempVarMonth, 'Augustus') = 0 THEN 
		SET strTempVarMonth = '08';
	ELSEIF STRCMP(strTempVarMonth, 'September') = 0 THEN 
		SET strTempVarMonth = '09';
	ELSEIF STRCMP(strTempVarMonth, 'Oktober') = 0 THEN 
		SET strTempVarMonth = '10';
	ELSEIF STRCMP(strTempVarMonth, 'November') = 0 THEN 
		SET strTempVarMonth = '11';
	ELSEIF STRCMP(strTempVarMonth, 'December') = 0 THEN 
		SET strTempVarMonth = '12';
	ELSE
		SET strTempVarMonth = strTempVarMonth;
	END IF;
        
    # Filter Year
	SET strTempYear = SUBSTRING_INDEX(tempString, ' ',-1);
    
    # Putting results together
    SET resultDateTime = (SELECT CONCAT(strTempYear, '-',strTempVarMonth, '-', strTempDay, ' ', strTime, ':00'));
    
    #RETURN STR_TO_DATE(resultDateTime, '%Y-%m-%d %H:%i:%s');
    RETURN LOWER(resultDateTime);
    
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `uuid_v4`() RETURNS char(36) CHARSET utf8mb3
    NO SQL
BEGIN
    -- Generate 8 2-byte strings that we will combine into a UUIDv4
    SET @h1 = LPAD(HEX(FLOOR(RAND() * 0xffff)), 4, '0');
    SET @h2 = LPAD(HEX(FLOOR(RAND() * 0xffff)), 4, '0');
    SET @h3 = LPAD(HEX(FLOOR(RAND() * 0xffff)), 4, '0');
    SET @h6 = LPAD(HEX(FLOOR(RAND() * 0xffff)), 4, '0');
    SET @h7 = LPAD(HEX(FLOOR(RAND() * 0xffff)), 4, '0');
    SET @h8 = LPAD(HEX(FLOOR(RAND() * 0xffff)), 4, '0');

    -- 4th section will start with a 4 indicating the version
    SET @h4 = CONCAT('4', LPAD(HEX(FLOOR(RAND() * 0x0fff)), 3, '0'));

    -- 5th section first half-byte can only be 8, 9 A or B
    SET @h5 = CONCAT(HEX(FLOOR(RAND() * 4 + 8)),
                LPAD(HEX(FLOOR(RAND() * 0x0fff)), 3, '0'));

    -- Build the complete UUID
    RETURN LOWER(CONCAT(
        @h1, @h2, '-', @h3, '-', @h4, '-', @h5, '-', @h6, @h7, @h8
    ));
END$$
DELIMITER ;
