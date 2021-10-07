# POCs

POCs for trying to speed up zipcode import 

## temp_import

This POC reads all rows from temp zipcode table and call importZipcode SP for EACH row.

SP calling other SP.

## temp_update

This POC read all rows for temp zipcode table and
- Insert city and store ID
- Update tempzipcode city field with stored ID

This POC took 29 minutes to complete with 600.000 records in the tempzipcode table

## Postgresql

This POC is the same as in the [temp_update](#temp_update) POC but in PostgreSql.

This POC took 5 minutes to complete with 600.000 records in the tempzipcode table


