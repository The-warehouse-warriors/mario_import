import mysql.connector

mydb = mysql.connector.connect(
    host="localhost",
    user="admin",
    password="RBNYFT9o34fgCh0r6",
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
    query = "SELECT * FROM {shopTable} LEFT JOIN {addressTable} a on shop.AddressInfo_ID = a.ID WHERE Name = '{name}' AND Street = '{street}' AND Number = '{number}' AND PostalCode = '{Postcode}'".format(
        shopTable=shopTable,
        addressTable=addressTable,
        name=shopInfo[0],
        street=shopInfo[1],
        number=shopInfo[2],
        Postcode=shopInfo[5].replace(" ", "")
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
    print("--- Adding shop ---")
    print('Naam: ' + shopInfo[0])
    print('Straat: ' + shopInfo[1])
    print('Nummer: ' + shopInfo[2])
    print('Stad: ' + shopInfo[3])
    print('Land: ' + shopInfo[4])
    print('Postcode: ' + shopInfo[5].replace(" ", ""))
    print('Telefoon: ' + shopInfo[6])

    # Insert address first
    mycursor = mydb.cursor()
    sql = "INSERT INTO addressinfo (Street, Number, PostalCode, City) VALUES(%s, %s, %s, %s)"
    val = (shopInfo[1], shopInfo[2], shopInfo[5].replace(" ", ""), shopInfo[4])
    mycursor.execute(sql, val)
    mydb.commit()

    print("1 addressinfo inserted, ID:", mycursor.lastrowid)

    # Add shop with Adress ID
    sql = "INSERT INTO shop (Name, Phone, AddressInfo_ID) VALUES(%s, %s, %s)"
    val = (shopInfo[0], shopInfo[6], mycursor.lastrowid)
    mycursor.execute(sql, val)
    mydb.commit()

    print("1 shop inserted, ID:", mycursor.lastrowid)
    


if __name__ == '__main__':
    print("--- Start importer ---\n")
    import_store('Winkels Mario.txt')
