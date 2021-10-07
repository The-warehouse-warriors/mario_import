-- Use a temp table an update these values first

USE marios_pizza;

DROP PROCEDURE IF EXISTS test1;

DELIMITER $$
CREATE PROCEDURE test1()
BEGIN

    DECLARE done BOOLEAN DEFAULT FALSE;
    DECLARE _city varchar(255);
    DECLARE _munId int;
    DECLARE cur CURSOR FOR SELECT distinct City, MunId FROM tempzipcodes;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done := TRUE;
    OPEN cur;

    SELECT now() INTO @nowDate;

    SET FOREIGN_KEY_CHECKS = 0;

    tempLoop:
    loop
        FETCH cur INTO _city, _munId;

        IF done THEN
            LEAVE tempLoop;
        END IF;

        -- ADD
        INSERT INTO city (name, municipality_id, createdon, createdby, lastupdate, updateby)
            VALUE (_city, _munId, @nowDate, 'henk', @nowDate, 'henk');
        SELECT last_insert_id() INTO @city_id;

        -- Replace
        UPDATE tempzipcodes SET city = @city_id WHERE city = _city;

    end loop tempLoop;

    SET FOREIGN_KEY_CHECKS=1;

END $$;
DELIMITER ;


CALL test1();