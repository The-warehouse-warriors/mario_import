import sys
import mysql.connector as msql
from mysql.connector import Error
import datetime
import pandas as pd


try:
    mariosDB = msql.connect(
        host="localhost",
        user="root",
        password="HvG5217405",
        database="marios_pizza")

    table = 'ingredienten'
    user = "System"
    timeStamp = datetime.datetime.now()
    starttime = datetime
    endtime = datetime
    processtime = datetime
    insertlog = []
    skiplog = []
    timelog = []


    if mariosDB.is_connected():

        cursor = mariosDB.cursor()
        cursor.execute("select database();")
        record = cursor.fetchone()
        print('Connected to database: ', record)

except Error as e:
    print('--- Error while connecting to database ---', e)


def removeCharInName(text):
    characters_to_remove_in_name = "!()@€[], '"
    for ch in characters_to_remove_in_name:
        text = text.replace(ch, "")
    return text


def removeCharInPrice(text):
    wrongCharacters = "$"
    charactersToRemove = "!()@€[], 'qwertyuiopasdfghjklzxcvbnm<>-"
    for wch in wrongCharacters:
        if wch in text != True:
            text = False
        else:
            for ch in charactersToRemove:
                text = text.replace(ch, "")
           # text = float(text)
    return text


def CheckIngredientExists(ingredient):
    sql = "SELECT Name FROM {table} WHERE Name = '{IngredientName}'".format(
        table="ingredient",
        IngredientName=ingredient
    )

    cursor.execute(sql)
    result = cursor.fetchall()

    if len(result) == 0:
        return False
    else:
        return True


def TaxImport():
    sql = "INSERT INTO tax (Tax, Description , CreatedOn, CreatedBy, LastUpdate, UpdateBy ) VALUES (%s, %s, %s, %s, %s, %s)"
    val = (9, "9% BTW", timeStamp, user, timeStamp, user)
    cursor.execute(sql, val)

    mariosDB.commit()
    print("tax inserted")
    sql = "INSERT INTO tax (Tax, Description , CreatedOn, CreatedBy, LastUpdate, UpdateBy ) VALUES (%s, %s, %s, %s, %s, %s)"
    val = (21, "21% BTW", timeStamp, user, timeStamp, user)
    cursor.execute(sql, val)

    mariosDB.commit()
    print("tax inserted")


def IngredientImport(file):
    # start tijd word bepaald
    starttime=datetime.datetime.now()

    print("-- Start inport ingredients--")

    # data word geïmporteerd naar een array.
    df = pd.read_csv (file)
    arrayData = df.values
    arrayLen = len(arrayData)

    # Aanmaken van while loop voor het inport process
    i = 0
    while i < arrayLen:
        # naam en prijs worden gesplitst om in de juiste row te kunnen worden geïmporteerd.
        rawstring = str(arrayData[i])
        rawname,rawprice=rawstring.split(";")

        cleanprice = removeCharInPrice(rawprice)
        if cleanprice == False:
            logInsert = "Insert {} skipt because of wrong value in price. ({})"
            skiplog.append(logInsert.format(i + 1, rawprice))
            i += 1
            continue

        cleanprice = float(cleanprice)
        cleanname = removeCharInName(rawname)

        # controle in database voor het bestaan van de item
        Check = CheckIngredientExists(cleanname)

        if Check == True:
            logInsert = "input: {} with name: {} and price: €{} is not inserted: already exists"
            skiplog.append(logInsert.format(i + 1, cleanname, cleanprice))
            i+=1
            continue

        sql = "INSERT INTO ingredient (Name, Price, Tax_ID, CreatedOn, CreatedBy, LastUpdate, UpdateBy ) VALUES (%s, %s, %s, %s, %s, %s, %s)"
        val = (cleanname, cleanprice, 1, timeStamp, user, timeStamp, user)
        cursor.execute(sql, val)
        mariosDB.commit()
        logInsert = "input: {} with name: {} and price: €{} is inserted"
        insertlog.append(logInsert.format(i+1, cleanname, cleanprice))
        i+=1

    # stelt de eind tijd van de inport vast
    endtime = datetime.datetime.now()
    processtime = endtime-starttime
    print("-- End inport ingredients--")
    print("")
    print("Total time consumed: ", processtime)

if __name__ == '__main__':

    if len(sys.argv) < 2:
        print('Missing argument!')
        exit()

    print('file: ' + sys.argv[1])
    filename = sys.argv[1]

    IngredientImport(filename)