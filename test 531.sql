USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

select @idFile=id from vw_getIdFileNumber where CodeM='155001' and NumberRegister=100012 and ReportYear=2014
select * from vw_getIdFileNumber where CodeM='155001' and NumberRegister=100012 and ReportYear=2014

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

select distinct c.id,531
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase								
where a.rf_idFiles=@idFile and r.IsNew>1

select distinct c.id,531,c.GUID_Case
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						inner join t_Case c1 on
			c.GUID_Case=c1.GUID_Case
			and c.id<>c1.id	
where a.rf_idFiles=@idFile and r.IsNew=0

SELECT a.NumberRegister,c.rf_idMO,ft.UserName
from t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
			  inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase
				INNER JOIN dbo.t_FileTested ft ON
			ft.id=f.rf_idFileTested
WHERE GUID_Case='61FE6FFC-BA4E-0C28-F638-E5F894B1B905'


select distinct c.id,531
from (
		select c.id,c.GUID_Case
		from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
		where a.rf_idFiles=@idFile and r.IsNew=1
	 ) c left join t_Case c1 on
			c.GUID_Case=c1.GUID_Case
			and c.id<>c1.id	
where c1.id is null
