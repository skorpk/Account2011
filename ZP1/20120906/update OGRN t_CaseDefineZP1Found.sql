use RegisterCases
go
begin transaction
select * from t_CaseDefineZP1Found where rf_idRefCaseIteration=10000678
update t_CaseDefineZP1Found set OGRN_SMO='1028601441274' where rf_idRefCaseIteration=10000678
select * from t_CaseDefineZP1Found where rf_idRefCaseIteration=10000678
commit