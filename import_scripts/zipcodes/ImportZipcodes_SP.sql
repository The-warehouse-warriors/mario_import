DROP PROCEDURE IF EXISTS ImportZipcodes;

DELIMITER $$
CREATE PROCEDURE ImportZipcodes(
    IN inZipcode varchar(6),
    IN inBreakpointStart varchar(6),
    IN inBreakpointEnd varchar(6),
    IN inCityName varchar(45),
    IN inStreetName varchar(75),
    IN inMunicipalityId int

)
BEGIN
    /* Check if city exists in DB, if not create */
    SET @city_id = (SELECT id FROM city WHERE Name = inCityName);
    IF (@city_id IS NULL) THEN
        INSERT INTO city (Name, Municipality_ID, CreatedOn, CreatedBy, LastUpdate, UpdateBy)
        VALUE (
               inCityName,
               inmunicipalityId,
               NOW(),
               'System - import',
               NOW(),
               'System - import'
        );
        SELECT last_insert_id() INTO @city_id;
    END IF;

    /* Check if Street exists in DB, if not create */
    SET @street_id = (SELECT id FROM street WHERE Name = inStreetName);
    IF (@street_id IS NULL) THEN
        INSERT INTO street (Name, City_ID, CreatedOn, CreatedBy, LastUpdate, UpdateBy)
        VALUE (
               inStreetName,
               @city_id,
               NOW(),
               'System - import',
               NOW(),
               'System - import'
        );
        SELECT last_insert_id() INTO @street_id;
    END IF;

    /* Check if servicearea exists in DB, if not create */
    SET @servicearea_id = (SELECT id FROM servicearea WHERE Zipcode = inZipcode);
    IF (@servicearea_id IS NULL) THEN
        INSERT INTO servicearea (Zipcode, BreakpointStart, BreakpointEnd, Street_ID, CreatedOn, CreatedBy, LastUpdate, UpdateBy)
        VALUE (
            inZipcode,
            inBreakpointStart,
            inBreakpointEnd,
            @street_id,
            NOW(),
            'System - import',
            NOW(),
            'System - import'
        );
    END IF;

END $$;
DELIMITER ;


