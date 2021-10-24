CREATE TABLE `addressinfo` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `HouseNumber` varchar(10) NOT NULL,
  `Address` varchar(100) NOT NULL,
  `Zipcode` varchar(6) DEFAULT NULL,
  `City` varchar(45) NOT NULL,
  `CreatedOn` datetime NOT NULL,
  `CreatedBy` varchar(45) NOT NULL,
  `LastUpdate` datetime NOT NULL,
  `UpdateBy` varchar(45) NOT NULL,
  `Deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `AddressInfoID_UNIQUE` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=32768 DEFAULT CHARSET=utf8mb3;

CREATE TABLE `category` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(45) NOT NULL,
  `Description` varchar(255) NOT NULL,
  `Active` tinyint NOT NULL,
  `CreatedOn` datetime NOT NULL,
  `CreatedBy` varchar(45) NOT NULL,
  `LastUpdate` datetime NOT NULL,
  `UpdateBy` varchar(45) NOT NULL,
  `Deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3;

CREATE TABLE `city` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(45) NOT NULL,
  `Municipality_ID` int NOT NULL,
  `CreatedOn` datetime NOT NULL,
  `CreatedBy` varchar(45) NOT NULL,
  `LastUpdate` datetime NOT NULL,
  `UpdateBy` varchar(45) NOT NULL,
  `Deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`,`Municipality_ID`),
  KEY `fk_City_Municipality1_idx` (`Municipality_ID`),
  KEY `index_CityName` (`Name`),
  CONSTRAINT `fk_City_Municipality1` FOREIGN KEY (`Municipality_ID`) REFERENCES `municipality` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=2451 DEFAULT CHARSET=utf8mb3;

CREATE TABLE `coupon` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Code` varchar(45) NOT NULL,
  `DiscountPercentage` decimal(7,3) DEFAULT NULL,
  `Discountprice` int DEFAULT NULL,
  `CouponFormula` varchar(500) DEFAULT NULL,
  `Description` varchar(255) NOT NULL,
  `Active` tinyint NOT NULL,
  `StartDate` datetime NOT NULL,
  `EndDate` datetime DEFAULT NULL,
  `CreatedOn` datetime NOT NULL,
  `CreatedBy` varchar(45) NOT NULL,
  `LastUpdate` datetime NOT NULL,
  `UpdateBy` varchar(45) NOT NULL,
  `Deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb3;

CREATE TABLE `customer` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(45) NOT NULL,
  `Birthdate` date DEFAULT NULL,
  `Email` varchar(255) NOT NULL,
  `Phone1` varchar(12) NOT NULL,
  `Phone2` varchar(12) DEFAULT NULL,
  `CreatedOn` datetime NOT NULL,
  `CreatedBy` varchar(45) NOT NULL,
  `LastUpdate` datetime NOT NULL,
  `UpdateBy` varchar(45) NOT NULL,
  `Deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `CustomerID_UNIQUE` (`ID`),
  UNIQUE KEY `Email_UNIQUE` (`Email`)
) ENGINE=InnoDB AUTO_INCREMENT=32768 DEFAULT CHARSET=utf8mb3;

CREATE TABLE `customer_addressinfo` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Customer_ID` int NOT NULL,
  `AddressInfo_ID` int NOT NULL,
  `CreatedOn` datetime NOT NULL,
  `CreatedBy` varchar(45) NOT NULL,
  `LastUpdate` datetime NOT NULL,
  `UpdateBy` varchar(45) NOT NULL,
  `Deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`,`Customer_ID`,`AddressInfo_ID`),
  KEY `fk_Customer_Addressinfo_Customer1_idx` (`Customer_ID`),
  KEY `fk_Customer_Addressinfo_AddressInfo1_idx` (`AddressInfo_ID`),
  CONSTRAINT `fk_Customer_Addressinfo_AddressInfo1` FOREIGN KEY (`AddressInfo_ID`) REFERENCES `addressinfo` (`ID`),
  CONSTRAINT `fk_Customer_Addressinfo_Customer1` FOREIGN KEY (`Customer_ID`) REFERENCES `customer` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=32768 DEFAULT CHARSET=utf8mb3;

CREATE TABLE `deliverytype` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Type` varchar(45) NOT NULL,
  `Active` tinyint NOT NULL DEFAULT '0',
  `CreatedOn` datetime NOT NULL,
  `CreatedBy` varchar(45) NOT NULL,
  `LastUpdate` datetime NOT NULL,
  `UpdateBy` varchar(45) NOT NULL,
  `Deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3;

