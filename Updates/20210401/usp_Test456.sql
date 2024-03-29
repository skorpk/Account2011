USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test456]    Script Date: 01.04.2021 17:52:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test456]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
/*
Значение должно соответствовать классификатору V024 (для действующих на DATE_Z_2 записей) 
и должно удовлетворять условию CODE_SH like 'sh%' or like ‘mt%’. 
Кроме того, значение CODE_SH должно быть равно значению в одном из тегов CRIT. 
Кроме того, если коду лексредства, указанному в REGNUM, задано соответствие в справочнике N021 (в N021 установлено соответствие кодов препаратов кодам схем), 
то в CODE_SH должна быть указана одна из соответствующих схем.
*/
--SELECT DiagnosisCode INTO #t FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'C81' AND 'C96'

SELECT DiagnosisCode INTO #tE FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'C81' AND 'C96'
UNION all
SELECT DiagnosisCode  FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'D45' AND 'D47'


INSERT #tError
SELECT DISTINCT c.id,456
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
			  INNER JOIN dbo.t_DrugTherapy d on
		c.id=d.rf_idCase
				INNER JOIN dbo.vw_Diagnosis dd ON
		c.id=dd.rf_idCase              
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND NOT EXISTS(SELECT * FROM sprv024 WHERE IDDKK=d.rf_idV024 AND DATEBEG<=cc.DateEnd AND DATEEND>=cc.DateEnd AND IDDKK LIKE '[sh,mt]%')
	AND Age>17 AND NOT EXISTS(SELECT 1 FROM #tE WHERE DiagnosisCode=dd.ds1)

INSERT #tError
SELECT DISTINCT c.id,456
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
			  INNER JOIN dbo.t_DrugTherapy d on
		c.id=d.rf_idCase
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND NOT EXISTS(SELECT 1 FROM dbo.t_AdditionalCriterion WHERE rf_idCase=c.id AND rf_idAddCretiria=d.rf_idV024)
		AND Age>17 AND c.rf_idV008<>32

INSERT #tError
SELECT DISTINCT c.id,456
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
			  INNER JOIN dbo.t_DrugTherapy d on
		c.id=d.rf_idCase		
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND d.rf_idV024 NOT IN('sh903','sh904','sh9001','sh9002','gem') 
	AND NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.sprN021 WHERE CODE_SH=d.rf_idV024 AND ID_LEKP=d.rf_idV020)
	AND Age>17 

----------------------------Children--------------
--INSERT #tError
--SELECT DISTINCT c.id,456
--from t_File f INNER JOIN t_RegistersCase a ON
--		f.id=a.rf_idFiles
--		AND a.ReportMonth=@month
--		AND a.ReportYear=@year
--			  inner join t_RecordCase r on
--		a.id=r.rf_idRegistersCase
--			  inner join t_Case c on
--		r.id=c.rf_idRecordCase						
--		AND c.DateEnd>='20190101'				
--			  INNER JOIN dbo.t_CompletedCase cc ON
--		r.id=cc.rf_idRecordCase 			  
--			  INNER JOIN dbo.t_DrugTherapy d on
--		c.id=d.rf_idCase
--where a.rf_idFiles=@idFile AND f.TypeFile='H' AND Age<18 AND d.rf_idV024<>'нет'

INSERT #tError
SELECT DISTINCT c.id,456
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
			  INNER JOIN dbo.t_DrugTherapy d on
		c.id=d.rf_idCase
	INNER JOIN dbo.vw_Diagnosis dd ON
		c.id=dd.rf_idCase 
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND LOWER(d.rf_idV024)='нет'
AND (C.age>17 AND (d.rf_idN013<>4 or NOT EXISTS(SELECT 1 FROM #tE WHERE DiagnosisCode=dd.ds1)))
go
		


