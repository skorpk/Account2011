alter database AccountOMS set single_user with rollback immediate
go
use AccountOMS
go
declare @tID as table(id int)
insert @tID 
select id
from vw_getIdFileNumber 
where CodeM='451002' 
	and PrefixNumberRegister='34002' 
	and NumberRegister=3
	and PropertyNumberRegister=1
	and ReportYear=2012

select distinct m.*
into tmp_Meduslugi
from @tID t inner join t_RegistersAccounts a on
			t.id=a.rf_idFiles
		  inner join t_RecordCasePatient r on
			a.id=r.rf_idRegistersAccounts
						inner join t_Case c on
			r.id=c.rf_idRecordCasePatient
						inner join t_Meduslugi m on
			c.id=m.rf_idCase

--alter table tmp_Meduslugi add rf_idCaseOld bigint

--update tmp
--set tmp.rf_idCaseOld=m.rf_idCase
--from tmp_Meduslugi tmp inner join (
--									select m.rf_idCase,m.GUID_MU
--									from @tID t inner join t_RegistersAccounts a on
--												t.id=a.rf_idFiles
--											  inner join t_RecordCasePatient r on
--												a.id=r.rf_idRegistersAccounts
--															inner join t_Case c on
--												r.id=c.rf_idRecordCasePatient
--															inner join t_Meduslugi m on
--												c.id=m.rf_idCase
--									group by m.rf_idCase,m.GUID_MU
--									) m on tmp.GUID_MU=m.GUID_MU

delete from t_Meduslugi where rf_idCase in (select distinct rf_idCase from tmp_Meduslugi )
print 'удалили '+cast(@@rowcount as varchar(30))
INSERT INTO dbo.t_Meduslugi(rf_idCase,id,GUID_MU,rf_idMO,rf_idSubMO,rf_idDepartmentMO,rf_idV002,IsChildTariff,DateHelpBegin,DateHelpEnd
								,DiagnosisCode,MUGroupCode,MUUnGroupCode,MUCode,Quantity,Price,TotalPrice,rf_idV004,rf_idDoctor)
select distinct rf_idCase,id,GUID_MU,rf_idMO,rf_idSubMO,rf_idDepartmentMO,rf_idV002,IsChildTariff,DateHelpBegin,DateHelpEnd
								,DiagnosisCode,MUGroupCode,MUUnGroupCode,MUCode,Quantity,Price,TotalPrice,rf_idV004,rf_idDoctor 
from tmp_Meduslugi tmp 

print 'вставили'+cast(@@rowcount as varchar(30))

--select m.* 
--from tmp_Meduslugi tmp inner join t_Meduslugi m on
--		tmp.rf_idCase=m.rf_idCase
--		and tmp.GUID_MU=m.GUID_MU
go
alter database AccountOMS set multi_user 
go
drop table tmp_Meduslugi