CREATE TABLE `differentopeningtime` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Date` date NOT NULL,
  `Open` time NOT NULL,
  `Close` time NOT NULL,
  `Name` varchar(45) NOT NULL,
  `Description` varchar(255) DEFAULT NULL,
  `Shop_ID` int NOT NULL,
  `CreatedOn` datetime NOT NULL,
  `CreatedBy` varchar(45) NOT NULL,
  `LastUpdate` datetime NOT NULL,
  `UpdateBy` varchar(45) NOT NULL,
  `Deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`,`Shop_ID`),
  KEY `fk_DiffOpeningTime_Shop1_idx` (`Shop_ID`),
  CONSTRAINT `fk_DiffOpeningTime_Shop1` FOREIGN KEY (`Shop_ID`) REFERENCES `shop` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

CREATE TABLE `ingredient` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(45) NOT NULL,
  `Description` varchar(255) DEFAULT NULL,
  `Price` decimal(7,3) DEFAULT NULL,
  `Active` tinyint NOT NULL DEFAULT '0',
  `Tax_ID` int NOT NULL,
  `CreatedOn` datetime NOT NULL,
  `CreatedBy` varchar(45) NOT NULL,
  `LastUpdate` datetime NOT NULL,
  `UpdateBy` varchar(45) NOT NULL,
  `Deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`,`Tax_ID`),
  KEY `fk_Ingredients_Tax1_idx` (`Tax_ID`),
  CONSTRAINT `fk_Ingredients_Tax1` FOREIGN KEY (`Tax_ID`) REFERENCES `tax` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb3;

CREATE TABLE `item_property` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `PizzaBottom_ID` int DEFAULT NULL,
  `Sauce_ID` int DEFAULT NULL,
  `Ingredient_ID` int DEFAULT NULL,
  `NonPizza_ID` int DEFAULT NULL,
  `Property_ID` int NOT NULL,
  `CreatedOn` datetime NOT NULL,
  `CreatedBy` varchar(45) NOT NULL,
  `LastUpdate` datetime NOT NULL,
  `UpdateBy` varchar(45) NOT NULL,
  `Deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`,`Property_ID`),
  KEY `fk_Item_Property_PizzaBottom1_idx` (`PizzaBottom_ID`),
  KEY `fk_Item_Property_Sauce1_idx` (`Sauce_ID`),
  KEY `fk_Item_Property_Ingredient1_idx` (`Ingredient_ID`),
  KEY `fk_Item_Property_Property1_idx` (`Property_ID`),
  KEY `fk_Item_Property_NonPizza1_idx` (`NonPizza_ID`),
  CONSTRAINT `fk_Item_Property_Ingredient1` FOREIGN KEY (`Ingredient_ID`) REFERENCES `ingredient` (`ID`),
  CONSTRAINT `fk_Item_Property_NonPizza1` FOREIGN KEY (`NonPizza_ID`) REFERENCES `nonpizza` (`ID`),
  CONSTRAINT `fk_Item_Property_PizzaBottom1` FOREIGN KEY (`PizzaBottom_ID`) REFERENCES `pizzabottom` (`ID`),
  CONSTRAINT `fk_Item_Property_Property1` FOREIGN KEY (`Property_ID`) REFERENCES `property` (`ID`),
  CONSTRAINT `fk_Item_Property_Sauce1` FOREIGN KEY (`Sauce_ID`) REFERENCES `sauce` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

CREATE TABLE `marioorderdata01` (
  `MyUnknownColumn` int DEFAULT NULL,
  `WinkelID` int DEFAULT NULL,
  `Winkelnaam` text,
  `CustomerID` int DEFAULT NULL,
  `Klantnaam` text,
  `TelefoonNr` text,
  `Email` text,
  `AddressID` int DEFAULT NULL,
  `Adres` text,
  `Woonplaats` text,
  `OrderID` int DEFAULT NULL,
  `Besteldatum` text,
  `DeliveryTypeID` int DEFAULT NULL,
  `AfleverType` text,
  `AfleverDatum` text,
  `AfleverMoment` text,
  `ProductID` int DEFAULT NULL,
  `nonProductID` int DEFAULT NULL,
  `Product` text,
  `PizzaBodemID` int DEFAULT NULL,
  `PizzaBodem` text,
  `PizzaSausID` int DEFAULT NULL,
  `PizzaSaus` text,
  `Prijs` text,
  `Bezorgkosten` text,
  `BezorgkostenDecimal` decimal(7,3) DEFAULT NULL,
  `Aantal` int DEFAULT NULL,
  `Extra IngrediÃƒÂ«nten` text,
  `Prijs Extra IngrediÃƒÂ«nten` text,
  `Regelprijs` text,
  `RegelprijsDecimal` decimal(7,3) DEFAULT NULL,
  `Totaalprijs` text,
  `TotaalprijsDecimal` decimal(7,3) DEFAULT NULL,
  `CouponID` int DEFAULT NULL,
  `Gebruikte Coupon` text,
  `Coupon Korting` text,
  `Te Betalen` text,
  `TeBetalenDecimal` decimal(7,3) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

CREATE TABLE `mariooverigeproducten` (
  `ID` int DEFAULT NULL,
  `categorie` text,
  `categorieUnique` text,
  `categorieID` text,
  `subcategorie` text,
  `subcategorieUnique` text,
  `subcategorieID` text,
  `productnaam` text,
  `productnaamUnique` text,
  `productnaamID` text,
  `productomschrijving` text,
  `productomschrijvingFiltered` text,
  `prijs` double DEFAULT NULL,
  `prijsDecimal` double DEFAULT NULL,
  `spicy` text,
  `spicyTrueFalse` int DEFAULT NULL,
  `vegetarisch` text,
  `vegetarischTrueFalse` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

CREATE TABLE `mariopizza_ingredienten` (
  `categorie` int DEFAULT NULL,
  `subcategorie` int DEFAULT NULL,
  `productnaam` text,
  `productomschrijving` text,
  `prijs` double DEFAULT NULL,
  `bezorgtoeslag` double DEFAULT NULL,
  `spicy` int DEFAULT NULL,
  `vegetarisch` int DEFAULT NULL,
  `beschikbaar` int DEFAULT NULL,
  `aantalkeer_ingredient` int DEFAULT NULL,
  `ingredientnaam` text,
  `pizzasaus_standaard` text,
  `MyUnknownColumn` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

CREATE TABLE `municipality` (
  `ID` int NOT NULL,
  `Name` varchar(45) NOT NULL,
  `CreatedOn` datetime NOT NULL,
  `CreatedBy` varchar(45) NOT NULL,
  `LastUpdate` datetime NOT NULL,
  `UpdateBy` varchar(45) NOT NULL,
  `Deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  KEY `index_MunName` (`Name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

CREATE TABLE `nonpizza` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(45) NOT NULL,
  `Description` varchar(255) NOT NULL,
  `Active` tinyint NOT NULL,
  `Tax_ID` int NOT NULL,
  `SubCategory_ID` int NOT NULL,
  `CreatedOn` datetime NOT NULL,
  `CreatedBy` varchar(45) NOT NULL,
  `LastUpdate` datetime NOT NULL,
  `UpdateBy` varchar(45) NOT NULL,
  `Deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`,`SubCategory_ID`,`Tax_ID`),
  KEY `fk_NonPizza_Tax1_idx` (`Tax_ID`),
  KEY `fk_NonPizza_SubCategory1_idx` (`SubCategory_ID`),
  CONSTRAINT `fk_NonPizza_SubCategory1` FOREIGN KEY (`SubCategory_ID`) REFERENCES `subcategory` (`ID`),
  CONSTRAINT `fk_NonPizza_Tax1` FOREIGN KEY (`Tax_ID`) REFERENCES `tax` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8mb3;

CREATE TABLE `openingtime` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(45) NOT NULL,
  `Description` varchar(255) DEFAULT NULL,
  `MonOpen` time DEFAULT NULL,
  `MonClosed` time DEFAULT NULL,
  `TueOpen` time DEFAULT NULL,
  `TueClosed` time DEFAULT NULL,
  `WedOpen` time DEFAULT NULL,
  `WedClosed` time DEFAULT NULL,
  `ThuOpen` time DEFAULT NULL,
  `ThueClosed` time DEFAULT NULL,
  `FriOpen` time DEFAULT NULL,
  `FriClosed` time DEFAULT NULL,
  `SatOpen` time DEFAULT NULL,
  `SatClosed` time DEFAULT NULL,
  `SunOpen` time DEFAULT NULL,
  `SunClosed` time DEFAULT NULL,
  `CreatedOn` datetime NOT NULL,
  `CreatedBy` varchar(45) NOT NULL,
  `LastUpdate` datetime NOT NULL,
  `UpdateBy` varchar(45) NOT NULL,
  `Deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

CREATE TABLE `order` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `OrderStatus` tinyint NOT NULL,
  `DeliveryPlan` datetime NOT NULL,
  `DeliveryTime` datetime DEFAULT NULL,
  `DeliveryPrice` decimal(7,3) DEFAULT NULL,
  `Customer_Id` int NOT NULL,
  `DeliveryType_ID` int NOT NULL,
  `Shop_ID` int NOT NULL,
  `OrderDate` timestamp NOT NULL,
  `TotalOrderPrice` decimal(7,3) DEFAULT NULL,
  `CreatedOn` datetime NOT NULL,
  `CreatedBy` varchar(45) NOT NULL,
  `LastUpdate` datetime NOT NULL,
  `UpdateBy` varchar(45) NOT NULL,
  `Deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`,`Customer_Id`,`DeliveryType_ID`,`Shop_ID`),
  KEY `fk_Order_Customer_idx` (`Customer_Id`),
  KEY `fk_Order_DeliveryType1_idx` (`DeliveryType_ID`),
  KEY `fk_Order_Shop1_idx` (`Shop_ID`),
  CONSTRAINT `fk_Order_Customer` FOREIGN KEY (`Customer_Id`) REFERENCES `customer` (`ID`),
  CONSTRAINT `fk_Order_DeliveryType` FOREIGN KEY (`DeliveryType_ID`) REFERENCES `deliverytype` (`ID`),
  CONSTRAINT `fk_Order_Shop` FOREIGN KEY (`Shop_ID`) REFERENCES `shop` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=65536 DEFAULT CHARSET=utf8mb3;

