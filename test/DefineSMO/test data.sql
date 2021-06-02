use RegisterCases
go
select * from vw_getIdFileNumber where id in (3383,3158)

select *
from t_RegisterPatient p inner join t_RefRegisterPatientRecordCase rf on
			p.id=rf.rf_idRegisterPatient
where Fam='Скрыпникова' and Im='Елена' and Ot='Николаевна'

select ab.*,c.id,p.*
from t_Case c inner join t_RecordCaseBack rb on
					c.id=rb.rf_idCase
			inner join t_PatientBack p on
					rb.id=p.rf_idRecordCaseBack
			inner join t_RegisterCaseBack ab on
					rb.rf_idRegisterCaseBack=ab.id
where c.rf_idRecordCase=2296690

select * 
from t_FileBack where rf_idFiles=3158