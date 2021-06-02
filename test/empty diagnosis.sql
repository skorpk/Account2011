select m.*
from t_Case c inner join t_Diagnosis d on
		c.id=d.rf_idCase
			  inner join t_Meduslugi m on
		c.id=m.rf_idCase
				left join t_MES mes on
		c.id=mes.rf_idCase
where GUID_Case='289bba0a-f7c9-4f3c-9e7f-9045c7cd862a'--'1a469569-60e1-42ba-8fe4-d8017dfdba06'

select * 
from t_Meduslugi where GUID_MU='C2C554C8-94B0-4C8F-86B4-BA7B6D73C547'--Price=0 or Price is null

