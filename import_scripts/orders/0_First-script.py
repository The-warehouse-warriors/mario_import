import numpy as np
import pandas as pd
import time

# Variables
start = time.time()
extendedLogging = 0
skipFirstRows = 4

def printRowsOfDataFrame(dataFrameVariable):
    index = dataFrameVariable.index
    number_of_rows = len(index)
    return number_of_rows


# Read datafile
df = pd.read_csv('C:\\Fontys\\Code\\MarioOrderData01_10000.csv', sep=';', skiprows=skipFirstRows)

# Print rows
print(printRowsOfDataFrame(df))
# print(df[0:10])
# print(df.head())

# For console output show all columns and first 10 rows
if extendedLogging == 1:
    pd.set_option('display.max_columns', None)
    print(df[0:10])

# Select all customer data before filling up emtpy fields
dfCustomers = df[['Klantnaam', 'TelefoonNr', 'Email', 'Adres', 'Woonplaats']]
print(dfCustomers[0:10])


# Replace all NAN elements in columns
cols = ['Winkelnaam','Klantnaam','TelefoonNr','Email','Adres','Woonplaats','Besteldatum','AfleverType','AfleverDatum','AfleverMoment']
df[cols] = df[cols].ffill()

# Export DataFrame, empty rows are deleted
df.to_csv('C:\\Fontys\\Code\\MarioOrderData01_Modified.csv', sep=';', encoding='utf-8')

# Print script runtime
print('The script took: {0:2f} seconds to run'.format(time.time() - start))
