import mysql.connector
from datetime import datetime
import re
import sys
import configparser

shopTable = 'shop'
logFile = './logs/shops_log.txt'

def createDbConnector():
    try:
        global mydb
        mydb = mysql.connector.connect(
            host = dbHost,
            user = dbUser,
            password = dbPassword,
            database = dbTable
        )
    except:
        log("! MySQL error !")
        exit()

def importStore(filename):
    log("Open file")

    # Get all line from file
    shopFile = open(filename, "r")
    lines = shopFile.readlines()

    # Create string array
    shopInfo = ["" for x in range(7)]
    i = 0

    # loop trough lines
    for line in lines:

        # Check if line start with --
        if bool(re.match("^-{2}", line)):
            continue

        # Check if line is empty
        if not line.strip():
            i = 0
            handleReccords(shopInfo)
            continue

        # Set line in info, remove nextline and trailing whitespace
        shopInfo[i] = line.strip('\n').strip()
        i += 1


# Handle shop data
def handleReccords(shopInfo):
    # Check if data is set
    if shopInfo[0] == '':
        return

    # check if shop exists
    if not checkShopExists(shopInfo):
        addShop(shopInfo)


# Check of shop/address exists
def checkShopExists(shopInfo):
    query = "SELECT * FROM {ShopTable} WHERE name = '{Name}' AND StreetName = '{StreetName}' AND HouseNumber = '{HouseNumber}' AND Zipcode = '{Zipcode}'".format(
        ShopTable=shopTable,
        Name=shopInfo[0],
        StreetName=shopInfo[1],
        HouseNumber=shopInfo[2],
        # Remove spaces, to uppercase
        Zipcode=shopInfo[5].replace(" ", "").upper()
    )

    mycursor = mydb.cursor()
    mycursor.execute(query)
    result = mycursor.fetchall()

    # Log result
    if len(result) == 0:
        return False
    else:
        return True


def addShop(shopInfo):
    log("Adding shop")
    dtNow = datetime.now()
   
    sql = "INSERT INTO shop (Name, Phone, Email ,StreetName, HouseNumber, Zipcode, City, CreatedOn, CreatedBy, LastUpdate, UpdateBy) VALUES(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
    val = (
        shopInfo[0],
        shopInfo[6],
        "",  # Email not given
        shopInfo[1],
        shopInfo[2],
        shopInfo[5].replace(" ", "").upper(),  # Remove spaces, to uppercase
        shopInfo[3],
        dtNow.strftime("%Y-%m-%d %H:%M:%S"),
        "System - import",
        dtNow.strftime("%Y-%m-%d %H:%M:%S"),
        "System - import"
    )
    mycursor = mydb.cursor()
    mycursor.execute(sql, val)
    mydb.commit()
    log("Shop inserted, ID: " + str(mycursor.lastrowid))

def log(text):
    print(text)
    dtnow = datetime.now()
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
    log("--- Start importer ---")
    
    setConfig()
    
    createDbConnector()

    if len(sys.argv) < 2:
        log('!! Missing argument!')
        exit()

    filename = sys.argv[1]
    importStore(filename)
