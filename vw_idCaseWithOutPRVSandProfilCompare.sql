USE RegisterCases
go
IF OBJECT_ID('vw_idCaseWithOutPRVSandProfilCompare',N'V') IS NOT NULL
DROP VIEW vw_idCaseWithOutPRVSandProfilCompare
GO
CREATE VIEW vw_idCaseWithOutPRVSandProfilCompare
AS
SELECT c.id,a.rf_idFiles,c.DateEnd
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase			
						inner join t_Case c on
			r.id=c.rf_idRecordCase
						INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase
						INNER JOIN (SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=72 and MUUnGroupCode=1
									UNION ALL
									SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=72 and MUUnGroupCode=4
									UNION ALL 
									SELECT code FROM dbo.vw_sprCSG
									) mu ON
			m.MES=mu.MU
UNION ALL 
SELECT DISTINCT c.id,a.rf_idFiles,c.DateEnd
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase			
						inner join t_Case c on
			r.id=c.rf_idRecordCase
						INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
WHERE c.DateEnd>'20140801' AND m.MUCode='2.79.51'
go