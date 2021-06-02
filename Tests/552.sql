USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT--=127080

SELECT @idFile=f.id 
from vw_getIdFileNumber f WHERE CodeM='103001' AND ReportYear=2021 AND NumberRegister=313

SELECT * FROM dbo.vw_getIdFileNumber WHERE id=@idFile									  


--select * from vw_getIdFileNumber where id=@idFile
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

select distinct c.id,552 as Error
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase
						inner join dbo.t_Diagnosis d on
			c.id=d.rf_idCase									
where a.rf_idFiles=@idFile AND NOT EXISTS(SELECT * FROM dbo.vw_sprMKB10 WHERE DiagnosisCode=ISNULL(d.DiagnosisCode,'bla-bla'))

select distinct c.id,552 as Error
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase
						inner join dbo.t_DS2_Info d on
			c.id=d.rf_idCase									
where a.rf_idFiles=@idFile AND NOT EXISTS(SELECT * FROM dbo.vw_sprMKB10 WHERE DiagnosisCode=ISNULL(d.DiagnosisCode,'bla-bla'))

select distinct c.id,552,d.DS1
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
								inner join t_Case c on
					r.id=c.rf_idRecordCase
								JOIN dbo.t_CompletedCase cc ON
                    cc.rf_idRecordCase = r.id
								inner join (SELECT DISTINCT rf_idCase,DiagnosisCode AS DS1 FROM dbo.t_Diagnosis 
											UNION ALL
											SELECT DISTINCT rf_idCase,DiagnosisCode AS DS1 FROM dbo.t_DS2_Info )  d on
					c.id=d.rf_idCase					
where a.rf_idFiles=@idFile and NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.sprMKBPeriod mkb WHERE mkb.DiagnosisCode=d.DS1 and cc.DateEnd>=mkb.DateBeg AND cc.DateEnd<=mkb.DateEnd)

SELECT * FROM oms_nsi.dbo.sprMKBPeriod WHERE DiagnosisCode='K58.9'

select distinct c.id,552
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
								inner join t_Case c on
					r.id=c.rf_idRecordCase
								inner join (SELECT DISTINCT rf_idCase,DiagnosisCode AS DS1 FROM dbo.t_Diagnosis 
											UNION ALL
											SELECT DISTINCT rf_idCase,DiagnosisCode AS DS1 FROM dbo.t_DS2_Info ) d on
					c.id=d.rf_idCase
								INNER JOIN dbo.vw_RegisterPatient p ON
				p.rf_idFiles=@idFile
				and r.id=p.rf_idRecordCase					
where a.rf_idFiles=@idFile AND NOT EXISTS(SELECT 1 FROM oms_NSI.dbo.sprMKB mkb WHERE d.DS1=(mkb.DiagnosisCode) AND p.rf_idV005=ISNULL(mkb.Sex,p.rf_idV005) )