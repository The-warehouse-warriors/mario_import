	SELECT  uuid_v4() as Code
			, null as DiscountPercentage
            , null as DiscountPrice
            , null as CouponFormula
            , srcTable.* 
				FROM (SELECT DISTINCT `Gebruikte Coupon` AS Description 
					, 1 as Active
					, '2021-10-01 00:00:01' as StartDate
                    , null as EndDate
					, '2021-10-10 18:29:54' as CreatedOn
					, 'System - import' as CreatedBy
					, '2021-10-10 18:29:54' as LastUpdate
					, 'System - import' as UpdateBy
					, 0 as Deleted
                       FROM marios_pizza.marioorderdata01	WHERE `Gebruikte Coupon` > ''  ) as srcTable
	;
    
	SELECT  uuid_v4() AS Code
			, null AS DiscountPercentage
            , null AS DiscountPrice
            , null AS CouponFormula
            , srcTable.* 
				FROM (SELECT `Gebruikte Coupon` AS Description 
					, 1 AS Active
					, '2021-10-01 00:00:01' as StartDate
                    , null as EndDate
					, CURRENT_TIMESTAMP as CreatedOn
					, 'System - import' as CreatedBy
					, CURRENT_TIMESTAMP as LastUpdate
					, 'System - import' as UpdateBy
					, 0 as Deleted
                       FROM marios_pizza.marioorderdata01	WHERE `Gebruikte Coupon` > '' 
                       GROUP BY `Gebruikte Coupon`) as srcTable
	;