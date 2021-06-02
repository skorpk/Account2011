use RegisterCases
go
if OBJECT_ID('vw_GetUnLoadPersonInPolicyDB',N'V') is not null
	drop view vw_GetUnLoadPersonInPolicyDB
go
create view vw_GetUnLoadPersonInPolicyDB
as
	select distinct r.rf_idFiles,rtrim(f.FileNameHR) as FileNameHR,cast(f.DateRegistration as date) as DateReg,f.CodeM
	from t_File f inner join t_RefCasePatientDefine r on
			f.id=r.rf_idFiles
					left join t_CaseDefineZP1 z on
			r.id=z.rf_idRefCaseIteration			
	where (IsUnloadIntoSP_TK is null) and z.rf_idRefCaseIteration is null
go