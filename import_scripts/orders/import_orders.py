import numpy as np
import pandas as pd
import time
from datetime import datetime
import sys

# Create needed Vars
start = time.time()

logFile = './logs/order_log.txt'
tempCsv = './temp/ordersModified.csv'
dbUser = 'root'
dbPassword = 'toor'
SQLUri = 'mysql+pymysql://%s:%s@localhost/marios_pizza' % (dbUser, dbPassword)
SQLOrderTable = 'marioorderdata01'


def printRowsOfDataFrame(dataFrameVariable):
    index = dataFrameVariable.index
    number_of_rows = len(index)
    return number_of_rows


def importOrder(filename):
    try:
        # Read datafile
        df = pd.read_csv(filename, sep=';', skiprows=skipFirstRows)

        # Print rows
        print(printRowsOfDataFrame(df))
        # print(df[0:10])
        # print(df.head())

        # For console output show all columns and first 10 rows
        if extendedLogging == 1:
            pd.set_option('display.max_columns', None)
            # print(df[0:10])

        # Select all customer data before filling up emtpy fields
        dfCustomers = df[['Klantnaam', 'TelefoonNr', 'Email', 'Adres', 'Woonplaats']]
        # print(dfCustomers[0:10])

        # Replace all NAN elements in columns
        cols = ['Winkelnaam', 'Klantnaam', 'TelefoonNr', 'Email', 'Adres', 'Woonplaats', 'Besteldatum', 'AfleverType',
                'AfleverDatum', 'AfleverMoment']
        df[cols] = df[cols].ffill()

        header_list = ['WinkelID', 'Winkelnaam', 'CustomerID', 'Klantnaam', 'TelefoonNr', 'Email', 'AddressID', 'Adres',
                       'Woonplaats', 'OrderID', 'Besteldatum', 'DeliveryTypeID', 'AfleverType', 'AfleverDatum',
                       'AfleverMoment', 'Product', 'PizzaBodem', 'PizzaSaus', 'Prijs', 'Bezorgkosten', 'Aantal',
                       'Extra IngrediÃ«nten', 'Prijs Extra IngrediÃ«nten', 'Regelprijs', 'Totaalprijs', 'CouponID',
                       'Gebruikte Coupon', 'Coupon Korting', 'Te Betalen']

        # Adding extra columns
        df = df.reindex(columns=header_list)

        # Export DataFrame, empty rows are deleted
        df.to_csv(tempCsv, sep=';', encoding='utf-8')

    except Exception as err:
        log(err)
        # Stop process on error
        return

    try:
        # Import CSV to database
        df = pd.read_csv(tempCsv)
        df.to_sql(SQLOrderTable, con=SQLUri, if_exists='replace', index=False)
    except Exception as err:
        log(err)
        # Stop process on error
        return


# Call stored procedures
def callSP():
    # Create MySql connector
    try:
        global mydb
        mydb = mysql.connector.connect(
            host="localhost",
            user=dbUser,
            password=dbPassword,
            database="marios_pizza"
        )
    except:
        log("!! MySQL error!")
        exit()

    ## Call SP X
    try:
        sql = "call XXXXX;"
        mycursor = mydb.cursor()
        mycursor.execute(sql)
        mydb.commit()
        log("SP called")
    except Exception as err:
        log(err)
        return


# Log text to file
def log(text):
    print(text)
    # Create a row in txt file with Datetime as prefix
    dtnow = datetime.now()
    with open(logFile, 'a') as logger:
        logger.write(str(dtnow) + ') ' + str(text) + '\n')


# Main function, called on start
if __name__ == '__main__':
    log("--- START import orders ---")

    # Set start time
    start = time.time()

    # Check given params
    if len(sys.argv) < 2:
        log("!! Missing argument !!")
        exit()

    # Select first param, and call main function
    filename = sys.argv[1]
    importOrder(filename)

    # After import completed, call SP's
    callSP()

    # Final msg with total run time in seconds
    log('--- DONE import orders, took: {0:2f} seconds to run'.format(time.time() - start))