CREATE TABLE `order_coupon` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Order_ID` int NOT NULL,
  `Coupon_ID` int NOT NULL,
  `CreatedOn` datetime NOT NULL,
  `CreatedBy` varchar(45) NOT NULL,
  `LastUpdate` datetime NOT NULL,
  `UpdateBy` varchar(45) NOT NULL,
  `Deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`,`Coupon_ID`),
  KEY `fk_Order_Coupon_Coupon1_idx` (`Coupon_ID`),
  KEY `fk_Order_Coupon_Order1_idx` (`Order_ID`),
  CONSTRAINT `fk_Order_Coupon_Coupon1` FOREIGN KEY (`Coupon_ID`) REFERENCES `coupon` (`ID`),
  CONSTRAINT `fk_Order_Coupon_Order1` FOREIGN KEY (`Order_ID`) REFERENCES `order` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

CREATE TABLE `orderitem` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `OrderID` int NOT NULL,
  `Pizza_ID` int DEFAULT NULL,
  `NonPizza_ID` int DEFAULT NULL,
  `OrderName` varchar(45) NOT NULL,
  `Amount` int NOT NULL,
  `TotalPrice` decimal(7,3) NOT NULL,
  `Tax` decimal(7,3) NOT NULL,
  `CreatedOn` datetime NOT NULL,
  `CreatedBy` varchar(45) NOT NULL,
  `LastUpdate` datetime NOT NULL,
  `UpdateBy` varchar(45) NOT NULL,
  `Deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`,`OrderID`),
  KEY `fk_Order_id` (`OrderID`) /*!80000 INVISIBLE */,
  KEY `fk_OrderItem_NonPizza1_idx` (`NonPizza_ID`),
  KEY `fk_OrderItem_Pizza1_idx` (`Pizza_ID`),
  CONSTRAINT `fk_OrderItem_NonPizza1` FOREIGN KEY (`NonPizza_ID`) REFERENCES `nonpizza` (`ID`),
  CONSTRAINT `fk_OrderItem_Order1` FOREIGN KEY (`OrderID`) REFERENCES `order` (`ID`),
  CONSTRAINT `fk_OrderItem_Pizza1` FOREIGN KEY (`Pizza_ID`) REFERENCES `pizza` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=163838 DEFAULT CHARSET=utf8mb3 KEY_BLOCK_SIZE=16;

CREATE TABLE `pizza` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(45) NOT NULL,
  `Sauce_ID` int NOT NULL,
  `PizzaBottom_ID` int NOT NULL,
  `IsCustom` tinyint NOT NULL DEFAULT '0' COMMENT 'Standaard GEEN custom pizza',
  `SubCategory_ID` int NOT NULL,
  `Active` tinyint NOT NULL DEFAULT '0',
  `Description` varchar(255) NOT NULL,
  `Price` decimal(7,3) NOT NULL,
  `CreatedOn` datetime NOT NULL,
  `CreatedBy` varchar(45) NOT NULL,
  `LastUpdate` datetime NOT NULL,
  `UpdateBy` varchar(45) NOT NULL,
  `Deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  KEY `fk_Pizza_Sauce1_idx` (`Sauce_ID`),
  KEY `fk_Pizza_PizzaBottom1_idx` (`PizzaBottom_ID`),
  KEY `fk_Pizza_SubCategory1_idx` (`SubCategory_ID`),
  CONSTRAINT `fk_Pizza_PizzaBottom1` FOREIGN KEY (`PizzaBottom_ID`) REFERENCES `pizzabottom` (`ID`),
  CONSTRAINT `fk_Pizza_Sauce1` FOREIGN KEY (`Sauce_ID`) REFERENCES `sauce` (`ID`),
  CONSTRAINT `fk_Pizza_SubCategory1` FOREIGN KEY (`SubCategory_ID`) REFERENCES `subcategory` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb3;

