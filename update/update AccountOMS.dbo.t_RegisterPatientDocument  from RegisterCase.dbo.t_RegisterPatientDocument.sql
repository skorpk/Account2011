select pa.id,pr.rf_idDocumentType,pr.SeriaDocument,pr.NumberDocument
		,pr.SNILS,pr.OKATO,pr.OKATO_Place
from AccountOMS.dbo.vw_getPatientDoc pa inner join RegisterCases.dbo.vw_getPatientDoc pr on
				pa.ID_Patient=pr.ID_Patient
group by pa.id,pr.rf_idDocumentType,pr.SeriaDocument,pr.NumberDocument
		,pr.SNILS,pr.OKATO,pr.OKATO_Place



insert AccountOMS.dbo.t_RegisterPatientDocument(rf_idRegisterPatient,rf_idDocumentType,SeriaDocument,
												NumberDocument,SNILS,OKATO,OKATO_Place)
select pa.id,pr.rf_idDocumentType,pr.SeriaDocument,pr.NumberDocument
		,pr.SNILS,pr.OKATO,pr.OKATO_Place
from AccountOMS.dbo.vw_getPatientDoc pa inner join RegisterCases.dbo.vw_getPatientDoc pr on
					pa.ID_Patient=pr.ID_Patient
										left join AccountOMS.dbo.t_RegisterPatientDocument p on
					pa.id=p.rf_idRegisterPatient
where p.rf_idRegisterPatient is null							
group by pa.id,pr.rf_idDocumentType,pr.SeriaDocument,pr.NumberDocument,pr.SNILS,pr.OKATO,pr.OKATO_Place


