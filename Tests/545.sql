USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT	

select @idFile=id from vw_getIdFileNumber where CodeM='804504' and NumberRegister=1 and ReportYear=2021

SELECT  ErrorNumber,COUNT(rf_idCase) AS CountCase from dbo.t_ErrorProcessControl WHERE rf_idFile=@idFile GROUP BY ErrorNumber   ORDER BY CountCase

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

SELECT * FROM vw_sprT001 WHERE CodeM='804504'

select distinct c.id,545,a.rf_idMO ,c.rf_idMO,'error'
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						left join vw_sprT001 l on
			a.rf_idMO=l.mcod				
			and c.rf_idMO=l.CodeM		
where l.CodeM is null
--соответствия заявленного значения коду медицинской организации, указанному в имени файла.
select distinct c.id,545
from t_File f inner join t_RegistersCase a on
			f.id=a.rf_idFiles
			and f.id=@idFile 
						inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where f.CodeM<>c.rf_idMO