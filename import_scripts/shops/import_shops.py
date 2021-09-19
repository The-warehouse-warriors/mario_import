import mysql.connector
from datetime import datetime
import re

mydb = mysql.connector.connect(
    host="localhost",
    user="admin",
    password="<nope>",
    database="marios_pizza"
)
addressTable = 'addressinfo'
shopTable = 'shop'


def import_store(filename):

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

    print("--- Handle Reccord--")
    print('Naam: ' + shopInfo[0])

    # check if shop exists
    if not checkShopExists(shopInfo):
        # NOT: Add shop
        addShop(shopInfo)


# Check of shop/address exists
def checkShopExists(shopInfo):
    print("--- Check shop ---")

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

    # Print result
    if len(result) == 0:
        print('No shop found')
        return False
    else:
        print('shop found')
        return True


def addShop(shopInfo):

    dtNow = datetime.now()

    print("--- Adding shop ---")
    print(dtNow.strftime("%Y-%m-%d %H:%M:%S"))
    print('Naam: ' + shopInfo[0])
    print('Straat: ' + shopInfo[1])
    print('Nummer: ' + shopInfo[2])
    print('Stad: ' + shopInfo[3])
    print('Land: ' + shopInfo[4])
    print('Postcode: ' + shopInfo[5].replace(" ", ""))
    print('Telefoon: ' + shopInfo[6])

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
    print("shop inserted, ID:", mycursor.lastrowid)
    print("\n")


if __name__ == '__main__':
    print("--- Start importer ---\n")
    import_store('Winkels Mario.txt')
