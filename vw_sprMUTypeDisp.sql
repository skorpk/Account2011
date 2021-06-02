USE OMS_NSI
GO
CREATE VIEW vw_sprMUTypeDisp
as
select CAST(m1.MUGroupCode as varchar(2))+'.'+cast(m2.MUUnGroupCode as varchar(2))+'.'+CAST(m3.MUCode as varchar(3)) AS MU
	   ,m3.MUName		
	   ,v16.Code AS TypeDisp ,v16.Name
from OMS_NSI.dbo.sprMUGroup m1 inner join OMS_NSI.dbo.sprMUUnGroup m2 on
			m1.MUGroupId=m2.rf_MUGroupId 
						inner join OMS_NSI.dbo.sprMU m3 on
			m2.MUUnGroupId=m3.rf_MUUnGroupId
						INNER JOIN oms_nsi.dbo.sprMUV016TFOMS ma ON
			m3.MUId=ma.rf_MUId                      
						INNER JOIN  oms_nsi.dbo.sprV016TFOMS v16 ON
			ma.rf_sprV016TFOMSId=v16.sprV016TFOMSId
WHERE m3.ST =1		