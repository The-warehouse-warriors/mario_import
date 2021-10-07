import mysql.connector
import pyodbc
from datetime import datetime
import sys

SQLCityTable = "city"
SQLMunicipalityTable = "municipality"
AccessMunicipalityTable = "GEMEENTEN"
AccessZipcodeTable = "POSTCODES"
logFile = './logs/zipcode_log.txt'

def createDbConnector():
    try:
        global mydb
        mydb = mysql.connector.connect(
            host="localhost",
            user="admin",
            password="<nope>",
            database="marios_pizza"
        )
    except:
        log("!! MySQL error!")
        exit()


def importFile(filename):
    log("Open database")
    handleMunicipality(filename)
    handleZipcodes(filename)

# Municipality table
def handleMunicipality(filename):
    log("- Import Municipality table")

    try:
        conn = pyodbc.connect(
            r'Driver={Microsoft Access Driver (*.mdb, *.accdb)};DBQ=' + filename + ';')
        cursor = conn.cursor()

        query = "SELECT * FROM {Municipality} ".format(
            Municipality=AccessMunicipalityTable
        )
        cursor.execute(query)

        for row in cursor.fetchall():
            id = row[0]
            name = row[1].upper()

            if id == '':
                log('! No ID given')
                continue

            if name == '':
                log("! No name given")
                continue

            # check if municipality exists
            if not checkMunicipalityExists(id, name):
                addMunicipality(id, name)

        log("Done import Municipality")

    except pyodbc.Error:
        log("!! ERROR: Cant find/open Access file")


# Zipcode Table
def handleZipcodes(filename):
    log("- Import Zipcodes table")

    try:
        conn = pyodbc.connect(
            r'Driver={Microsoft Access Driver (*.mdb, *.accdb)};DBQ=' + filename + ';')
        cursor = conn.cursor()

        query = "SELECT * FROM {Zipcode}".format(
            Zipcode=AccessZipcodeTable
        )

        cursor.execute(query)
        i = 0
        for row in cursor.fetchall():
            i = i + 1
            zipcode = row[0].replace(" ", "").upper()
            breakpointStart = str(row[2])
            breakpointEnd = str(row[3])
            city = str(row[4])
            street = str(row[5])
            municipalityId = row[6]

            log("- "+str(i))

            # Call SP to insert
            addZipcode(
                zipcode,
                breakpointStart,
                breakpointEnd,
                city,
                street,
                municipalityId
            )

        log("Handled items : " + str(i))
        log("Done import Municipality\n")

    except pyodbc.Error:
        log("!! ERROR: Cant find/open Access file")
    except pyodbc.DatabaseError as err:
        log(err)


## SQL Insert functions

# Insert into SQL DB
def addMunicipality(id, name):
    log("Insert: " + str(id) + " - " + name)
    dtNow = datetime.now()

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
    log("Municipality inserted, ID:", mycursor.lastrowid)

# Insert data with Stored procedure


def addZipcode(zipcode, breakpointStart, breakpointEnd, city, street, municipalityId):
    #print("- Insert: " + zipcode)

    try:
        mycursor = mydb.cursor()
        args = [
            zipcode,
            breakpointStart,
            breakpointEnd,
            city.replace("'", ""),
            street,
            municipalityId
        ]
        result = mycursor.callproc('ImportZipcodes', args)
        mydb.commit()

    except pyodbc.Error as e:
        log(e)


# Item Exists check functions

# Municipality
def checkMunicipalityExists(id, name):
    log("Check Municipality")

    query = "SELECT * FROM {Table} WHERE ID = '{Id}' OR Name = '{Name}'".format(
        Table=SQLMunicipalityTable,
        Id=id,
        Name=name,
    )

    mycursor = mydb.cursor()
    mycursor.execute(query)
    result = mycursor.fetchall()

    # log result
    if len(result) == 0:
        log("No Municipality found")
        return False
    else:
        log("Municipality found")
        return True


# City
def checkCityExists(name):
    log("Check City")

    query = "SELECT * FROM {Table} WHERE Name = '{Name}'".format(
        Table=SQLCityTable,
        Name=name
    )

    mycursor = mydb.cursor()
    mycursor.execute(query)
    result = mycursor.fetchall()

    # log result
    if len(result) == 0:
        log("No City found")
        return False
    else:
        log("City found")
        return True


def log(text):
    print(text)
    dtnow = datetime.now()
    with open(logFile, 'a') as logger:
        logger.write(str(dtnow) + ') ' + text + '\n')

if __name__ == '__main__':
    log("--- Start importer ---")

    # Check/create Mysql connector
    createDbConnector()

    # Check given params
    if len(sys.argv) < 2:
        log("!! Missing argument !!")
        exit()

    filename = sys.argv[1]    
    importFile(filename)