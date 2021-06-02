USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT,
	@month TINYINT=1,
	@year SMALLINT=2019

select @idFile=id, @month=ReportMonth, @year=ReportYear from vw_getIdFileNumber where CodeM='101001' and NumberRegister=526 and ReportYear=2019

SELECT ErrorNumber,COUNT(*) FROM dbo.t_ErrorProcessControl WHERE rf_idFile=@idFile GROUP BY ErrorNumber

select * from vw_getIdFileNumber where id=@idFile

CREATE TABLE #tNomencl(code VARCHAR(20), typeSPR TINYINT, dateBeg DATE, dateEnd date)
--typeSPR=1 то стоматологическая
--typeSPR=1 то из справочника номенклатур
INSERT #tNomencl( code,typeSPR ) SELECT code,1 FROM oms_nsi.dbo.sprDentalMU WHERE isFormula=1

INSERT #tNomencl( code,typeSPR,dateBeg,dateEnd ) SELECT codeNomenclMU,2,dateBeg,dateEnd FROM oms_nsi.dbo.sprNomenclMUBodyParts

SELECT DISTINCT c.id,458
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'												
			  INNER JOIN dbo.t_Meduslugi m ON			  
		c.id=m.rf_idCase			  
			  INNER JOIN #tNomencl n ON
		m.MUSurgery=n.code            
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND typeSPR=1  AND  len(ISNULL(m.Comments,''))=0 AND c.rf_idV006=3 AND c.rf_idV002 IN(85,86,87,88,89,90,140,171)

CREATE TABLE #tUsl (rf_idV006 TINYINT, rf_idV008 SMALLINT)
INSERT #tUsl( rf_idV006, rf_idV008 ) VALUES  ( 1,31),(2,null)

SELECT DISTINCT c.id,458,'errror',m.MUSurgery
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase								             
		AND c.DateEnd>='20190101'
				INNER JOIN dbo.t_CompletedCase cc ON
		r.id=cc.rf_idRecordCase				
				INNER JOIN #tUsl u ON
		c.rf_idV006=u.rf_idV006
		AND c.rf_idV008=ISNULL(u.rf_idV008,c.rf_idV008) 
			  INNER JOIN dbo.t_Meduslugi m ON			  
		c.id=m.rf_idCase			  
			  INNER JOIN #tNomencl n ON
		m.MUSurgery=n.code            
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND typeSPR=2  AND  len(ISNULL(m.Comments,''))=0 AND cc.DateEnd BETWEEN n.dateBeg AND n.dateEnd


------------Распарсиваем парные органы----------------------

SELECT c.id,m.MUSurgery,cc.DateEnd,CAST(replace( ('<Root><Num num="'+m.Comments)+'" /></Root>', ',' ,'" /><Num num="') AS XML) AS XMLNum
INTO #t
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'
			INNER JOIN dbo.t_CompletedCase cc ON
		r.id=cc.rf_idRecordCase
		  	  INNER JOIN #tUsl u ON
		c.rf_idV006=u.rf_idV006
		AND c.rf_idV008=ISNULL(u.rf_idV008,c.rf_idV008) 				
			  INNER JOIN dbo.t_Meduslugi m ON			  
		c.id=m.rf_idCase			  
			  INNER JOIN #tNomencl n ON
		m.MUSurgery=n.code            
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND n.typeSPR=2 AND len(ISNULL(m.Comments,''))>0 AND c.rf_idV006<3 AND cc.DateEnd BETWEEN n.dateBeg AND n.dateEnd


;WITH cte
AS(
SELECT s.id,s.MUSurgery,s.DateEnd,m.c.value('@num[1]','int') AS CodeParts
FROM #t s CROSS APPLY s.XMLNum.nodes('/Root/Num') as m(c)
)
SELECT DISTINCT id,458 FROM cte c WHERE NOT EXISTS(SELECT 1 FROM vw_sprNomenclBodyParts 
																  WHERE codeNomenclMU=c.MUSurgery AND code=CodeParts AND c.DateEnd BETWEEN dateBeg AND dateEnd)

------------Распарсиваем зубки----------------------

SELECT DISTINCT c.id,458
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'				
			  INNER JOIN dbo.t_Meduslugi m ON			  
		c.id=m.rf_idCase			  
			  INNER JOIN #tNomencl n ON
		m.MUSurgery=n.code            
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND n.typeSPR=1 AND len(ISNULL(m.Comments,''))>0 AND c.rf_idV006=3 AND c.rf_idV002 IN(85,86,87,88,89,90,140,171)
		AND m.Comments LIKE '%[a-zA-Zа-яА-Я!|\/.:; *]%'

CREATE TABLE #tDentalPosition(toothID tinyint)
INSERT #tDentalPosition( toothID )
VALUES (11),(12),(13),(14),(15),(16),(17),(18),(21),(22),(23),(24),(25),(26),(27),(28),(31),(32),(33),(34),(35),(36),(37),(38),(41),(42),(43),(44),(45),(46),(47),(48),(51),(52),(53),(54),(55),(61),(62),(63),(64),(65),(71),(72),(73),(74),(75),(81),(82),(83),(84),(85)

SELECT c.id,m.MUSurgery,CAST(replace( ('<Root><Num num="'+m.Comments)+'" /></Root>', ',' ,'" /><Num num="') AS XML) AS XMLNum
INTO #t2
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'				
			  INNER JOIN dbo.t_Meduslugi m ON			  
		c.id=m.rf_idCase			  
			  INNER JOIN #tNomencl n ON
		m.MUSurgery=n.code            
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND n.typeSPR=1 AND len(ISNULL(m.Comments,''))>0 AND c.rf_idV006=3 AND c.rf_idV002 IN(85,86,87,88,89,90,140,171)
	AND m.Comments NOT LIKE '%[a-zA-Zа-яА-Я!|\/.:; *]%'

;WITH cte
AS(
SELECT s.id,m.c.value('@num[1]','varchar(20)') AS ToothId2
FROM #t2 s CROSS APPLY s.XMLNum.nodes('/Root/Num') as m(c)
)
SELECT id INTO #toothId FROM cte WHERE LEN(ToothID2)>2

SELECT id, 458 from #toothId

;WITH cte
AS(
SELECT s.id,m.c.value('@num[1]','tinyint') AS ToothId2
FROM #t2 s CROSS APPLY s.XMLNum.nodes('/Root/Num') as m(c)
WHERE NOT EXISTS(SELECT 1 FROM #toothId WHERE id=s.id)
)
SELECT DISTINCT id,458 FROM cte c WHERE NOT EXISTS(SELECT 1 FROM #tDentalPosition WHERE toothID=c.ToothId2)
go
DROP TABLE #t
go
DROP TABLE #toothId
go
DROP TABLE #t2
go
DROP TABLE #tDentalPosition
go
DROP TABLE #tNomencl
go
DROP TABLE #tUsl

