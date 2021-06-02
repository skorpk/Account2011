USE RegisterCases
GO
CREATE VIEW vw_sprMUAndN0013
as
select convert(varchar, C.MUGroupCode) + '.' + convert(varchar, B.MUUnGroupCode) + '.' + CONVERT(varchar, A.MUCode) AS CodeMU,
       A.typeHealing,
       E.ID_TLech
from oms_nsi.dbo.sprMU A
     INNER JOIN oms_nsi.dbo.sprMUUnGroup B on B.MUUnGroupId = A.rf_MUUnGroupId
     INNER JOIN oms_nsi.dbo.sprMUGroup C on C.MUGroupId = B.rf_MUGroupId
     INNER JOIN oms_nsi.dbo.sprMUN013 D on D.rf_MUId = A.MUId
     INNER JOIN oms_nsi.dbo.sprN013 E on D.rf_sprN013Id = E.sprN013Id
GO
GRANT SELECT ON vw_sprMUAndN0013 TO db_RegisterCase