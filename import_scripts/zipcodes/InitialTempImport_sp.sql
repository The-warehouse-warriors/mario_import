DROP PROCEDURE IF EXISTS ImportTempZipcodes;

DELIMITER $$
CREATE PROCEDURE ImportTempZipcodes()
BEGIN

    DECLARE done BOOLEAN DEFAULT FALSE;

    DECLARE _id int;
    DECLARE _zipcode varchar(255);
    DECLARE _breakpointStart varchar(255);
    DECLARE _breakpointEnd varchar(255);
    DECLARE _city varchar(255);
    DECLARE _street varchar(255);
    DECLARE _municipalityId varchar(255);

    DECLARE cur CURSOR FOR SELECT * FROM tmpPostcode;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done := TRUE;

    OPEN cur;

    tempLoop: LOOP
        FETCH cur INTO _id, _zipcode, _breakpointStart, _breakpointEnd, _city, _street, _municipalityId;

        IF done THEN
        LEAVE tempLoop;
        END IF;

        -- Import all data from temp table with other SP
        CALL ImportZipcodes(UPPER(REPLACE(_zipcode, ' ', '')),_breakpointStart,_breakpointEnd,_city,_street,_municipalityId);

    END LOOP tempLoop;

    CLOSE cur;

END $$;
DELIMITER ;