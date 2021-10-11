import sys
import mysql.connector as msql
from mysql.connector import Error
import datetime
import pandas as pd

table = 'tax'
user = "System"
timeStamp = datetime.datetime.now()
starttime = datetime
endtime = datetime
processtime = datetime
logFile = './logs/ingredients_log.txt'

try:
    mariosDB = msql.connect(
        host="localhost",
        user="root",
        password="HvG5217405",
        database="marios_pizza")

    if mariosDB.is_connected():

        cursor = mariosDB.cursor()
        cursor.execute("select database();")
        record = cursor.fetchone()
        print('Connected to database: ', record)

except Error as e:
    print('--- Error while connecting to database ---', e)

def removeChars(text):
    charactersToRemove = "!()@€[], '-"
    for ch in charactersToRemove:
        text = text.replace(ch, "")
    return text

def checkTax(tax):
    sql = "SELECT Tax FROM {Table} WHERE Tax = '{Tax}'".format(
        Table=table,
        Tax=tax
    )

    cursor.execute(sql)
    result = cursor.fetchall()

    if len(result) == 0:
        return False
    else:
        return True

def taxImport(filename):
    starttime=datetime.datetime.now()

    log("-- Start import tax--")

    df = pd.read_csv(filename)
    arrayData = df.values
    arrayLen = len(arrayData)

    i = 0
    while i < arrayLen:
        rawstring = str(arrayData[i])
        rawbtw,rawdesc=rawstring.split(";")

        cleanbtw = removeChars(rawbtw)
        cleanbtw = float(cleanbtw)

        cleandesc = removeChars(rawdesc)
        check = checkTax(cleanbtw)

        if check == True:

            loginput = "! input: {} with tax: {} is not inserted: already exists"
            log(loginput.format(i + 1, cleanbtw))
            i += 1
            continue

        sql = "INSERT INTO tax (Tax, Description , CreatedOn, CreatedBy, LastUpdate, UpdateBy ) VALUES (%s, %s, %s, %s, %s, %s)"
        val = (cleanbtw, cleandesc, timeStamp, user, timeStamp, user)
        cursor.execute(sql, val)
        mariosDB.commit()
        loginput = "input: {} with tax: {} is inserted"
        log(loginput.format(i + 1, cleanbtw))
        i += 1

    endtime = datetime.datetime.now()
    processtime = endtime-starttime
    log("-- End import tax--")
    log("Total time consumed: ", processtime)


def log(text):
    print(text)
    dtnow = datetime.datetime.now()
    with open(logFile, 'a') as logger:
        logger.write(str(dtnow) + ') ' + text + '\n')

if __name__ == '__main__':

    if len(sys.argv) < 2:
        print('Missing argument!')
        exit()

    print('file: ' + sys.argv[1])
    filename = sys.argv[1]

    taxImport(filename)
