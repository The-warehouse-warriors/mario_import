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
global df

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
                   'Extra Ingredi??nten',
                   'Prijs Extra Ingredi??nten', 'Regelprijs', 'RegelprijsDecimal', 'Totaalprijs', 'TotaalprijsDecimal',
                   'CouponID', 'Gebruikte Coupon',
                   'Coupon Korting', 'Te Betalen', 'TeBetalenDecimal', 'ErrorDetails']
    log('Extra columns are being added: {}'.format('\n'.join(header_list)))

    # Appending extra columns
    df = df.reindex(columns=header_list)

    # Show all columnheaders
    log('Current columns are: {}'.format(df.columns))

    # Replacing comma's for dots
    log("Replacing comma's for dots")
    df.Prijs = df.Prijs.str.replace(',', '.')
    df.Bezorgkosten = df.Bezorgkosten.str.replace(',', '.')
    df['Prijs Extra Ingredi??nten'] = df['Prijs Extra Ingredi??nten'].astype(str).str.replace(',', '.')
    df.Regelprijs = df.Regelprijs.str.replace(',', '.')
    df.Totaalprijs = df.Totaalprijs.str.replace(',', '.')
    df['Totaalprijs'] = df['Totaalprijs'].fillna(0)
    df['Coupon Korting'] = df['Coupon Korting'].str.replace(',', '.')
    df['Te Betalen'] = df['Te Betalen'].str.replace(',', '.')

    # Extract floats
    log("String to float conversion")
    df.Prijs = df.Prijs.str.extract('(\d*\.\d+|\d+)', expand=True).astype(float)
    df.Bezorgkosten = df.Bezorgkosten.str.extract('(\d*\.\d+|\d+)', expand=True).astype(float)
    df['Prijs Extra Ingredi??nten'] = df['Prijs Extra Ingredi??nten'].astype(str).str.extract('(\d*\.\d+|\d+)',
                                                                                            expand=True).astype(float)
    df.Regelprijs = df.Regelprijs.str.extract('(\d*\.\d+|\d+)', expand=True).astype(float)
    df['Coupon Korting'] = df['Coupon Korting'].str.extract('(\d*\.\d+|\d+)', expand=True).astype(float)
    df['Te Betalen'] = df['Te Betalen'].str.extract('(\d*\.\d+|\d+)', expand=True).astype(float)
    # df['Totaalprijs'] = df['Totaalprijs'].str.extract('(\d*\.\d+|\d+)', expand=True).astype(float)
    df.TotaalprijsDecimal = df.Totaalprijs.str.extract('(\d*\.\d+|\d+)', expand=True).astype(float)

    log('Exporting csv file, location: {}'.format(tempCsv))
    df.to_csv(tempCsv, sep=';', encoding='utf-8', decimal=".", index_label='ID')


def executeImportOrderDataSP():
    try:
        log('call ImportTempZipcodes')
        # Create and execute query
        sql = "call ImportTempZipcodes();"
        mycursor = mydb.cursor()
        mycursor.execute(sql)
        mydb.commit()
        log("SP called")
    except Exception as err:
        log(err)
        return


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


def bulkImport():
    # Truncate MarioOrderData first
    try:
        sql = "truncate marioorderdata01;"
        mycursor = mydb.cursor()
        mycursor.execute(sql)
        mydb.commit()
        log("Truncated marioorderdata01")
    except Exception as err:
        log(err)
        # Stop process on error
        return

    try:
        # Create connection
        SQLUri = 'mysql+pymysql://%s:%s@%s/%s' % (dbUser, dbPassword, dbHost, dbTable)

        # Import csv to sql with pandas
        dfCSV = pd.read_csv(tempCsv, sep=';', encoding='utf-8', decimal=".")

        # Table name
        # Connection uri
        # Replace data
        # Create no indexes
        dfCSV.to_sql(SQLMarioOrderDataTable, con=SQLUri, if_exists='append', index=False)
    except Exception as err:
        log(err)
        # Stop process on error
        return

    log("Done with CSV import")


# Truncate table
def truncateTable(tableName):
    try:
        # Create and execute query
        query = "TRUNCATE marios_pizza.{Table}".format(
            Table=tableName
        )
        mycursor = mydb.cursor()
        mycursor.execute(query)
        result = mycursor.fetchall()

        # Check if a result is returned
        if len(result) == 0:
            return False
        else:
            return True
    except pyodbc.Error as e:
        log(e)
    return False


