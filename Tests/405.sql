USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

SELECT @idFile=f.id 
from vw_getIdFileNumber f WHERE CodeM='103001' AND ReportYear=2020 AND NumberRegister=933


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

SELECT DiagnosisCode INTO #tDIag FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'C%'
UNION ALL
SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'D00' AND 'D09'

select DISTINCT c.id,405
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase	
		AND c.DateEnd<'20190101'
				INNER JOIN dbo.t_AdditionalCriterion ac ON
		c.id=ac.rf_idCase						
where a.rf_idFiles=@idFile AND ac.rf_idAddCretiria IS NOT NULL AND c.rf_idV006 >2

select DISTINCT c.id,405
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase	
		AND c.DateEnd<'20190101'
				INNER JOIN dbo.t_AdditionalCriterion ac ON
		c.id=ac.rf_idCase	
where a.rf_idFiles=@idFile AND ac.rf_idAddCretiria IS NOT NULL AND NOT EXISTS(SELECT * FROM dbo.vw_sprAddCriterion WHERE code=ac.rf_idAddCretiria) 							

/*
≈сли присутствует, то N_KSG не пусто. «начение должно соответствовать V024 (выбираютс€ только действующие на DATE_Z_2 записи).

*/
select DISTINCT c.id,405
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase	
		AND c.DateEnd>='20190101'
				INNER JOIN dbo.t_AdditionalCriterion ac ON
		c.id=ac.rf_idCase	
where a.rf_idFiles=@idFile AND ac.rf_idAddCretiria IS NOT NULL AND NOT EXISTS(SELECT 1 FROM t_mes WHERE rf_idCase=c.id AND IsCSGTag=2)

select DISTINCT c.id,405 ,rf_idAddCretiria
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase	
			INNER JOIN dbo.t_CompletedCase cc ON
		r.id=cc.rf_idRecordCase	          
				INNER JOIN dbo.t_AdditionalCriterion ac ON
		c.id=ac.rf_idCase	
where a.rf_idFiles=@idFile AND ac.rf_idAddCretiria IS NOT NULL AND NOT EXISTS(SELECT 1 FROM sprV024 WHERE IDDKK=ac.rf_idAddCretiria and  DATEBEG<=cc.DateEnd AND DATEEND>=cc.DateEnd)

--SELECT * FROM oms_nsi.dbo.sprV024 WHERE IDDKK='sh123'
--SELECT * FROM oms_nsi.dbo.sprV024 WHERE IDDKK='sh130'
--SELECT * FROM sprV024 WHERE IDDKK='sh130'



--SELECT * FROM oms_nsi.dbo.sprV024 WHERE IDDKK='sh398.1'
/*
≈сли CRIT like СFR%Т or like 'fr%', то ONK_SL/K_FR >=0 (not is null), и в SL, в котором  CRIT like СFR%Т or like 'fr%' существует тег ONK_USL, дл€ которого USL_TIP in (3,4).
*/
select DISTINCT c.id,405
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase	
				INNER JOIN dbo.t_Diagnosis d ON
        c.id=d.rf_idCase
				INNER JOIN #tDIag dd ON
        dd.DiagnosisCode = d.DiagnosisCode
				INNER JOIN dbo.t_AdditionalCriterion ac ON
		c.id=ac.rf_idCase	
where a.rf_idFiles=@idFile AND ac.rf_idAddCretiria LIKE 'FR%' AND NOT EXISTS(SELECT 1 FROM dbo.t_ONK_SL WHERE rf_idCase=c.id AND ISNULL(K_FR,0)>0)

select DISTINCT c.id,405
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase	
				INNER JOIN dbo.t_Diagnosis d ON
        c.id=d.rf_idCase
				INNER JOIN #tDIag dd ON
        dd.DiagnosisCode = d.DiagnosisCode
				INNER JOIN dbo.t_AdditionalCriterion ac ON
		c.id=ac.rf_idCase	
where a.rf_idFiles=@idFile AND ac.rf_idAddCretiria LIKE 'FR%' AND NOT EXISTS(SELECT 1 FROM dbo.t_ONK_USL WHERE rf_idCase=c.id AND rf_idN013 IN(3,4))
GO
DROP TABLE #tDIag