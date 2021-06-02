use RegisterCases
go
/*
select * 
from vw_sprT001
where CodeM='741901'

select * from t_File where CodeM='741901'

--exec usp_RegisterCaseDelete 656

select * from t_FileBack where CodeM='255802'

select *
from t_FileBack 
where CodeM='741901'
*/
select r.*,cb.TypePay,p.rf_idSMO,c.GUID_Case,p.OKATO,r.PropertyNumberRegister
from t_Case c inner join t_RecordCaseBack rcb on
		c.id=rcb.rf_idCase
				inner join t_CaseBack cb on
		rcb.id=cb.rf_idRecordCaseBack
				inner join t_RegisterCaseBack r on
		rcb.rf_idRegisterCaseBack=r.id
				inner join t_PatientBack p on
		rcb.id=p.rf_idRecordCaseBack
where GUID_Case in (select * from AccountOMS.dbo.t_GUID)--('12C60F3A-2646-4E32-96CD-E48E03809A8B')

--select * from t_FileBack where id=682

--select * from AccountOMS.dbo.t_CaseError