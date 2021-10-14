import mysql.connector
import pyodbc
import csv
from datetime import datetime
import time
import sys
import pandas as pd

# Create needed Vars
AccessMunicipalityTable = "GEMEENTEN"
AccessZipcodeTable = "POSTCODES"
logFile = './logs/zipcode_log.txt'
tempCsv = './temp/tempZipcode.csv'

# Database vars
dbUser = 'admin'
dbPassword = '<nope>'
SQLCityTable = "city"
SQLMunicipalityTable = "municipality"
SQLtempZipcodeTable = 'tempzipcodes'
SQLUri = 'mysql+pymysql://%s:%s@localhost/marios_pizza' % (dbUser, dbPassword)



# Create connector for later use
def createDbConnector():
    try:
        global mydb
        mydb = mysql.connector.connect(
            host="localhost",
            user=dbUser,
            password=dbPassword,
            database="marios_pizza"
        )
    except:
        log("!! MySQL error!")
        exit()

# Import given file into database
def importFile(filename):
    log("Open database")
    # Import Municipalities first
    handleMunicipality(filename)
    # Import Zipcode (and more)
    handleZipcodes(filename)


# Municipality table
def handleMunicipality(filename):
    log("Import Municipality table")

    try:
        # Create Access connector
        conn = pyodbc.connect(
            r'Driver={Microsoft Access Driver (*.mdb, *.accdb)};DBQ=' + filename + ';')
        cursor = conn.cursor()

        # Get all Municipalities
        query = "SELECT * FROM {Municipality} ".format(
            Municipality=AccessMunicipalityTable
        )
        cursor.execute(query)

        # Loop through found Municipality
        i = 0
        for row in cursor.fetchall():
            id = row[0]
            name = row[1].upper()

            # Log if no ID is found
            if id == '':
                log('! No ID given')
                continue

            # Log if not name is found
            if name == '':
                log("! No name given")
                continue

            # Check if municipality exists
            if not checkMunicipalityExists(id, name):
                addMunicipality(id, name)
                i = i + 1

        log("Done import Municipality")
        log("Add new municipality : " + str(i))

    except pyodbc.Error:
        log("!! ERROR: Cant find/open Access file")

# Insert into SQL DB
def addMunicipality(id, name):
    dtNow = datetime.now()
    try:
        # Create and execute query
        sql = "INSERT INTO municipality (ID, Name, CreatedOn, CreatedBy, LastUpdate, UpdateBy) VALUES (%s,%s,%s,%s,%s,%s)"
        val = (
            id,
            name,
            dtNow.strftime("%Y-%m-%d %H:%M:%S"),
            "System - import",
            dtNow.strftime("%Y-%m-%d %H:%M:%S"),
            "System - import"
        )
        mycursor = mydb.cursor()
        mycursor.execute(sql, val)
        mydb.commit()
    except pyodbc.Error as e:
        log(e)

# check if m unicipality exists
def checkMunicipalityExists(id, name):
    try:
        # Create and execute query
        query = "SELECT * FROM {Table} WHERE ID = '{Id}' OR Name = '{Name}'".format(
            Table=SQLMunicipalityTable,
            Id=id,
            Name=name,
        )
        mycursor = mydb.cursor()
        mycursor.execute(query)
        result = mycursor.fetchall()

        # Check if a result is returned
        if len(result) == 0:
            return False
        else:
            return True
    except pyodbc.Error as e:
        log(e)
    return False

# Zipcode Table
def handleZipcodes(filename):
    log("Handle zipcodes")

    # Access to CSV
    createTempZipcodeCsv(filename)

    # Upload SCV to SQL
    bulkImport()

    # And calling SP
    executeZipcodeSP()

def createTempZipcodeCsv(filename):
    log("Create Zipcodes temp file")
    try:
        # Get Zipcode data
        conn = pyodbc.connect(
            r'Driver={Microsoft Access Driver (*.mdb, *.accdb)};DBQ=' + filename + ';')
        cursor = conn.cursor()

        query = "SELECT * FROM {Zipcode}".format(
            Zipcode=AccessZipcodeTable
        )
        cursor.execute(query)

        # Create file if not exists, or truncates if it does
        f = open(tempCsv, 'w', encoding='UTF8', newline='')
        writer = csv.writer(f)

        header = ['Zipcode', 'BreakStart', 'BreakEnd', 'City', 'Street', 'MunId', 'CityId', 'StreetId']
        writer.writerow(header)

        i = 0
        for row in cursor.fetchall():
            i = i + 1
            zipcode = row[0].replace(" ", "").upper()
            breakpointStart = str(row[2])
            breakpointEnd = str(row[3])
            city = str(row[4])
            street = str(row[5])
            municipalityId = row[6]
                
            # Create row and add to file
            data = [zipcode, breakpointStart, breakpointEnd, city, street, municipalityId, '', '']
            writer.writerow(data)

        # Done with CSV creating
        f.close()      
        conn.close()

        log("Added " + str(i) + " rows to temp file")
    except pyodbc.Error:
        log("!! ERROR: Cant find/open Access file")
    except Exception as err:
        log(err)

def bulkImport():
    # Truncate tempzipcodes first
    try:
        sql = "truncate tempzipcodes;"
        mycursor = mydb.cursor()
        mycursor.execute(sql)
        mydb.commit()
        log("Truncated tempzipcodes")
    except Exception as err:
        log(err)
        # Stop process on error
        return 
    
    try:
        # Import csv to sql with pandas
        df = pd.read_csv(tempCsv)
        
        # Table name
        # Connection uri
        # Replace data 
        # Create no indexes
        df.to_sql(SQLtempZipcodeTable, con=SQLUri, if_exists='replace', index=False)
    except Exception as err:
        log(err)
        # Stop process on error
        return

    log("Done with CSV import")

# Execute the stored procedure 
# to handle the imported temp zipcodes
def executeZipcodeSP():
    try:
        # Create and execute query
        sql = "call ImportTempZipcodes();"
        mycursor = mydb.cursor()
        mycursor.execute(sql)
        mydb.commit()
        log("SP called")
    except Exception as err:
        log(err)
        return

# Log text to file
def log(text):    
    print(text)

    # Create a row in txt file with Datetime as prefix
    dtnow = datetime.now()
    with open(logFile, 'a') as logger:
        logger.write(str(dtnow) + ') ' + str(text) + '\n')


# Main function, called on start
if __name__ == '__main__':
    log("--- START import zipcode ---")

    # Set start time
    start = time.time()

    # Check/create Mysql connector
    createDbConnector()

    # Check given params
    if len(sys.argv) < 2:
        log("!! Missing argument !!")
        exit()

    # Select first param, and call main function
    filename = sys.argv[1]    
    importFile(filename)

    # Final msg with total run time in seconds
    log('--- DONE import zipcode, took: {0:2f} seconds to run'.format(time.time() - start))