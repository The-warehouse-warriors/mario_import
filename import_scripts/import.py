import os

if __name__ == '__main__':
    print("--- Start importer ---\n")

    print("Import ingredients")
    os.system("python .\Ingredienten\main.py .//files/Ingredients.csv")

    print("Import shops")
    os.system("python .\shops\import_shops.py .//files/WinkelsMario.txt")

    print("Import zipcodes")
    os.system("python .\zipcodes\import_zipcodes.py .//files/Postcode_tabel.mdb")