# Mario_import
Import code for mario pizza's

# Main import

To import all the data, put all files in `.\import_scripts\files`.

and run: `python .\import_scripts\import.py`


# Scripts

## Shops

Import all shop data from given text file.

run: `python .\import_scripts\shops\import_shops.py "<FILE NAME>"`

### Dependencies
Install mysql-connector-python:

`python -m pip install mysql-connector-python`

## Zipcode

Import all zip codes, street names, cities and municipalities

run: `python .\import_scripts\ziptcodes\import_zipcodes.py "<FILE NAME>"`

### Dependencies
Install pyodbc:

`python -m pip install pyodbc`

### Stored procedure
Add the `ImportZipcodes_SP.sql` to MySql
