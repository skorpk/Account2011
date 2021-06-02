USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

SELECT @idFile=f.id 
from vw_getIdFileNumber f WHERE CodeM='103001' AND ReportYear=2021 AND NumberRegister=112


SELECT ErrorNumber,COUNT(rf_idCase) AS CountCase FROM dbo.t_ErrorProcessControl WHERE rf_idFile=@idFile GROUP BY ErrorNumber ORDER BY countCase desc
declare @month tinyint,
		@year smallint,
		@codeLPU char(6),
		@dateReg DATE,
		@mcod CHAR(6),
		@typeFile char(1)
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear,@dateReg=CAST(f.DateRegistration AS DATE),@mcod =rc.rf_idMO, @typeFile=UPPER(f.TypeFile)
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile

/*
«начение должно соответствовать классификатору V024 (дл€ действующих на DATE_Z_2 записей) 
и должно удовлетвор€ть условию CODE_SH like 'sh%' or like Сmt%Т. 
 роме того, значение CODE_SH должно быть равно значению в одном из тегов CRIT. 
 роме того, если коду лексредства, указанному в REGNUM, задано соответствие в справочнике N021 (в N021 установлено соответствие кодов препаратов кодам схем), 
то в CODE_SH должна быть указана одна из соответствующих схем.
*/
SELECT DiagnosisCode INTO #t FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'C81' AND 'C96'

SELECT DISTINCT c.id,456,rf_idV024,c.DateBegin,c.DateEnd
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
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.sprv024 WHERE IDDKK=d.rf_idV024 AND DATEBEG<=cc.DateEnd AND DATEEND>=cc.DateEnd AND IDDKK LIKE '[sh,mt]%')
	AND Age>17 AND NOT EXISTS(SELECT 1 FROM #t WHERE DiagnosisCode=dd.ds1) 

	SELECT * FROM oms_nsi.dbo.sprV024 WHERE IDDKK='sh246'

SELECT DISTINCT c.id,456,d.rf_idV024,c.GUID_Case
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
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND NOT EXISTS(SELECT 1 FROM dbo.t_AdditionalCriterion WHERE rf_idCase=c.id AND rf_idAddCretiria=d.rf_idV024)
		AND Age>17 AND NOT EXISTS(SELECT 1 FROM #t WHERE DiagnosisCode=dd.ds1) AND c.rf_idV008<>32

SELECT DISTINCT c.id,456,d.rf_idV024,d.rf_idV020
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
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND d.rf_idV024 NOT IN('sh9001','sh9001') AND NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.sprN021 WHERE CODE_SH=d.rf_idV024 AND ID_LEKP=d.rf_idV020)
	AND Age>17 AND NOT EXISTS(SELECT 1 FROM #t WHERE DiagnosisCode=dd.ds1)

----------------------------Children--------------
SELECT DISTINCT c.id,456,d.rf_idV024
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
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND (Age<17 or EXISTS(SELECT 1 FROM #t WHERE DiagnosisCode=dd.ds1)) AND d.rf_idV024<>'нет'


GO
DROP TABLE #t