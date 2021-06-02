USE RegisterCases
GO

DECLARE @idFile INT=201280,
		@month TINYINT,
		@year SMALLINT,
		@codeLPU char(6)	
--------------------------------------------------------------
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles					
where f.id=@idFile

DECLARE @dtStart DATE=CAST(@year AS CHAR(4))+RIGHT('0'+CAST(@month AS VARCHAR(2)),2)+'01'

------------------------------------------------------------------------------------------

CREATE TABLE #tAspect(CSG VARCHAR(10),typeQ tinyint)

INSERT #tAspect(CSG,typeQ)
SELECT DISTINCT Code,Age FROM vw_sprCSGRules WHERE age <5 AND @dtStart BETWEEN dateBeg AND dateEnd

-------------------------Дети-----------------------
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
WHERE f.id=@idFile AND a.ReportYear=@year AND a.ReportMonth=@month AND f.CodeM=@codeLPU AND c.age<3
)
SELECT DISTINCT  b.id AS rf_idCase, CASE WHEN b.DateBirth<29 AND b.typeQ<4 THEN 1 
							   WHEN b.DateBirth>28 AND b.DateBirth<91 AND b.typeQ<4 THEN 2 
							   WHEN b.DateBirth>91 AND b.typeQ<4 THEN 3 
							   WHEN b.typeQ=4 THEN 4 END AS CodAge
INTO #tChildAge							   
FROM cteB b 
---------------------------

SELECT DISTINCT f.id AS rf_idFile,f.codeM,a.NumberRegister,c.idRecordCase, c.id AS rf_idCase,m.MES,RTRIM(d.DiagnosisCode) AS DS1,c.rf_idV006 AS USL_OK,mm.MUSurgery
	,RTRIM(dd.DiagnosisCode) AS DS2,ad.rf_idAddCretiria
	--,CASE WHEN age>17 THEN 6 ELSE NULL END AS Age
	,CASE WHEN age>17 THEN 6
		  WHEN tt.CodAge IS NOT NULL then tt.CodAge 
		  ELSE 5 END AS Age
	,CASE WHEN c.KD<4 THEN 1 WHEN c.KD BETWEEN 4 and 10 THEN 11
			WHEN c.KD BETWEEN 11 AND 20 THEN 12 WHEN c.KD BETWEEN 21 AND 30 THEN 13 ELSE NULL END AS Los            
INTO #t
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase
			  INNER JOIN dbo.t_Diagnosis d ON
		c.id=d.rf_idCase
		AND d.TypeDiagnosis=1
			  INNER JOIN dbo.t_MES m ON
		c.id=m.rf_idCase				  
			  INNER JOIN dbo.t_Meduslugi mm ON
        c.id=mm.rf_idCase
				LEFT JOIN #tChildAge tt ON
		c.id=tt.rf_idCase	
			left JOIN dbo.t_Diagnosis dd ON
		c.id=dd.rf_idCase
		AND dd.TypeDiagnosis=3
			LEFT JOIN dbo.t_AdditionalCriterion ad ON
        c.id=ad.rf_idCase
WHERE f.id=@idFile AND a.ReportYear=@year AND a.ReportMonth=@month AND f.CodeM=@codeLPU AND m.TypeMES=2 --AND Age>17

;WITH cteCSG
AS
(
SELECT DISTINCT t.rf_idCase
FROM #t t JOIN dbo.sprBitCSGRules gr ON
		t.MES=gr.CodeCSG
		AND t.USL_OK=gr.USL_OK
		  JOIN dbo.vw_sprCSGRules v on
		v.MSCondition=t.USL_OK
		AND gr.CodeCSG=v.code
		AND gr.USL_OK=v.MSCondition
		AND (gr.DS1=0 OR(gr.DS1=1 AND t.DS1=v.DS1)) 
        AND (gr.DS2=0 OR(gr.DS2=1 AND t.DS2=v.DS2)) 
		AND (gr.MUSurgery=0 OR( gr.MUSurgery=1 AND t.MUSurgery=v.MuSurgery)) 
		AND (gr.rf_idAddCretiria=0 OR( gr.rf_idAddCretiria=1 AND t.rf_idAddCretiria=v.rf_idAddCretiria)) 
		AND (gr.Los=0 OR( gr.Los=1 AND t.Los=v.Los)) 
		AND (gr.Age=0 OR( gr.Age=1 AND t.Age=v.Age)) 
		)
SELECT DISTINCT t.rf_idCase
FROM #t t 
WHERE NOT EXISTS(SELECT 1 FROM cteCSG c WHERE c.rf_idCase= t.rf_idCase)

go
DROP TABLE #t
GO
DROP TABLE #tAspect
GO
DROP TABLE #tChildAge