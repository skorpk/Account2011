USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT	

select @idFile=id from vw_getIdFileNumber where CodeM='581001' and NumberRegister=21298 and ReportYear=2021

select * from vw_getIdFileNumber where id=@idFile

declare @month tinyint,
		@year smallint,
		@codeLPU char(6)
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile
--устанавливаем дату начала и дату окончания отчетного периода
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))	

SELECT DiagnosisCode INTO #td FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'D00' AND 'D09'
UNION ALL 
SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'C%'

SELECT DISTINCT c.id,'314',c.NumberHistoryCase
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase			
				INNER JOIN dbo.vw_Diagnosis d ON
        c.id=d.rf_idCase
				INNER JOIN #td t ON
		t.DiagnosisCode=d.DS1
where a.rf_idFiles=@idFile AND c.rf_idV006=3 AND c.rf_idV009 IN(308,309,315)
AND NOT EXISTS(SELECT 1 FROM dbo.t_DirectionMU dm WHERE dm.rf_idCase=c.id)

SELECT DISTINCT c.id,'314',c.NumberHistoryCase
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase			
				INNER JOIN dbo.t_DS_ONK_REAB d ON
        c.id=d.rf_idCase
where a.rf_idFiles=@idFile AND c.rf_idV006=3 AND c.rf_idV009 IN(308,309,315) AND d.DS_ONK=1
AND NOT EXISTS(SELECT 1 FROM dbo.t_DirectionMU dm WHERE dm.rf_idCase=c.id)
-----------------------------------------------------------------------------------------
SELECT DISTINCT c.id,'314',c.NumberHistoryCase
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase			
				INNER JOIN dbo.vw_Diagnosis d ON
        c.id=d.rf_idCase
				INNER JOIN #td t ON
		t.DiagnosisCode=d.DS1
where a.rf_idFiles=@idFile AND c.rf_idV006=3 AND c.rf_idV009 IN(308,309)
AND NOT EXISTS(SELECT 1 FROM dbo.t_DirectionMU dm WHERE dm.rf_idCase=c.id AND dm.TypeDirection IN(1,4))


SELECT DISTINCT c.id,'314',c.NumberHistoryCase
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase			
				INNER JOIN dbo.t_DS_ONK_REAB d ON
        c.id=d.rf_idCase
where a.rf_idFiles=@idFile AND c.rf_idV006=3 AND c.rf_idV009 IN(308,309) AND d.DS_ONK=1
AND NOT EXISTS(SELECT 1 FROM dbo.t_DirectionMU dm WHERE dm.rf_idCase=c.id AND dm.TypeDirection IN(1,4))

SELECT DISTINCT c.id,'314',c.NumberHistoryCase,'Error'
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase			
				INNER JOIN dbo.vw_Diagnosis d ON
        c.id=d.rf_idCase
				INNER JOIN #td t ON
		t.DiagnosisCode=d.DS1
where a.rf_idFiles=@idFile AND c.rf_idV006=3 AND c.rf_idV009=315
AND NOT EXISTS(SELECT 1 FROM dbo.t_DirectionMU dm WHERE dm.rf_idCase=c.id AND dm.TypeDirection=3)
SELECT * FROM dbo.vw_sprV009 WHERE id=315
SELECT * FROM oms_nsi.dbo.sprV028 WHERE IDVN=3

SELECT DISTINCT c.id,'314',c.NumberHistoryCase
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase			
				INNER JOIN dbo.t_DS_ONK_REAB d ON
        c.id=d.rf_idCase
where a.rf_idFiles=@idFile AND c.rf_idV006=3 AND c.rf_idV009 =315 AND d.DS_ONK=1
AND NOT EXISTS(SELECT 1 FROM dbo.t_DirectionMU dm WHERE dm.rf_idCase=c.id AND dm.TypeDirection=3)
GO 
DROP TABLE #td