# Update storeID on MarioOrderData table
def executeUpdateWinkelIDOnOrderDataSP():
    try:
        log('CALL `proc_update_WinkelID`();')
        # Create and execute query
        sql = "call proc_update_WinkelID();"
        mycursor = mydb.cursor()
        mycursor.execute(sql)
        mydb.commit()
        log("SP called")
    except Exception as err:
        log(err)
        return


def checkIfDeliveryDateTimeAndOrderDataNotNull():
    try:
        # Create and execute query
        query = "UPDATE marios_pizza.marioorderdata01 SET ErrorDetails = 'Incorrect Besteldatum, Afleverdatum or Aflevermoment' WHERE Besteldatum LIKE '%,%' OR AfleverDatum LIKE '%,%' OR AfleverMoment LIKE '%,%' OR AfleverMoment LIKE '%PM%' OR AfleverMoment LIKE '%AM%' OR AfleverMoment NOT LIKE '%:%' OR AfleverMoment IS NULL OR AfleverDatum IS NULL OR Besteldatum IS NULL;"

        mycursor = mydb.cursor()
        mycursor.execute(query)
        result = mycursor.fetchall()

        # Check if a result is returned
        if len(result) == 0:
            return False
        else:
            return True
    except pyodbc.Error as e:
        log(e)
    return False


def checkIfStoreIDisNotNull():
    try:
        # Create and execute query
        query = "UPDATE marios_pizza.marioorderdata01 destTable SET ErrorDetails = 'No store found for this row' " \
                "WHERE WinkelID IS NULL; "

        mycursor = mydb.cursor()
        mycursor.execute(query)
        result = mycursor.fetchall()

        # Check if a result is returned
        if len(result) == 0:
            return False
        else:
            return True
    except pyodbc.Error as e:
        log(e)
    return False


# Derive customers from orders
def executeDeriveCustomersFromOrderDataSP():
    try:
        log('CALL `proc_derive_Customers_from_OrderData`();')
        # Create and execute query
        sql = "call proc_derive_Customers_from_OrderData();"
        mycursor = mydb.cursor()
        mycursor.execute(sql)
        mydb.commit()
        log("SP called")
    except Exception as err:
        log(err)
        return


# Update order table with customerID
def executeUpdateCustomerIDToOrderDataSP():
    try:
        log('CALL `proc_Update_Order_Customer_ID`();')
        # Create and execute query
        sql = "call proc_Update_Order_Customer_ID();"
        mycursor = mydb.cursor()
        mycursor.execute(sql)
        mydb.commit()
        log("SP called")
    except Exception as err:
        log(err)
        return


# Update customer address table with address from orderdata table, GROUP BY Woonplaats, Adres: 12 sec -> 0.2
def executeDeriveCustomerAddressFromOrderDataSP():
    try:
        log('CALL `proc_insertCustomerAddress`();')
        # Create and execute query
        sql = "call proc_insertCustomerAddress();"
        mycursor = mydb.cursor()
        mycursor.execute(sql)
        mydb.commit()
        log("SP called")
    except Exception as err:
        log(err)
        return


# Update customer address table with address from orderdata table, GROUP BY Woonplaats, Adres: 12 sec -> 0.2
def executeDeriveCouponsFromOrderDataSP():
    try:
        log('CALL `proc_derive_Coupons_From_OrderData_And_Insert`();')
        # Create and execute query
        sql = "call proc_derive_Coupons_From_OrderData_And_Insert();"
        mycursor = mydb.cursor()
        mycursor.execute(sql)
        mydb.commit()
        log("SP called")
    except Exception as err:
        log(err)
        return


# Update customer address table with address from orderdata table, GROUP BY Woonplaats, Adres: 12 sec -> 0.2
def executeUpdateCouponIDOnOrderDataSP():
    try:
        log('CALL `proc_update_CouponID_on_MarioOrderData`();')
        # Create and execute query
        sql = "call proc_update_CouponID_on_MarioOrderData();"
        mycursor = mydb.cursor()
        mycursor.execute(sql)
        mydb.commit()
        log("SP called")
    except Exception as err:
        log(err)
        return


# Update customer address table with address from orderdata table, GROUP BY Woonplaats, Adres: 12 sec -> 0.2
def executeDeriveDeliverTypeOrderDataSP():
    try:
        log('CALL proc_derive_DeliverType_from_OrderData();')
        # Create and execute query
        sql = "call proc_derive_DeliverType_from_OrderData();"
        mycursor = mydb.cursor()
        mycursor.execute(sql)
        mydb.commit()
        log("SP called")
    except Exception as err:
        log(err)
        return