CREATE TABLE `pizza_ingredient` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Pizza_ID` int DEFAULT NULL,
  `Ingredient_ID` int DEFAULT NULL,
  `Price` decimal(7,3) DEFAULT NULL,
  `CreatedOn` datetime NOT NULL,
  `CreatedBy` varchar(45) NOT NULL,
  `LastUpdate` datetime NOT NULL,
  `UpdateBy` varchar(45) NOT NULL,
  `Deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  KEY `fk_Pizza_Ingredient_Ingredient1_idx` (`Ingredient_ID`),
  KEY `fk_Pizza_Ingredient_Pizza1_idx` (`Pizza_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=128 DEFAULT CHARSET=utf8mb3;

CREATE TABLE `pizzabottom` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(45) NOT NULL,
  `Size` varchar(45) NOT NULL,
  `Active` tinyint NOT NULL,
  `Price` decimal(4,3) DEFAULT NULL,
  `Tax_ID` int NOT NULL,
  `PizzaBottomType_ID` int NOT NULL,
  `CreatedOn` datetime NOT NULL,
  `CreatedBy` varchar(45) NOT NULL,
  `LastUpdate` datetime NOT NULL,
  `UpdateBy` varchar(45) NOT NULL,
  `Deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`,`Tax_ID`,`PizzaBottomType_ID`),
  KEY `fk_PizzaBottom_Tax1_idx` (`Tax_ID`),
  KEY `fk_PizzaBottom_PizzaBottomType1_idx` (`PizzaBottomType_ID`),
  CONSTRAINT `fk_PizzaBottom_PizzaBottomType1` FOREIGN KEY (`PizzaBottomType_ID`) REFERENCES `pizzabottomtype` (`ID`),
  CONSTRAINT `fk_PizzaBottom_Tax1` FOREIGN KEY (`Tax_ID`) REFERENCES `tax` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3;

CREATE TABLE `pizzabottomtype` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(45) DEFAULT NULL,
  `Description` varchar(255) DEFAULT NULL,
  `Active` tinyint DEFAULT NULL,
  `CreatedOn` datetime NOT NULL,
  `CreatedBy` varchar(45) NOT NULL,
  `LastUpdate` datetime NOT NULL,
  `UpdateBy` varchar(45) NOT NULL,
  `Deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `Name_UNIQUE` (`Name`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3;

CREATE TABLE `property` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(45) DEFAULT NULL,
  `Description` varchar(255) DEFAULT NULL,
  `CreatedOn` datetime NOT NULL,
  `CreatedBy` varchar(45) NOT NULL,
  `LastUpdate` datetime NOT NULL,
  `UpdateBy` varchar(45) NOT NULL,
  `Deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

CREATE TABLE `sauce` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(45) NOT NULL,
  `Description` varchar(255) NOT NULL,
  `Price` decimal(7,3) DEFAULT NULL,
  `Active` tinyint NOT NULL,
  `Tax_ID` int NOT NULL,
  `CreatedOn` datetime NOT NULL,
  `CreatedBy` varchar(45) NOT NULL,
  `LastUpdate` datetime NOT NULL,
  `UpdateBy` varchar(45) NOT NULL,
  `Deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`,`Tax_ID`),
  KEY `fk_Sauce_Tax1_idx` (`Tax_ID`),
  CONSTRAINT `fk_Sauce_Tax1` FOREIGN KEY (`Tax_ID`) REFERENCES `tax` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3;

CREATE TABLE `servicearea` (
  `ID` int NOT NULL,
  `Zipcode` varchar(6) NOT NULL,
  `BreakpointStart` varchar(6) NOT NULL,
  `BreakpointEnd` varchar(6) NOT NULL,
  `Street_ID` int NOT NULL,
  `Shop_ID` int DEFAULT NULL,
  `CreatedOn` datetime NOT NULL,
  `CreatedBy` varchar(45) NOT NULL,
  `LastUpdate` datetime NOT NULL,
  `UpdateBy` varchar(45) NOT NULL,
  `Deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`,`Street_ID`),
  KEY `fk_ZipCode_Shop1_idx` (`Shop_ID`),
  KEY `fk_ZipCode_StreetName1_idx` (`Street_ID`),
  KEY `index_Zipcode` (`Zipcode`),
  CONSTRAINT `fk_ZipCode_Shop1` FOREIGN KEY (`Shop_ID`) REFERENCES `shop` (`ID`),
  CONSTRAINT `fk_ZipCode_StreetName1` FOREIGN KEY (`Street_ID`) REFERENCES `street` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

CREATE TABLE `shop` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(75) NOT NULL,
  `Phone` varchar(12) NOT NULL,
  `Email` varchar(255) NOT NULL,
  `StreetName` varchar(75) NOT NULL,
  `HouseNumber` varchar(10) NOT NULL,
  `Zipcode` varchar(6) NOT NULL,
  `City` varchar(45) NOT NULL,
  `CreatedOn` datetime NOT NULL,
  `CreatedBy` varchar(45) NOT NULL,
  `LastUpdate` datetime NOT NULL,
  `UpdateBy` varchar(45) NOT NULL,
  `Deleted` tinyint NOT NULL DEFAULT '0',
  `OpeningTime_ID` int DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `fk_Shop_OpeningTime1_idx` (`OpeningTime_ID`),
  CONSTRAINT `fk_Shop_OpeningTime1` FOREIGN KEY (`OpeningTime_ID`) REFERENCES `openingtime` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=145 DEFAULT CHARSET=utf8mb3;

CREATE TABLE `street` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(75) NOT NULL,
  `City_ID` int NOT NULL,
  `CreatedOn` datetime NOT NULL,
  `CreatedBy` varchar(45) NOT NULL,
  `LastUpdate` datetime NOT NULL,
  `UpdateBy` varchar(45) NOT NULL,
  `Deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`,`City_ID`),
  KEY `fk_StreetName_City1_idx` (`City_ID`),
  KEY `index_StreetName` (`Name`),
  CONSTRAINT `fk_StreetName_City1` FOREIGN KEY (`City_ID`) REFERENCES `city` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=117721 DEFAULT CHARSET=utf8mb3;

CREATE TABLE `subcategory` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(45) NOT NULL,
  `Description` varchar(255) NOT NULL,
  `Active` tinyint NOT NULL DEFAULT '0',
  `Categorie_ID` int NOT NULL,
  `CreatedOn` datetime NOT NULL,
  `CreatedBy` varchar(45) NOT NULL,
  `LastUpdate` datetime NOT NULL,
  `UpdateBy` varchar(45) NOT NULL,
  `Deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`,`Categorie_ID`),
  KEY `fk_SubCategory_Category1_idx` (`Categorie_ID`),
  CONSTRAINT `fk_SubCategory_Category1` FOREIGN KEY (`Categorie_ID`) REFERENCES `category` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb3;

CREATE TABLE `tax` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Tax` decimal(7,3) NOT NULL,
  `Description` varchar(255) NOT NULL,
  `CreatedOn` datetime NOT NULL,
  `CreatedBy` varchar(45) NOT NULL,
  `LastUpdate` datetime NOT NULL,
  `UpdateBy` varchar(45) NOT NULL,
  `Deleted` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
