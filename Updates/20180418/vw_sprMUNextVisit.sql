USE RegisterCases
go
CREATE VIEW vw_sprMUNextVisit
as
WITH cteMU
AS(
select m3.MUId,m1.MUGroupCode,m2.MUUnGroupCode,m3.MUCode,m3.MUName, m3.rf_sprV025Id, v25.IDPC AS IsNextVisit
from oms_nsi.dbo.sprMUGroup m1 inner join oms_nsi.dbo.sprMUUnGroup m2 on
			m1.MUGroupId=m2.rf_MUGroupId 
						inner join oms_nsi.dbo.sprMU m3 on
			m2.MUUnGroupId=m3.rf_MUUnGroupId
						INNER JOIN oms_nsi.dbo.sprV025 v25 ON
			m3.rf_sprV025Id = v25.SprV025Id                        
)
SELECT CAST(MUGroupCode AS varchar(2)) + '.' + CAST(MUUnGroupCode AS varchar(2)) + '.' + CAST(MUCode AS varchar(3)) AS MU,MUName, IsNextVisit
FROM cteMU
GO
GRANT SELECT ON vw_sprMUNextVisit TO db_RegisterCase