DROP PROCEDURE IF EXISTS ImportTempZipcodes;

DELIMITER $$
CREATE PROCEDURE ImportTempZipcodes()
BEGIN

    SET @importDate = NOW();
    SET @importName = 'System - import';

    -- ADD CITY'S
    INSERT INTO city (
        Name, 
        Municipality_ID, 
        CreatedOn, 
        CreatedBy, 
        UpdateBy, 
        LastUpdate
    )
    SELECT DISTINCT 
        City, 
        MunId, 
        @importDate, 
        @importName, 
        @importName, 
        @importDate 
    FROM tempzipcodes as temp
    WHERE NOT EXISTS(
        SELECT Name 
        FROM city 
        WHERE Name = temp.City
    );

    -- Update temp with City ID
    UPDATE tempzipcodes temp
    JOIN city on City.Name = temp.City
    SET temp.CityId = City.ID
    WHERE temp.CityId IS NULL;

    -- INSERT street
    INSERT INTO street (
        Name,
        City_ID,
        CreatedOn,
        CreatedBy,
        UpdateBy,
        LastUpdate
    )
    SELECT DISTINCT  
        Street, 
        CityId,
        @importDate,
        @importName,
        @importName,
        @importDate 
    FROM tempzipcodes as temp
    WHERE NOT EXISTS(
        SELECT name 
        FROM street 
        WHERE Name = temp.Street
    );

    -- UPDATE temp with street ID
    UPDATE tempzipcodes temp
    JOIN street ON temp.Street = Street.Name
    SET temp.StreetId = Street.ID
    WHERE temp.StreetId IS NULL;

    -- INSERT INTO SERVICE
    INSERT INTO servicearea (
        Zipcode, 
        BreakpointStart, 
        BreakpointEnd, 
        Street_ID, 
        CreatedOn, 
        CreatedBy, 
        LastUpdate, 
        UpdateBy
    )
    SELECT DISTINCT 
        UPPER(REPLACE(Zipcode, ' ', '')),
        BreakStart,
        BreakEnd,
        StreetId, 
        @importDate, 
        @importName, 
        @importDate, 
        @importName 
    FROM tempzipcodes as temp
    WHERE NOT EXISTS(
        SELECT Zipcode 
        FROM servicearea 
        WHERE servicearea.Zipcode = UPPER(REPLACE(temp.Zipcode, ' ', '')) 
        AND servicearea.BreakpointStart = temp.BreakStart
    );

END $$;
DELIMITER ;

