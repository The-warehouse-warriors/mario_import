import sys
import mysql.connector as msql
from mysql.connector import Error
import datetime
import pandas as pd
import configparser


table = 'ingredienten'
user = "System"
timeStamp = datetime.datetime.now()
starttime = datetime
endtime = datetime
processtime = datetime
logFile = './logs/ingredients_log.txt'

def createDbConnector():
    try:
        global mariosDB
        mariosDB = msql.connect(
            host = dbHost,
            user = dbUser,
            password = dbPassword,
            database = dbTable
        )

        if mariosDB.is_connected():
            global cursor
            cursor = mariosDB.cursor()
            cursor.execute("select database();")
            record = cursor.fetchone()
            print('Connected to database: ', record)

    except Error as e:
        print('--- Error while connecting to database ---', e)


def removeCharInName(text):
    characters_to_remove_in_name = "!()@€[],'"
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
    return text


def CheckIngredientExists(ingredient):
    sql = "SELECT Name FROM {table} WHERE Name = '{IngredientName}'".format(
        table="ingredient",
        IngredientName=ingredient
    )

    cursor = mariosDB.cursor()
    cursor.execute(sql)
    result = cursor.fetchall()

    if len(result) == 0:
        return False
    else:
        return True

def IngredientImport(filename):
    # start tijd word bepaald
    starttime=datetime.datetime.now()

    log("-- Start import ingredients--")

    # data word geïmporteerd naar een array.
    df = pd.read_csv (filename)
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
            loginput = "! Insert {} skipt because of wrong value in price. ({})"
            log(loginput.format(i + 1, rawprice))
            i += 1
            continue

        cleanprice = float(cleanprice)
        cleanname = removeCharInName(rawname)

        # controle in database voor het bestaan van de item
        Check = CheckIngredientExists(cleanname)

        if Check == True:

            loginput = "! input: {} with name: {} and price: €{} is not inserted: already exists"
            log(loginput.format(i + 1, cleanname, cleanprice))
            i+=1
            continue

        sql = "INSERT INTO ingredient (Name, Price, Tax_ID, CreatedOn, CreatedBy, LastUpdate, UpdateBy ) VALUES (%s, %s, %s, %s, %s, %s, %s)"
        val = (cleanname, cleanprice, 1, timeStamp, user, timeStamp, user)
        cursor.execute(sql, val)
        mariosDB.commit()
#        loginput = "input: {} with name: {} and price: €{} is inserted"
#        log(loginput.format(i+1, cleanname, cleanprice))
        i+=1

    # stelt de eind tijd van de inport vast
    endtime = datetime.datetime.now()
    processtime = endtime-starttime
    log("-- End import ingredients--")
    log("Total import time: " +  str(processtime))

def log(text):
    print(text)
    dtnow = datetime.datetime.now()
    with open(logFile, 'a') as logger:
        logger.write(str(dtnow) + ') ' + text + '\n')

def setConfig():  

    # read config and set values
    config = configparser.ConfigParser()
    config.read('config.ini')

    global dbHost
    global dbTable
    global dbUser
    global dbPassword

    dbHost = config.get('Database', 'dbHost')
    dbTable = config.get('Database', 'dbTable')
    dbUser = config.get('Database', 'dbUser')
    dbPassword = config.get('Database', 'dbPassword')

if __name__ == '__main__':

    if len(sys.argv) < 2:
        log('Missing argument!')
        exit()

    setConfig()

    createDbConnector()

    filename = sys.argv[1]
    IngredientImport(filename)
