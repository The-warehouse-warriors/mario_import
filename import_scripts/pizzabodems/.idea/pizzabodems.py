import pandas as pd
import mysql.connector
# import pymysql
from openpyxl import load_workbook

df = pd.read_excel('pizzabodems.xlsx')
print(df.to_string())
table = "temporaryPizzaBottoms"


def createDbConnector():
    try:
        global mydb
        mydb = mysql.connector.connect(
        # mydb = pymysql.connect(
            host='localhost',
            port='330',
            user='root',
            password='televisie',
            database='marios_pizza'
        )
        global cursor
        cursor = mydb.cursor()
    except:
        print("Kan database niet bereiken.")

def createTable():
    try:
        query = "create  table " + table + "(name varchar(254), diameter varchar(254), omschrijving varchar(254), toeslag varchar(254), beschikbaar varchar(254))"
        cursor.execute(query)
    except:
        cleanQuery = "drop table " + table
        cursor.execute(cleanQuery)
        createTable()

def fillTable():
    cols = "`,`".join([str(i) for i in df.columns.tolist()])
    try:
        for (i,row) in df.itterrows():
            # naam = rs[0]
            # diameter = rs[1]
            # omschrijving = rs[2]
            # toeslag = rs[3]
            # beschikbaar = rs[4]
            query = "insert into '" + table + "'('" + cols + "') values (" + "%s,"*(len(row)-1) + "%s)"
            # val = (naam, diameter, omschrijving, toeslag, beschikbaar)
            cursor.execute(query, tuple(row))
            mydb.commit()
            print("Filled table: " + table)
    except:
        print("Can't fill table: " + table + "!")

# bottomTable = 'pizzabottom'
# filename = load_workbook('pizzabodems.xlsx')
# sheet = filename.active
# rows = sheet.rows
#
# def readBottom():
#     headers = [cell.value for cell in next(rows)]
#     print(headers)
#
#     try:
#         rowdata = next(rows)
#
#         while rowdata != "":
#             data = [cell.value for cell in rowdata]
#             if data == "":
#                 break
#             print(data)
#             rowdata = next(rows)
#     except StopIteration:
#         print("Alle data is ontvangen")

#def importBottom(filename):

#Handle bottomdata
# def handleRecords(line):
#     if line == "":
#         return
#
#     print("--- Handle Record --")
#     print('Pizzabodem: ' + line)
#
createDbConnector()
createTable()
fillTable()
mydb.close()


