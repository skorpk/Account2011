USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT	

select @idFile=id from vw_getIdFileNumber where CodeM='103001' and NumberRegister=319 and ReportYear=2021

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

SELECT DISTINCT c.id,319
	from t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
			AND a.ReportMonth=@month
			AND a.ReportYear=@year
				  inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
				  inner join t_Case c on
			r.id=c.rf_idRecordCase			
				INNER JOIN t_mes m ON
            c.id=m.rf_idCase
				INNER JOIN oms_nsi.dbo.sprMUV018V019V022Relation vr ON
            m.MES=vr.Code_MU
	where a.rf_idFiles=@idFile AND c.rf_idV006=1 AND c.rf_idV008=32 AND NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.sprMUV018V019V022Relation v WHERE m.MES=v.Code_MU AND v.IDHM=c.rf_idV019 AND IDHVID=c.rf_idV018 AND DateBeg<=c.DateEnd AND c.DateEnd<=DateEnd)

	SELECT distinct c.id,319,vr.CODE_MU,d.DiagnosisCode,c.rf_idV018,rf_idV019
	from t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
			AND a.ReportMonth=@month
			AND a.ReportYear=@year
				  inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
				  inner join t_Case c on
			r.id=c.rf_idRecordCase			
				INNER JOIN t_mes m ON
            c.id=m.rf_idCase
				INNER JOIN vw_MU_VMP_Diag vr ON
            m.MES=vr.Code_MU
				INNER JOIN dbo.t_Diagnosis d ON
            c.id=d.rf_idCase
			AND d.TypeDiagnosis=1
	where a.rf_idFiles=@idFile AND c.rf_idV006=1 AND c.rf_idV008=32 AND NOT EXISTS(SELECT 1 FROM vw_MU_VMP_Diag v 
																					WHERE m.MES=v.Code_MU AND METOD_HMP=c.rf_idV019 AND VID_HMP=c.rf_idV018 
																							AND DateBeg<=c.DateEnd AND c.DateEnd<=DateEnd 
																							AND v.DiagnosisCode=d.DiagnosisCode)

SELECT * FROM vw_MU_VMP_Diag WHERE CODE_MU='1.20.190' --AND DiagnosisCode='C25.0'