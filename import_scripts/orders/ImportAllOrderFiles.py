import io
import numpy as np
import pandas as pd
import time
import glob
import mysql
import mysql.connector
import pyodbc
from datetime import datetime
import sys
import configparser

# Variables
start = time.time()
extendedLogging = 0
skipFirstRows = 4
logFile = './logs/orderdata_log.txt'
tempCsv = './temp/MarioOrderData.csv'

# Database vars
SQLMarioOrderDataTable = "marioorderdata01"


# Return number of rows
def printRowsOfDataFrame(dataFrameVariable):
    index = dataFrameVariable.index
    number_of_rows = len(index)
    return number_of_rows


# Log text to file
def log(text):
    print(text)

    # Create a row in txt file with Datetime as prefix
    dtnow = datetime.now()
    with open(logFile, 'a') as logger:
        logger.write(str(dtnow) + ') ' + str(text) + '\n')


# Create connector for later use
def createDbConnector():
    try:
        global mydb
        mydb = mysql.connector.connect(
            host=dbHost,
            user=dbUser,
            password=dbPassword,
            database=dbTable
        )
    except:
        log("!! MySQL error !!")
        exit()


def importFiles(folderPath):
    # Read all datafiles
    path = folderPath  # use your path
    log('Folderpath is: ' + folderPath)
    all_files = glob.glob(path + "/MarioOrder*.csv")
    log('Number of files: ' + ', '.join(all_files))

    li = []

    for filename in all_files:
        log('Reading file: ' + filename)
        tempdf = pd.read_csv(filename, sep=';', skiprows=skipFirstRows)
        log('File: {} has {} rows'.format(filename, printRowsOfDataFrame(tempdf)))
        li.append(tempdf)
    df = pd.concat(li, axis=0, ignore_index=True)

    log('Empty rows removed and actual rows imported: {}'.format(printRowsOfDataFrame(df)))

    # Replace all NAN elements in columns with value from above item
    cols = ['Winkelnaam', 'Klantnaam', 'TelefoonNr', 'Email', 'Adres', 'Woonplaats', 'Besteldatum', 'AfleverType',
            'AfleverDatum', 'AfleverMoment']
    log('Empty fields in columns: {} \n will be filled with fielddata from parent'.format(', '.join(cols)))
    df[cols] = df[cols].ffill()
    log('Current columns are: {}'.format(df.columns))

    # Adding extra columns
    header_list = ['WinkelID', 'Winkelnaam', 'CustomerID', 'Klantnaam', 'TelefoonNr', 'Email', 'AddressID', 'Adres',
                   'Woonplaats', 'OrderID', 'Besteldatum', 'DeliveryTypeID', 'AfleverType', 'AfleverDatum',
                   'AfleverMoment', 'ProductID',
                   'NonProductID',
                   'Product', 'PizzaBodemID', 'PizzaBodem', 'PizzaSausID', 'PizzaSaus', 'Prijs', 'Bezorgkosten',
                   'BezorgkostenDecimal', 'Aantal',
                   'Extra Ingrediënten',
                   'Prijs Extra Ingrediënten', 'Regelprijs', 'RegelprijsDecimal', 'Totaalprijs', 'TotaalprijsDecimal',
                   'CouponID', 'Gebruikte Coupon',
                   'Coupon Korting', 'Te Betalen', 'TeBetalenDecimal']
    log('Extra columns are being added: {}'.format('\n'.join(header_list)))

    # Appending extra columns
    df = df.reindex(columns=header_list)

    # Show all columnheaders
    log('Current columns are: {}'.format(df.columns))

    # Replacing comma's for dots
    log("Replacing comma's for dots")
    df.Prijs = df.Prijs.str.replace(',', '.')
    df.Bezorgkosten = df.Bezorgkosten.str.replace(',', '.')
    df['Prijs Extra Ingrediënten'] = df['Prijs Extra Ingrediënten'].astype(str).str.replace(',', '.')
    df.Regelprijs = df.Regelprijs.str.replace(',', '.')
    df.Totaalprijs = df.Totaalprijs.str.replace(',', '.')
    df['Totaalprijs'] = df['Totaalprijs'].fillna(0)
    df['Coupon Korting'] = df['Coupon Korting'].str.replace(',', '.')
    df['Te Betalen'] = df['Te Betalen'].str.replace(',', '.')

    # Extract floats
    log("String to float conversion")
    df.Prijs = df.Prijs.str.extract('(\d*\.\d+|\d+)', expand=True).astype(float)
    df.Bezorgkosten = df.Bezorgkosten.str.extract('(\d*\.\d+|\d+)', expand=True).astype(float)
    df['Prijs Extra Ingrediënten'] = df['Prijs Extra Ingrediënten'].astype(str).str.extract('(\d*\.\d+|\d+)',
                                                                                            expand=True).astype(float)
    df.Regelprijs = df.Regelprijs.str.extract('(\d*\.\d+|\d+)', expand=True).astype(float)
    df['Coupon Korting'] = df['Coupon Korting'].str.extract('(\d*\.\d+|\d+)', expand=True).astype(float)
    df['Te Betalen'] = df['Te Betalen'].str.extract('(\d*\.\d+|\d+)', expand=True).astype(float)
    # df['Totaalprijs'] = df['Totaalprijs'].str.extract('(\d*\.\d+|\d+)', expand=True).astype(float)
    df.TotaalprijsDecimal = df.Totaalprijs.str.extract('(\d*\.\d+|\d+)', expand=True).astype(float)

    log('Exporting csv file, location: {}'.format(tempCsv))
    df.to_csv(tempCsv, sep=';', encoding='utf-8', decimal=".")

# Read config values from file into vars
def setConfig():
    # Read from config.ini
    config = configparser.ConfigParser()
    config.read('config.ini')

    # declare global vars
    global dbHost
    global dbTable
    global dbUser
    global dbPassword

    # set theses vars with the values
    dbHost = config.get('Database', 'dbHost')
    dbTable = config.get('Database', 'dbTable')
    dbUser = config.get('Database', 'dbUser')
    dbPassword = config.get('Database', 'dbPassword')


# Main function, called on start
if __name__ == '__main__':
    log("--- START import Orders ---")

    setConfig()

    # Set start time
    start = time.time()

    # Check/create Mysql connector
    createDbConnector()

    # Check given params
    if len(sys.argv) < 2:
        log("!! Missing argument !!")
        exit()

    # Select first param, and call main function
    folderPath = sys.argv[1]
    importFiles(folderPath)

    # Final msg with total run time in seconds
    log('--- DONE import order data, took: {0:2f} seconds to run'.format(time.time() - start))
