import numpy as np
import pandas as pd
import time

# Variables
start = time.time()
extendedLogging = 0
skipFirstRows = 0


def printRowsOfDataFrame(dataFrameVariable):
    index = dataFrameVariable.index
    number_of_rows = len(index)
    return number_of_rows


# Read datafile
df = pd.read_csv('C:\\Fontys\\Code\\MarioOrderData04_10000.csv', sep=';', skiprows=skipFirstRows)

# Print rows
print(printRowsOfDataFrame(df))

# For console output show all columns and first 10 rows
if extendedLogging == 1:
    pd.set_option('display.max_columns', None)
    print(df[0:10])

# Replace all NAN elements in columns with value from above item
cols = ['Winkelnaam', 'Klantnaam', 'TelefoonNr', 'Email', 'Adres', 'Woonplaats', 'Besteldatum', 'AfleverType',
        'AfleverDatum', 'AfleverMoment']
df[cols] = df[cols].ffill()
print(df.columns)
# Adding extra columns
header_list = ['WinkelID', 'Winkelnaam', 'CustomerID', 'Klantnaam', 'TelefoonNr', 'Email', 'AddressID', 'Adres',
               'Woonplaats', 'OrderID', 'Besteldatum', 'DeliveryTypeID', 'AfleverType', 'AfleverDatum', 'AfleverMoment', 'ProductID',
               'NonProductID',
               'Product', 'PizzaBodemID','PizzaBodem', 'PizzaSausID','PizzaSaus', 'Prijs', 'Bezorgkosten', 'BezorgkostenDecimal', 'Aantal',
               'Extra Ingrediënten',
               'Prijs Extra Ingrediënten', 'Regelprijs', 'RegelprijsDecimal', 'Totaalprijs', 'TotaalprijsDecimal',
               'CouponID', 'Gebruikte Coupon',
               'Coupon Korting', 'Te Betalen', 'TeBetalenDecimal']

# Appending extra columns
df = df.reindex(columns=header_list)

# Show all columnheaders
print(df.columns)

# Replacing comma's for dots
df.Prijs = df.Prijs.str.replace(',', '.')
df.Bezorgkosten = df.Bezorgkosten.str.replace(',', '.')
df['Prijs Extra Ingrediënten'] = df['Prijs Extra Ingrediënten'].astype(str).str.replace(',', '.')
df.Regelprijs = df.Regelprijs.str.replace(',', '.')
df.Totaalprijs = df.Totaalprijs.str.replace(',', '.')
df['Totaalprijs'] = df['Totaalprijs'].fillna(0)
df['Coupon Korting'] = df['Coupon Korting'].str.replace(',', '.')
df['Te Betalen'] = df['Te Betalen'].str.replace(',', '.')

# Extract floats
df.Prijs = df.Prijs.str.extract('(\d*\.\d+|\d+)', expand=True).astype(float)
df.Bezorgkosten = df.Bezorgkosten.str.extract('(\d*\.\d+|\d+)', expand=True).astype(float)
df['Prijs Extra Ingrediënten'] = df['Prijs Extra Ingrediënten'].astype(str).str.extract('(\d*\.\d+|\d+)', expand=True).astype(float)
df.Regelprijs = df.Regelprijs.str.extract('(\d*\.\d+|\d+)', expand=True).astype(float)
df['Coupon Korting'] = df['Coupon Korting'].str.extract('(\d*\.\d+|\d+)', expand=True).astype(float)
df['Te Betalen'] = df['Te Betalen'].str.extract('(\d*\.\d+|\d+)', expand=True).astype(float)
# df['Totaalprijs'] = df['Totaalprijs'].str.extract('(\d*\.\d+|\d+)', expand=True).astype(float)
df.TotaalprijsDecimal = df.Totaalprijs.str.extract('(\d*\.\d+|\d+)', expand=True).astype(float)

# Putting floats in the correct columns



# Export DataFrame, empty rows are deleted
df.to_csv('C:\\Fontys\\Code\\MarioOrderData01_Modified4.csv', sep=';', encoding='utf-8', decimal=".")

# Print script runtime
print('The script took: {0:2f} seconds to run'.format(time.time() - start))
