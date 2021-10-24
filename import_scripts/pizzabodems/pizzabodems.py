import pandas as pd
import mysql.connector
from mysql.connector import Error
# import pymysql
from openpyxl import load_workbook

df = pd.read_excel('C:\\Users\\Mikel\\IdeaProjects\\mario_import\\import_scripts\\pizzabodems\\pizzabodems.xlsx')
print(df.to_string())
table = "temporaryPizzaBottoms"


def createDbConnector():
    try:
        global mydb
        mydb = mysql.connector.connect(
        # mydb = pymysql.connect(
            host= 'localhost',
            port='330',
            user='root',
            password='televisie',
            database='marios_pizza'
        )
        global cursor
        cursor = mydb.cursor()
    except Error as e:
        print("Kan database niet bereiken." + e)

def createTable():
    try:
        query = "create  table " + table + "(naam varchar(254), diameter varchar(254), omschrijving varchar(254), toeslag varchar(254), beschikbaar varchar(254))"
        cursor.execute(query)
    except:
        cleanQuery = "drop table " + table
        cursor.execute(cleanQuery)
        createTable()

def fillTable():
    cols = ",".join([str(i) for i in df.columns.tolist()])
    try:
        for (i,row) in df.iterrows():
            query = "insert into " + table + "(" + cols + ") values (" + "%s,"*(len(row)-1) + "%s)"
            cursor.execute(query, tuple(row))
        mydb.commit()
        print("Filled table: " + table)
    except Error as e:
        print(e)

def callProc():
    cursor.callproc('proc_fill_pizzabottom')

createDbConnector()
createTable()
fillTable()
callProc()
mydb.close()


