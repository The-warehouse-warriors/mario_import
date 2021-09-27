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
    log = []

    if mariosDB.is_connected():

        cursor = mariosDB.cursor()
        cursor.execute("select database();")
        record = cursor.fetchone()
        print('Connected to database: ', record)

except Error as e:
    print('--- Error while connecting to database ---', e)

#   Bij grote bestanden kan er ook gebruik worden gemaakt van een class. Voor de ingredienten is dit misschien niet nodig

class Ingredient:
    def __init__(self, name, price):
        self.name = name
        self.price = price

def removeCharInName(text):
    characters_to_remove_in_name = "!()@€[], '"
    for ch in characters_to_remove_in_name:
        text = text.replace(ch, "")
    return text

def removeCharInPrice(text):
    characters_to_remove_in_price = "!()@€[], 'qwertyuiopasdfghjklzxcvbnm<>$"
    for ch in characters_to_remove_in_price:
        text = text.replace(ch, "")

    return text

def CheckIngredientExists(ingredient):
    sql = "SELECT Name FROM {table} WHERE Name = '{IngredientName}'".format(
        table="ingredient",
        IngredientName=ingredient
    )

    cursor.execute(sql)
    result = cursor.fetchall()

    if len(result) == 0:
        print(ingredient, " ingredient")
        return False
    else:
        print("Ingredient", ingredient, "already exsists")
        return True

def TaxImport():
    sql = "INSERT INTO tax (Tax, Description , CreatedOn, CreatedBy, LastUpdate, UpdateBy ) VALUES (%s, %s, %s, %s, %s, %s)"
    val = (9, "9% BTW", timeStamp, user, timeStamp, user)
    cursor.execute(sql, val)

    mariosDB.commit()
    print(cursor.rowcount, "record inserted")
    sql = "INSERT INTO tax (Tax, Description , CreatedOn, CreatedBy, LastUpdate, UpdateBy ) VALUES (%s, %s, %s, %s, %s, %s)"
    val = (21, "21% BTW", timeStamp, user, timeStamp, user)
    cursor.execute(sql, val)

    mariosDB.commit()
    print(cursor.rowcount, "record inserted")


def IngredientImport():

#   Data kan ik de while loop worden geimporteert.

    df = pd.read_csv (r'C:\Users\harmv\OneDrive\Bureaublad\Extra Ingredienten.csv')
    arrayData = df.values
    arrayLen = len(arrayData)
    i = 0
    while i < arrayLen:
        string1 = str(arrayData[i])
        name1,price1=string1.split(";")
        name1 = removeCharInName(name1)
        price1 = removeCharInPrice(price1)
        price1 = float(price1)

        Check = CheckIngredientExists(name1)

    

        sql = "INSERT INTO ingredient (Name, Price, Tax_ID, CreatedOn, CreatedBy, LastUpdate, UpdateBy ) VALUES (%s, %s, %s, %s, %s, %s, %s)"
        val = (name1, price1, 1, timeStamp, user, timeStamp, user)
        cursor.execute(sql, val)

        mariosDB.commit()
        logInsert = "{} time {} is inserted"
        log.append(logInsert.format(cursor.rowcount, name1))
        i+=1

if __name__ == '__main__':
    TaxImport()
    print(" ")
    IngredientImport()

    print(log)

