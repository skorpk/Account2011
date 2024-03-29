USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test458]    Script Date: 11.04.2019 11:04:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test458]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

CREATE TABLE #tNomencl(code VARCHAR(20), typeSPR tinyint)
--typeSPR=1 то стоматологическая
--typeSPR=1 то из справочника номенклатур
INSERT #tNomencl( code,typeSPR ) SELECT code,1 FROM oms_nsi.dbo.sprDentalMU WHERE isFormula=1

INSERT #tNomencl( code,typeSPR ) SELECT codeNomenclMU,2 FROM oms_nsi.dbo.sprNomenclMUBodyParts

INSERT #tError
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

INSERT #tError
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
				INNER JOIN #tUsl u ON
		c.rf_idV006=u.rf_idV006
		AND c.rf_idV008=ISNULL(u.rf_idV008,c.rf_idV008) 
			  INNER JOIN dbo.t_Meduslugi m ON			  
		c.id=m.rf_idCase			  
			  INNER JOIN #tNomencl n ON
		m.MUSurgery=n.code            
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND typeSPR=2  AND  len(ISNULL(m.Comments,''))=0


------------Распарсиваем парные органы----------------------

SELECT c.id,m.MUSurgery,CAST(replace( ('<Root><Num num="'+m.Comments)+'" /></Root>', ',' ,'" /><Num num="') AS XML) AS XMLNum
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
		  	  INNER JOIN #tUsl u ON
		c.rf_idV006=u.rf_idV006
		AND c.rf_idV008=ISNULL(u.rf_idV008,c.rf_idV008) 				
			  INNER JOIN dbo.t_Meduslugi m ON			  
		c.id=m.rf_idCase			  
			  INNER JOIN #tNomencl n ON
		m.MUSurgery=n.code            
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND n.typeSPR=2 AND len(ISNULL(m.Comments,''))>0 AND c.rf_idV006<3

;WITH cte
AS(
SELECT s.id,s.MUSurgery,m.c.value('@num[1]','int') AS CodeParts
FROM #t s CROSS APPLY s.XMLNum.nodes('/Root/Num') as m(c)
)
INSERT #tError SELECT DISTINCT id,458 FROM cte c WHERE NOT EXISTS(SELECT 1 FROM vw_sprNomenclBodyParts WHERE codeNomenclMU=c.MUSurgery AND code=CodeParts)

------------Распарсиваем зубки----------------------

INSERT #tError SELECT DISTINCT c.id,458
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

INSERT #tError SELECT id, 458 from #toothId

;WITH cte
AS(
SELECT s.id,m.c.value('@num[1]','tinyint') AS ToothId2
FROM #t2 s CROSS APPLY s.XMLNum.nodes('/Root/Num') as m(c)
WHERE NOT EXISTS(SELECT 1 FROM #toothId WHERE id=s.id)
)
INSERT #tError SELECT DISTINCT id,458 FROM cte c WHERE NOT EXISTS(SELECT 1 FROM #tDentalPosition WHERE toothID=c.ToothId2)

DROP TABLE #t
DROP TABLE #t2
DROP TABLE #toothId
DROP TABLE #tDentalPosition
DROP TABLE #tNomencl
DROP TABLE #tUsl

