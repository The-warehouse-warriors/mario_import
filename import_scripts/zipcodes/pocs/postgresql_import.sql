-- Create an SP in postgresql
-- Select desinct cities in temp zipcode table
-- Add City to table an update Temp zipcode with just added city ID
-- This takes about 5 minuts for 600.000 temp rows

create function postgres_poc1() returns void
    language plpgsql
as
$$
DECLARE
        _date date = NOW();
        _city varchar(255);
        _munId int;
        _cityId int;
        curTemp CURSOR FOR SELECT distinct "City", "MunId" FROM "tempZipcodes";
BEGIN
    open curTemp;
    loop
        FETCH curTemp INTO _city, _munId;
        exit when not found;

        INSERT INTO "City" ("Name", "Municipality_ID", "CreatedOn", "CreatedBy", "LastUpdate", "UpdateBy")
            VALUES (_city, _munId, _date, 'henk', _date, 'henk') RETURNING id INTO _cityId;

        UPDATE "tempZipcodes" SET "City" = _cityId WHERE "City" = _city;

    end loop;
    CLOSE curTemp;
END;
$$;

alter function postgres_poc1() owner to admin;

