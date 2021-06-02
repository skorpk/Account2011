USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

select @idFile=id from vw_getIdFileNumber where CodeM='106002' and NumberRegister=4 and ReportYear=2019

select * from vw_getIdFileNumber where id=@idFile

select distinct c.id,532
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
					inner join t_Case c on
			r.id=c.rf_idRecordCase
					left join (select * from t_RegisterPatient where rf_idFiles=@idFile) p on
			r.ID_Patient=p.ID_Patient
where p.id is null


