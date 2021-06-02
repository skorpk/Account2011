use AccountOMS
go
if OBJECT_ID('vw_getPatientDoc',N'V') is not null
	drop view vw_getPatientDoc
go
create view vw_getPatientDoc
as
select rp.id,ID_Patient,rpd.rf_idDocumentType,rpd.SeriaDocument,rpd.NumberDocument,rpd.OKATO,rpd.SNILS,rpd.OKATO_Place
from AccountOMS.dbo.t_RegisterPatient rp left join AccountOMS.dbo.t_RegisterPatientDocument rpd on
				rp.id=rpd.rf_idRegisterPatient
where rpd.rf_idDocumentType is null
group by rp.id,ID_Patient,rpd.rf_idDocumentType,rpd.SeriaDocument,rpd.NumberDocument,rpd.OKATO,rpd.SNILS,rpd.OKATO_Place
go
use RegisterCases
go
if OBJECT_ID('vw_getPatientDoc',N'V') is not null
	drop view vw_getPatientDoc
go
create view vw_getPatientDoc
as
select ID_Patient,rpd.rf_idDocumentType,rpd.SeriaDocument,rpd.NumberDocument,rpd.OKATO,rpd.SNILS,rpd.OKATO_Place
from RegisterCases.dbo.t_RegisterPatient rp inner join RegisterCases.dbo.t_RegisterPatientDocument rpd on
				rp.id=rpd.rf_idRegisterPatient									
											inner join t_Case c on
				rp.rf_idRecordCase=c.rf_idRecordCase
											inner join t_RecordCaseBack rb on
				c.id=rb.rf_idCase
											inner join t_CaseBack cb on
				rb.id=cb.rf_idRecordCaseBack
				and cb.TypePay=1
where rpd.rf_idDocumentType is not null
group by ID_Patient,rpd.rf_idDocumentType,rpd.SeriaDocument,rpd.NumberDocument,rpd.OKATO,rpd.SNILS,rpd.OKATO_Place
go
use AccountOMS
go
create unique index UQ_t_RegisterPatientDocument_RefID on t_RegisterPatientDocument(rf_idRegisterPatient) with IGNORE_DUP_KEY