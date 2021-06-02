use AccountOMS
go
select c.rf_idMO,a.PrefixNumberRegister,a.NumberRegister,a.PropertyNumberRegister,ReportYear,Letter
from t_RegistersAccounts a inner join t_RecordCasePatient r on
				a.id=r.rf_idRegistersAccounts
							inner join t_Case c on
				r.id=c.rf_idRecordCasePatient				
							inner join t_Meduslugi m on
				c.id=m.rf_idCase
							inner join 
										(
										select m.rf_idCase,m.GUID_MU,m.rf_idMO
										from t_RegistersAccounts a inner join t_RecordCasePatient r on
														a.id=r.rf_idRegistersAccounts
																	inner join t_Case c on
														r.id=c.rf_idRecordCasePatient
																	inner join t_Meduslugi m on
														c.id=m.rf_idCase
										group by m.rf_idCase,m.GUID_MU,m.rf_idMO
										having COUNT(*)>1
										) d  on m.rf_idCase=d.rf_idCase and m.GUID_MU=d.GUID_MU
group by c.rf_idMO,a.PrefixNumberRegister,a.NumberRegister,a.PropertyNumberRegister,ReportYear,Letter