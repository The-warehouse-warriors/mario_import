SHOW CREATE TABLE new_schema.marioorderdata01;

CREATE TABLE `marioorderdata01` (\n  `ID` int NOT NULL,\n  `Winkelnaam` text,\n  `Klantnaam` text,\n  `TelefoonNr` text,\n  `Email` text,\n  `Adres` text,\n  `Woonplaats` text,\n  `Besteldatum` text,\n  `AfleverType` text,\n  `AfleverDatum` text,\n  `AfleverMoment` text,\n  `Product` text,\n  `PizzaBodem` text,\n  `PizzaSaus` text,\n  `Prijs` text,\n  `Bezorgkosten` text,\n  `Aantal` text,\n  `Extra IngrediÃ«nten` text,\n  `Prijs Extra IngrediÃ«nten` text,\n  `Regelprijs` text,\n  `Totaalprijs` text,\n  `Gebruikte Coupon` text,\n  `Coupon Korting` text,\n  `Te Betalen` text,\n  PRIMARY KEY (`ID`)\n) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci' 

CREATE DATABASE `marios_pizza` /*!40100 DEFAULT CHARACTER SET utf8 */ /*!80016 DEFAULT ENCRYPTION='N' */;
