 SELECT * FROM new_schema.marioorderdata01;

# Source:
# ID, Winkelnaam, Klantnaam, TelefoonNr, Email, Adres, Woonplaats, Besteldatum, AfleverType, AfleverDatum, AfleverMoment, Product, PizzaBodem, PizzaSaus, Prijs, Bezorgkosten, Aantal, Extra IngrediÃ«nten, Prijs Extra IngrediÃ«nten, Regelprijs, Totaalprijs, Gebruikte Coupon, Coupon Korting, Te Betalen
# '0', 'Middelburg', 'Johny ten Brinke', '06-25480284', 'JohnytenBrinke@armyspy.com', 'Hooge Meestraat 88', 'Middelburg', 'woensdag 5 juni 2019', 'Bezorgen', 'woensdag 5 juni 2019', '20:05', 'Creamy Bacon', 'Family XXL Pizza', 'Creme Fraiche', '€ 7,95', '€ 2,00', '2', '', '€ 0,00', '€ 29,90', '€ 73,70', '', '€ 0,00', '€ 73,70\r'
 
# Order table 
# ID, OrderStatus, DeliveryPlan, DeliveryTime, DeliveryPrice, Customer_Id, DeliveryType_ID, Shop_ID, OrderDate, TotalOrderPrice, CreatedOn, CreatedBy, LastUpdate, UpdateBy, Deleted

# Order item table
# ID, OrderID, Pizza_ID, NonPizza_ID, OrderName, Amount, TotalPrice, Tax, CreatedOn, CreatedBy, LastUpdate, UpdateBy, Deleted


# 1) Get source row
# 2) Create order
# 3) Create order items

DROP PROCEDURE IF EXISTS proc_cursor_to_loopAndInsert;
DELIMITER ;;
CREATE PROCEDURE proc_cursor_to_loopAndInsert()
BEGIN
  DECLARE CURSOR_STUDENT_ID INT;
  DECLARE CURSOR_ENROLL_DATE DATE;
  DECLARE done INT DEFAULT FALSE;
  DECLARE cursor_studentEnrollDate CURSOR FOR SELECT student_id, enroll_date FROM student_enroll_date;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
  OPEN cursor_studentEnrollDate;
  loop_through_rows: LOOP
    FETCH cursor_studentEnrollDate INTO CURSOR_STUDENT_ID,CURSOR_ENROLL_DATE;
    IF done THEN
      LEAVE loop_through_rows;
    END IF;
    INSERT INTO student_enroll_date_duplicate(student_id,enroll_date,duplicate_flag) VALUES(CURSOR_STUDENT_ID,CURSOR_ENROLL_DATE,TRUE);
  END LOOP;
  CLOSE cursor_studentEnrollDate;
END;
;;
 
 INSERT INTO marios_pizza.order(ID, OrderStatus, DeliveryPlan, DeliveryTime, DeliveryPrice, Customer_Id, DeliveryType_ID, Shop_ID, OrderDate, TotalOrderPrice, CreatedOn, CreatedBy, LastUpdate, UpdateBy, Deleted)
 VALUES(
		 (SELECT),
         (),
         (),
         () 
 );