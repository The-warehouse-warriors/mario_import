import numpy as np
import pandas as pd
import time

# dfPizzaIngredients = pd.read_excel ('C:\\Fontys\\Code\\MarioData\\pizza_ingredienten.xlsx')
# print (dfPizzaIngredients['subcategorie'].unique())
# print (dfPizzaIngredients['pizzasaus_standaard'].unique())
# print (dfPizzaIngredients['productnaam'].unique())

# data_xls = pd.read_excel(excel_file, 'Untitled', index=0,skiprows=1, sep='|',encoding='utf-8')
dfOverigeproducten = pd.read_excel ('C:\\Fontys\\Code\\MarioData\\Overige producten.xlsx')
print (dfOverigeproducten)

# Adding extra columns
header_list = ['categorie','categorieUnique','categorieID',
               'subcategorie','subcategorieUnique','subcategorieID',
               'productnaam','productnaamUnique','productnaamID',
               'productomschrijving','productomschrijvingFiltered',
               'prijs','prijsDecimal',
               'spicy','spicyTrueFalse',
               'vegetarisch','vegetarischTrueFalse']

# Append extra columns
dfOverigeproducten = dfOverigeproducten.reindex(columns=header_list)

# Show all columnheaders
print(dfOverigeproducten.columns)

# Correct data to new columns
# dfOverigeproducten['prijs'] = dfOverigeproducten['prijs'].str.replace(',', '.')
# dfOverigeproducten['prijsDecimal'] = dfOverigeproducten['prijs'].str.extract('(\d*\.\d+|\d+)', expand=True).astype(float)

# Filter next lines characters
dfOverigeproducten['productomschrijvingFiltered'] = dfOverigeproducten['productomschrijving'].replace('\r','', regex=True).replace('\n', '', regex=True).replace('_x000D_', '', regex=True)
dfOverigeproducten['productomschrijving']= dfOverigeproducten['productomschrijving'].replace('\r','', regex=True).replace('\n', '', regex=True).replace('_x000D_', '', regex=True)

# Filter weird characters
dfOverigeproducten['categorieUnique'] = dfOverigeproducten['categorie'].replace('[\]\\[!@#$%.&*`,~^_{}:;<>\'/\\|()-]+','', regex=True).replace(' ', '', regex=True)
dfOverigeproducten['subcategorieUnique'] = dfOverigeproducten['subcategorie'].replace('[\]\\[!@#$%.&*`,~^_{}:;<>\'/\\|()-]+','', regex=True).replace(' ', '', regex=True)
dfOverigeproducten['productnaamUnique'] = dfOverigeproducten['productnaam'].replace('[\]\\[!@#$%.&*`,~^_{}:;<>\'/\\|()-]+','', regex=True).replace(' ', '', regex=True)

# Set true(1) or false(0)
dfOverigeproducten['spicyTrueFalse'] = dfOverigeproducten['spicy'].apply(lambda x: 1 if x == 'Ja' else '0')
dfOverigeproducten['vegetarischTrueFalse'] = dfOverigeproducten['vegetarisch'].apply(lambda x: 1 if x == 'Ja' else '0')





# Export to CSV
dfOverigeproducten.to_csv('C:\\Fontys\\Code\\MarioData\\Overigeproducten.csv', sep=';', encoding='utf-8', decimal=".", index_label='ID')