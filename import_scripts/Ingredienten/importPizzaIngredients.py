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
logFile = './logs/PizzaIngredients_log.txt'
tempCsv = './temp/PizzaIngredients.csv'
global df

# Database vars
SQLMarioOrderDataTable = "mariopizza_ingredienten"


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
    all_files = glob.glob(path + "/pizza_ingredienten*.xlsx")
    log('Number of files: ' + ', '.join(all_files))

    li = []

    for filename in all_files:
        log('Reading file: ' + filename)
        tempdf = pd.read_excel(filename)
        log('File: {} has {} rows'.format(filename, printRowsOfDataFrame(tempdf)))
        li.append(tempdf)
    df = pd.concat(li, axis=0, ignore_index=True)
    log('Current columns are: {}'.format(df.columns))

    # Adding extra columns
    header_list = ['categorie', 'categorieUnique', 'categorieID',
                   'subcategorie', 'subcategorieUnique', 'subcategorieID',
                   'productnaam', 'productnaamUnique', 'productnaamID',
                   'productomschrijving', 'productomschrijvingFiltered',
                   'prijs', 'prijsDecimal',
                   'bezorgtoeslag', 'bezorgtoeslagDecimal',
                   'spicy', 'spicyTrueFalse',
                   'vegetarisch', 'vegetarischTrueFalse',
                   'beschikbaar', 'beschikbaarTrueFalse',
                   'aantalkeer_ingredient', 'ingredientnaam', 'ingredientnaamID',
                   'pizzasaus_standaard', 'pizzasausID', 'ErrorDetails'
                   ]

    # Reindex columns
    df = df.reindex(columns=header_list)

    # Assign default values
    df['categorieID'] = 0
    df['subcategorieID'] = 0
    df['productnaamID'] = 0
    df['ingredientnaamID'] = 0
    df['pizzasausID'] = 0
    df['pizzasausID'] = 'text'

    df['productomschrijvingFiltered'] = df['productomschrijving'].replace('\r', '', regex=True).replace('\n', '',
                                                                                                        regex=True).replace(
        '_x000D_', '', regex=True)
    df['productomschrijving'] = df['productomschrijving'].replace('\r', '', regex=True).replace('\n', '',
                                                                                                regex=True).replace(
        '_x000D_', '', regex=True)

    # Filter weird characters
    df['categorieUnique'] = df['categorie'].replace('[\]\\[!@#$%.&*`’,~^_{}:;<>\'/\\|()-]+', '', regex=True).replace(
        ' ', '', regex=True)
    df['subcategorieUnique'] = df['subcategorie'].replace('[\]\\[!@#$%.&*`’,~^_{}:;<>\'/\\|()-]+', '',
                                                          regex=True).replace(' ', '', regex=True)
    df['productnaamUnique'] = df['productnaam'].replace('[\]\\[!@#$%.&*`’,~^_{}:;<>\'/\\|()-]+', '',
                                                        regex=True).replace(' ', '', regex=True)

    # Set true(1) or false(0)
    df['spicyTrueFalse'] = df['spicy'].apply(lambda x: 1 if x == 'Ja' else '0')
    df['vegetarischTrueFalse'] = df['vegetarisch'].apply(lambda x: 1 if x == 'Ja' else '0')
    df['beschikbaarTrueFalse'] = df['beschikbaar'].apply(lambda x: 1 if x == 'Ja' else '0')
    log('Current columns are: {}'.format(df.columns))

    log('Exporting csv file, location: {}'.format(tempCsv))
    df.to_csv(tempCsv, sep=';', encoding='utf-8', decimal=".", index_label='ID')

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
        sql = "truncate mariopizza_ingredienten;"
        mycursor = mydb.cursor()
        mycursor.execute(sql)
        mydb.commit()
        log("Truncated mariopizza_ingredienten")
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
        dfCSV.to_sql(SQLMarioOrderDataTable, con=SQLUri, if_exists='replace', index=False)
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

def setErrorDetailsToNull():
    try:
        # Create and execute query
        query = "UPDATE marios_pizza.mariopizza_ingredienten SET ErrorDetails = null ;"

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
    log('Bulk insert csv file {} into table {}'.format(tempCsv, SQLMarioOrderDataTable))
    bulkImport()
    setErrorDetailsToNull()

    # Derive Categories from proc_derive_Categories_From_MarioPizzaIngredienten : Duration: s
    executeStoredProcedure('proc_derive_Categories_From_MarioPizzaIngredienten')

    # Update CategorieID in proc_derive_Categories_From_MarioPizzaIngredienten : Duration: s
    executeStoredProcedure('proc_update_CategoryID_On_MariosPizza_Ingredienten')

    # Derive SubCategories in proc_derive_Categories_From_MarioPizzaIngredienten : Duration: s
    executeStoredProcedure('proc_derive_SubCategory_From_mariopizza_ingredienten')

    # Update  in proc_derive_Categories_From_MarioPizzaIngredienten : Duration: s
    executeStoredProcedure('proc_update_SubcategoryID_On_mariopizza_ingredienten')

    # Update  in proc_derive_Categories_From_MarioPizzaIngredienten : Duration: s
    executeStoredProcedure('proc_filter_MisMatch_Ingredients')

    # Update  in proc_derive_Categories_From_MarioPizzaIngredienten : Duration: s
    executeStoredProcedure('proc_update_IngredientID_on_mariopizza_ingredienten')

    # Update  in proc_derive_Categories_From_MarioPizzaIngredienten : Duration: s
    executeStoredProcedure('proc_update_SauceID_On_mariopizza_ingredienten')

    # Update  in proc_derive_Categories_From_MarioPizzaIngredienten : Duration: s
    executeStoredProcedure('proc_derive_Pizzas_From_mariopizza_ingredienten')

    executeStoredProcedure('proc_derive_PizzaIngredients_From_mariopizza_ingredienten')

    # Final msg with total run time in seconds
    log('--- DONE import order data, took: {0:2f} seconds to run'.format(time.time() - start))
