use AccountOMS
go
select f.id,f.DateRegistration,f.CodeM,a.PrefixNumberRegister,a.NumberRegister,a.PropertyNumberRegister,f.FileNameHR,c.GUID_Case
--into tmp_FileMU
from t_File f inner join t_RegistersAccounts a on
		f.id=a.rf_idFiles
			inner join t_RecordCasePatient r on
		a.id=r.rf_idRegistersAccounts
			inner join t_Case c on
		r.id=c.rf_idRecordCasePatient
			left join t_Meduslugi m on
		c.id=m.rf_idCase
where m.rf_idCase is null and f.CodeM!='131940'
--group by f.id,f.DateRegistration,f.CodeM,a.PrefixNumberRegister,a.NumberRegister,a.PropertyNumberRegister,f.FileNameHR
order by f.DateRegistration

--файлы который былы удалены т.к. отсутствовали медуслуги
--select * from tmp_FileMU
select m.*
from t_File f inner join t_RegistersAccounts a on
		f.id=a.rf_idFiles
			inner join t_RecordCasePatient r on
		a.id=r.rf_idRegistersAccounts
			inner join t_Case c on
		r.id=c.rf_idRecordCasePatient
			inner join t_Meduslugi m on
		c.id=m.rf_idCase
where f.id=7367