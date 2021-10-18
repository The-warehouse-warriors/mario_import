SHOW CREATE TABLE new_schema.marioorderdata01;

CREATE TABLE `marioorderdata01` (
  `ID` int NOT NULL,
  `Winkelnaam` text,
  `Klantnaam` text,
  `TelefoonNr` text,
  `Email` text,
  `Adres` text,
  `Woonplaats` text,
  `Besteldatum` text,
  `AfleverType` text,
  `AfleverDatum` text,
  `AfleverMoment` text,
  `Product` text,
  `PizzaBodem` text,
  `PizzaSaus` text,
  `Prijs` text,
  `Bezorgkosten` text,
  `Aantal` text,
  `Extra IngrediÃ«nten` text,
  `Prijs Extra IngrediÃ«nten` text,
  `Regelprijs` text,
  `Totaalprijs` text,
  `Gebruikte Coupon` text,
  `Coupon Korting` text,
  `Te Betalen` text,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci' 
