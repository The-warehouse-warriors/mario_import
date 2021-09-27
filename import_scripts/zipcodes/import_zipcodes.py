import mysql.connector
import pyodbc
from datetime import datetime

mydb = mysql.connector.connect(
    host="localhost",
    user="admin",
    password="<nope>",
    database="marios_pizza"
)
SQLCityTable = "city"
SQLMunicipalityTable = "municipality"
AccessMunicipalityTable = "GEMEENTEN"
AccessZipcodeTable = "POSTCODES"


def importFile(filename):
    print("--- Open database  ---")

    handleMunicipality(filename)
    handleZipcodes(filename)

# Municipality table


def handleMunicipality(filename):
    print("--- Import Municipality table ---")

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
                print('No ID given')
                continue

            if name == '':
                print("No name given")
                continue

            # check if municipality exists
            if not checkMunicipalityExists(id, name):
                addMunicipality(id, name)

        print("-- Done import Municipality\n")

    except pyodbc.Error:
        print("ERROR: Cant find/open Access file")


# Zipcode Table
def handleZipcodes(filename):
    print("--- Import Zipcodes table ---")

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

            print("- "+str(i))

            # Call SP to insert
            addZipcode(
                zipcode,
                breakpointStart,
                breakpointEnd,
                city,
                street,
                municipalityId
            )

        print("Handled items : " + str(i))
        print("-- Done import Municipality\n")

    except pyodbc.Error:
        print("ERROR: Cant find/open Access file")
    except pyodbc.DatabaseError as err:
        print(err)


## SQL Insert functions

# Insert into SQL DB
def addMunicipality(id, name):
    print("- Insert: " + str(id) + " - " + name)
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
    print("- Municipality inserted, ID:", mycursor.lastrowid)

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
        print(result)

    except pyodbc.Error as e:
        print(e)


# Item Exists check functions

# Municipality
def checkMunicipalityExists(id, name):
    print("--- Check Municipality ---")

    query = "SELECT * FROM {Table} WHERE ID = '{Id}' OR Name = '{Name}'".format(
        Table=SQLMunicipalityTable,
        Id=id,
        Name=name,
    )

    mycursor = mydb.cursor()
    mycursor.execute(query)
    result = mycursor.fetchall()

    # Print result
    if len(result) == 0:
        print('- No Municipality found')
        return False
    else:
        print('- Municipality found')
        return True


# City
def checkCityExists(name):
    print("--- Check City ---")

    query = "SELECT * FROM {Table} WHERE Name = '{Name}'".format(
        Table=SQLCityTable,
        Name=name
    )

    mycursor = mydb.cursor()
    mycursor.execute(query)
    result = mycursor.fetchall()

    # Print result
    if len(result) == 0:
        print('- No City found')
        return False
    else:
        print('- City found')
        return True


if __name__ == '__main__':
    print("--- Start importer ---\n")
    importFile('.\Postcode_tabel.mdb')
