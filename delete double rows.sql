USE AccountOMSReports
GO
SELECT rf_idCase,GUID_MU,id,COUNT(*) AS CountRecords
INTO #tmpMU
FROM dbo.t_Meduslugi
GROUP BY rf_idCase,GUID_MU,id
HAVING COUNT(*)>1

SELECT DISTINCT m.* 
INTO #tmpMeduslugi
FROM #tmpMU m1 INNER JOIN dbo.t_Meduslugi m ON
		m1.rf_idCase=m.rf_idCase
		AND m1.GUID_MU=m.GUID_MU
		AND m1.id=m.id
SELECT @@rowcount

-----------------------------------------------------------------------		
BEGIN TRANSACTION
---Удаляем двойные записи
DELETE FROM dbo.t_Meduslugi
FROM dbo.t_Meduslugi m INNER JOIN #tmpMU m1 ON
		m1.rf_idCase=m.rf_idCase
		AND m1.GUID_MU=m.GUID_MU
		AND m1.id=m.id

SELECT @@rowcount
--вставляем записи
INSERT dbo.t_Meduslugi( rf_idCase ,id ,GUID_MU ,rf_idMO ,rf_idSubMO ,rf_idDepartmentMO ,rf_idV002 ,IsChildTariff ,DateHelpBegin ,DateHelpEnd ,
						DiagnosisCode ,MUGroupCode ,MUUnGroupCode ,MUCode ,Quantity ,Price ,TotalPrice ,rf_idV004 ,rf_idDoctor ,Comments ,MUSurgery)
SELECT m.rf_idCase ,m.id ,m.GUID_MU ,m.rf_idMO ,m.rf_idSubMO ,m.rf_idDepartmentMO ,m.rf_idV002 ,m.IsChildTariff ,m.DateHelpBegin ,m.DateHelpEnd ,
	   m.DiagnosisCode ,m.MUGroupCode ,m.MUUnGroupCode ,m.MUCode ,m.Quantity ,m.Price ,m.TotalPrice ,m.rf_idV004 ,m.rf_idDoctor ,m.Comments ,m.MUSurgery
FROM #tmpMeduslugi m INNER JOIN dbo.t_Case c ON
			m.rf_idCase=c.id

SELECT @@rowcount
--проверяем что бы не было дубликатов
SELECT TOP 10 rf_idCase,GUID_MU,id,COUNT(*) AS CountRecords
FROM dbo.t_Meduslugi
GROUP BY rf_idCase,GUID_MU,id
HAVING COUNT(*)>1

COMMIT


	
go

DROP TABLE #tmpMU
DROP TABLE #tmpMeduslugi