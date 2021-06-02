use master
go
alter database RegisterCases set SINGLE_USER with rollback immediate
go
use RegisterCases
go
begin transaction

delete from t_PatientBack where rf_idRecordCaseBack in (
														select pb.rf_idRecordCaseBack as id
														from  t_RecordCaseBack rcb inner join (		
																								select rf_idRecordCaseBack 
																								from t_PatientBack p 
																								group by rf_idRecordCaseBack having COUNT(*)>1
																								) t on
																	rcb.id=t.rf_idRecordCaseBack
																			inner join t_PatientBack pb on
																	rcb.id=pb.rf_idRecordCaseBack
																	
																			inner join t_CaseBack p on
																	rcb.id=p.rf_idRecordCaseBack
																	and p.TypePay=2
														) and rf_idSMO not in (select '00' union all select '0') 
														
select pb.rf_idRecordCaseBack as id
from  t_RecordCaseBack rcb inner join (		
										select rf_idRecordCaseBack 
										from t_PatientBack p 
										group by rf_idRecordCaseBack having COUNT(*)>1
									  ) t on
										rcb.id=t.rf_idRecordCaseBack
							inner join t_PatientBack pb on
										rcb.id=pb.rf_idRecordCaseBack
							inner join t_CaseBack p on
										rcb.id=p.rf_idRecordCaseBack
										and p.TypePay=2
commit

go
alter database RegisterCases set MULTI_USER