use RegisterCases
go
declare @t as TVP_CasePatient
declare @fileName varchar(26)='HRM111008T34_111101'

insert @t
select rf_idCase,rf_idRegisterPatient
from t_RefCasePatientDefine
where IsUnloadIntoSP_TK is null

exec usp_DefineSMOIteration2_4 @t,2,@fileName

