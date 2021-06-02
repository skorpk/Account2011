USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

select @idFile=id from vw_getIdFileNumber where CodeM='106002' and NumberRegister=93 and ReportYear=2018

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

 select distinct c.id,579,c.Age,r.id,c.DateEnd,c.DateBegin,r.id
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where c.Age<0

--SELECT p.*
--FROM dbo.t_RefRegisterPatientRecordCase r INNER JOIN dbo.t_RegisterPatient p ON
--			r.rf_idRegisterPatient=p.id
--WHERE r.rf_idRecordCase=40630051			

select distinct c.id,579
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where c.Age>105

select distinct c.id,579
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join vw_RegisterPatient p on
			r.id=p.rf_idRecordCase
			and p.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
where p.BirthDay>=GETDATE()
