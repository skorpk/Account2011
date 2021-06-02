USE RegisterCases
GO
DECLARE @dtStar DATETIME='20210101',
		@dtEnd DATETIME=GETDATE(),
		@year SMALLINT=2021

CREATE TABLE #tAspect(CSG VARCHAR(10),typeQ tinyint)

INSERT #tAspect(CSG,typeQ)
SELECT DISTINCT Code,Age FROM vw_sprCSGRules WHERE age <5

;WITH cteB
AS(
SELECT DISTINCT c .id, DATEDIFF(DAY,rp.BirthDay,cc.DateEnd) AS DateBirth,ap.typeQ
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase								
				JOIN dbo.t_Case c ON
		r.id=c.rf_idRecordCase
				JOIN dbo.t_CompletedCase cc ON
        r.id=cc.rf_idRecordCase
				JOIN dbo.t_MES m ON
        c.id=m.rf_idCase			
				JOIN #tAspect ap ON
        m.MES=ap.CSG
				JOIN dbo.t_RefRegisterPatientRecordCase rf ON
		r.id=rf.rf_idRecordCase
				JOIN dbo.t_RegisterPatient rp ON
		rf.rf_idRegisterPatient=rp.id	
WHERE f.DateRegistration>@dtStar AND f.DateRegistration<@dtEnd AND a.ReportYear>=@year  AND c.age<2
)
SELECT DISTINCT  b.id AS rf_idCase, CASE WHEN b.DateBirth<29 AND b.typeQ<4 THEN 1 
							   WHEN b.DateBirth>28 AND b.DateBirth<91 AND b.typeQ<4 THEN 2 
							   WHEN b.DateBirth>91 AND b.typeQ<4 THEN 3 
							   WHEN b.typeQ=4 THEN 4 END AS CodAge
							   
FROM cteB b --WHERE id=136789767
GO
DROP TABLE #tAspect