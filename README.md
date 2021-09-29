# mario_import
Import code for mario pizza's




# Shops

Import all shop data from given text file.

run: `python .\import_scripts\shops\import_shops.py "<FILE NAME>"`

## Dependencies
Install mysql-connector-python:

`python -m pip install mysql-connector-python`

# Zipcode

Import all zip codes, street names, cities and municipalities

run: `python .\import_scripts\ziptcodes\import_zipcodes.py ".\Postcode_tabel.mdb"`

## Dependencies
Install pyodbc:

`python -m pip install pyodbc`

## Stored procedure
Add the `ImportZipcodes_SP.sql` to MySql