use RegisterCases
go
declare @id int

select @id=id from vw_getIdFileNumber where CodeM='154620' and NumberRegister=9 and ReportYear=2012
begin transaction
select distinct f.id, f.CodeM,t.NameS, a.NumberRegister,a.PropertyNumberRegister,f.DateCreate,f.FileNameHRBack--p.*,ps.OKATO
--update p
--set p.OKATO=ps.OKATO,p.rf_idSMO='34'
from t_FileBack f inner join t_RegisterCaseBack a on
			f.id=a.rf_idFilesBack
			--and f.rf_idFiles=@id
			and f.DateCreate>'20120215'
			and a.PropertyNumberRegister=2
				inner join t_RecordCaseBack r on
			a.id=r.rf_idRegisterCaseBack
				inner join t_PatientBack p on
			r.id=p.rf_idRecordCaseBack
				inner join t_RecordCase r1 on
			r.rf_idRecordCase=r1.id
				inner join t_PatientSMO ps on
			r1.id=ps.ref_idRecordCase
				inner join vw_sprT001 t on
			f.CodeM=t.CodeM
where p.OKATO='18000' and p.rf_idSMO not in (select s.smocod from vw_sprSMO s) and ps.OKATO is not null and f.IsUnload=1
order by CodeM
rollback