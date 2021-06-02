USE RegisterCases
go
update r
set r.AttachLPU=tmp.LPU
from AccountOMS.dbo.t_RecordCasePatient r inner join (
														select distinct r.ID_Patient,p.LPU 
														from t_RegistersCase a inner join t_RecordCase r on
																	a.id=r.rf_idRegistersCase
																	and a.ReportYear=2012
																			inner join t_Case c on
																	r.id=c.rf_idRecordCase
																	and c.DateEnd>='20120101' 
																	and c.DateEnd<='20130101' 
																			inner join t_RefCasePatientDefine d on
																	c.id=d.rf_idCase
																			inner join t_CaseDefine cd on
																	d.id=cd.rf_idRefCaseIteration
																			inner join PolicyRegister.dbo.PEOPLE p on
																	cd.PID=p.ID
														where (DateDefine>='20120101' and DateDefine<=GETDATE()) and (p.LPU is not null)
													  ) tmp on
				r.ID_Patient=tmp.ID_Patient
go
