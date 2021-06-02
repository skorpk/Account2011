SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

select * 
from t_FileBack where rf_idFiles=28

--select * from t_File where id=28

select rc.ID_Patient as ID_PAC,p.rf_idF008 as VPOLIS,p.SeriaPolis as SPOLIS,p.NumberPolis as NPOLIS,
		p.rf_idSMO as SMO,p.OKATO as SMO_OK,rc.idRecord as N_ZAP,recb.id
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id
							left join t_PatientBack p on
			recb.id=p.rf_idRecordCaseBack
where rf_idFilesBack=61
group by rc.ID_Patient,p.rf_idF008,p.SeriaPolis,p.NumberPolis,p.rf_idSMO ,p.OKATO ,rc.idRecord ,recb.id
order by N_ZAP


select distinct rp.* 
from t_RefCasePatientDefine r inner join t_CaseDefineZP1Found c on
			r.id=c.rf_idRefCaseIteration
							inner join t_CasePatientDefineIteration i on
			r.id=i.rf_idRefCaseIteration
			and i.rf_idIteration in (2,4)
							inner join t_RegisterPatient rp on
			r.rf_idRegisterPatient=rp.id			
where r.rf_idCase=42021--r.rf_idFiles=28 and rp.ID_Patient='74-852077'

select *
from t_Case c inner join t_RecordCase r on
		c.rf_idRecordCase=r.id
where r.ID_Patient='74-852077'
