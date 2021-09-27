#import pandas as pd
#import mysql.connector
from openpyxl import load_workbook

#df = pd.read_excel('pizzabodems.xlsx')
#print(df.head())

# mydb = mysql.connector.connect(
#     host="localhost",
#     user="root",
#     password="televisie",
#     database="marios_pizza"
# )

#bottomTable = 'pizzabottom'
filename = load_workbook('pizzabodems.xlsx')
sheet = filename.active
rows = sheet.rows

def readBottom():
    headers = [cell.value for cell in next(rows)]
    print(headers)

    try:
        rowdata = next(rows)

        while rowdata != "":
            data = [cell.value for cell in rowdata]
            if data == "":
                break
            print(data)
            rowdata = next(rows)
    except StopIteration:
        print("Alle data is ontvangen")

#def importBottom(filename):

#Handle bottomdata
# def handleRecords(line):
#     if line == "":
#         return
#
#     print("--- Handle Record --")
#     print('Pizzabodem: ' + line)

readBottom()