# Update customer address table with address from orderdata table, GROUP BY Woonplaats, Adres: 12 sec -> 0.2
def executeUpdateDeliverTypeIDOrderDataSP():
    try:
        log('CALL proc_update_DeliverTypeID_on_OrderData();')
        # Create and execute query
        sql = "call proc_update_DeliverTypeID_on_OrderData();"
        mycursor = mydb.cursor()
        mycursor.execute(sql)
        mydb.commit()
        log("SP called")
    except Exception as err:
        log(err)
        return


def executeDeriveOrdersOrderDataSP():
    try:
        log('CALL proc_derive_Orders_From_MarioData();')
        # Create and execute query
        sql = "call proc_derive_Orders_From_MarioData();"
        mycursor = mydb.cursor()
        mycursor.execute(sql)
        mydb.commit()
        log("SP called")
    except Exception as err:
        log(err)
        return


def executeUpdateOrderIDonOrderDataSP():
    try:
        log('CALL proc_update_OrderID_on_MarioOrderData();')
        # Create and execute query
        sql = "call proc_update_OrderID_on_MarioOrderData();"
        mycursor = mydb.cursor()
        mycursor.execute(sql)
        mydb.commit()
        log("SP called")
    except Exception as err:
        log(err)
        return


def executeStoredProcedure(storedProcedure):
    try:
        log('CALL {sProcedure}();'.format(sProcedure=storedProcedure))
        # Create and execute query
        sql = "call {sProcedure}();".format(sProcedure=storedProcedure)
        mycursor = mydb.cursor()
        mycursor.execute(sql)
        mydb.commit()
        log("SP {sProcedure} called".format(sProcedure=storedProcedure))
    except Exception as err:
        log(err)
        return


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
    log('Truncating table')
    truncateTable(SQLMarioOrderDataTable)
    log('Bulk insert csv file {} into table {}'.format(tempCsv, SQLMarioOrderDataTable))
    bulkImport()

    # Filter evil stuff:
    checkIfDeliveryDateTimeAndOrderDataNotNull()

    # Update storeID
    executeUpdateWinkelIDOnOrderDataSP()

    # Verify if every order item has a store
    checkIfStoreIDisNotNull()

    # Derive Customers from order data
    executeDeriveCustomersFromOrderDataSP()

    # `proc_Update_Order_Customer_ID`(
    executeUpdateCustomerIDToOrderDataSP()

    #
    executeDeriveCustomerAddressFromOrderDataSP()

    #
    executeDeriveCouponsFromOrderDataSP()

    #
    executeUpdateCouponIDOnOrderDataSP()

    #
    executeDeriveDeliverTypeOrderDataSP()

    # `proc_update_DeliverTypeID_on_OrderData`()
    executeUpdateDeliverTypeIDOrderDataSP()

    # Derive orders from orderdata
    executeDeriveOrdersOrderDataSP()

    # Update MarioOrderData with order ID
    executeUpdateOrderIDonOrderDataSP()

    # Update productID in marioorderdata with PizzaIDs : Duration: 8.8s
    executeStoredProcedure('proc_update_ProductID_with_PizzaIDs_on_marioorderdata')

    # Update productID in marioorderdata with NonPizzaIDs : Duration: 5,234s
    executeStoredProcedure('proc_update_ProductID_with_NonPizzaIDs_on_marioorderdata')

    # Update PizzaBottomID in marioorderdata : Duration: s
    executeStoredProcedure('proc_update_PizzaBodemID_on_marioorderdata')

    # Update PizzaSausID in marioorderdata : Duration: s
    executeStoredProcedure('proc_update_PizzaSausID_on_marioorderdata')

    # Update  in marioorderdata : Duration: s
    executeStoredProcedure()

    # Update  in marioorderdata : Duration: s
    executeStoredProcedure()

    # Update  in marioorderdata : Duration: s
    executeStoredProcedure()

    # Update  in marioorderdata : Duration: s
    executeStoredProcedure()

    # Update  in marioorderdata : Duration: s
    executeStoredProcedure()

    # Final msg with total run time in seconds
    log('--- DONE import order data, took: {0:2f} seconds to run'.format(time.time() - start))
