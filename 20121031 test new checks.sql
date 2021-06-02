USE RegisterCases
go
declare @idFile int
select @idFile=id from vw_getIdFileNumber where CodeM='311001' and NumberRegister=104
select @idFile,CountSluch  from vw_getIdFileNumber where id=@idFile

select distinct ErrorNumber from t_ErrorProcessControl where rf_idFile=@idFile

select c1.id,50,c1.GUID_Case,idRecordCase
	from(
		select c.id,c.idRecordCase,c.GUID_Case,max(c1.id) as MaxID
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile
					and r.IsNew=1
								inner join t_Case c on
					r.id=c.rf_idRecordCase
								inner join t_Case c1 on
				c.GUID_Case=c1.GUID_Case
				and c.id<>c1.id
		group by c.id,c.idRecordCase,c.GUID_Case
		 ) c1 inner join t_ErrorProcessControl e on
				c1.MaxID=e.rf_idCase
				and e.ErrorNumber=50
go
select f.DateRegistration,a.NumberRegister
from t_File f inner join t_RegistersCase a on
			f.id=a.rf_idFiles
						inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase
where c.GUID_Case in ('EB5AAD30-5DA9-E7BF-3795-F8452C239810')