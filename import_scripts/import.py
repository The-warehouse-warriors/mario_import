import os
from datetime import datetime

logFile = './logs/import_log.txt'
tempFolder = './temp'
logFolder = './logs'
fileFolder = './files'

def log(text):
    print(text)
    dtnow = datetime.now()
    with open(logFile, 'a') as logger:
        logger.write(str(dtnow) + ') ' + text + '\n')

if __name__ == '__main__':
    log("--- Start importer ---\n")

    # Create needed folders
    if not os.path.exists(tempFolder):
        os.makedirs(tempFolder)
    if not os.path.exists(logFolder):
        os.makedirs(logFolder)
    if not os.path.exists(fileFolder):
        os.makedirs(fileFolder)
        log('missing import files!')
        exit()
        

    log("Import Tax")
    os.system("python .\TaxImport\import_tax.py .//files/tax_import.csv")
    log("Done with Tax, view tax_log.txt")

    log("Import ingredients")
    os.system("python .\Ingredienten\import_ingredienten.py .//files/Extra_Ingredienten.csv")
    log("Done with ingredients, view ingredients_log.txt")

    log("Import shops")
    os.system("python .\shops\import_shops.py .//files/WinkelsMario.txt")
    log("Done with shops, view shops_log.txt")

    log("Import zipcodes")
    os.system("python .\zipcodes\import_zipcodes.py .//files/Postcode_tabel.mdb")
    log("Done with shops, view zipcode_log.txt")

    log("Import PizzaBottoms")
    os.system("python .\pizzabodems\ImportPizzaBottoms.py .//files")
    log("Done with shops, view pizzabottoms.txt")

    log("Import PizzaIngredients")
    os.system("python .\Ingredienten\importPizzaIngredients.py .//files")
    log("Done with shops, view PizzaIngredients.txt")

    log("Import OtherProducts")
    os.system("python .\otherproducts\ImportOtherProducts.py .//files")
    log("Done with shops, view OtherProducts.txt")

    log("Import orders")
    os.system("python .\orders\ImportAllOrderFiles.py .//files")
    log("Done with orders, view orders-log.txt")