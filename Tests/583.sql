USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

select @idFile=id from vw_getIdFileNumber where CodeM='103001' and NumberRegister=5 and ReportYear=2019

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

 select c.id,583,d.OKATO
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
							inner join t_RegisterPatientDocument d on
				p.id=d.rf_idRegisterPatient
where d.OKATO IS NOT NULL AND NOT EXISTS(SELECT 1 FROM OMS_NSI.dbo.vw_Accounts_OKATO2 WHERE OKATO=d.OKATO)

select c.id,583	
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join t_RefRegisterPatientRecordCase ref on
				r.id=ref.rf_idRecordCase
							inner join t_RegisterPatient p on
				ref.rf_idRegisterPatient=p.id
				and p.rf_idFiles=@idFile
							inner join t_RegisterPatientDocument d on
				p.id=d.rf_idRegisterPatient					
where d.OKATO_Place IS NOT NULL AND NOT EXISTS(SELECT 1 FROM OMS_NSI.dbo.vw_Accounts_OKATO2 WHERE OKATO=d.OKATO_Place)

SELECT * FROM OMS_NSI.dbo.vw_Accounts_OKATO2 WHERE namel LIKE '%Волжский%'