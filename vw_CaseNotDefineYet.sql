USE RegisterCases
GO
--вьюха которая показывает случай по которым не определена страховая принадлежность
if OBJECT_ID('vw_CaseNotDefineYet',N'V') is not null
drop view vw_CaseNotDefineYet
go
create view vw_CaseNotDefineYet
as
select czp1.rf_idRefCaseIteration,czp1.rf_idZP1
from t_RefCasePatientDefine rf inner join t_CaseDefineZP1 czp1 on
					rf.id=czp1.rf_idRefCaseIteration
					and rf.IsUnloadIntoSP_TK is null					
where NOT EXISTS (SELECT * FROM t_CasePatientDefineIteration WHERE rf_idRefCaseIteration=rf.id)
group by czp1.rf_idRefCaseIteration,czp1.rf_idZP1
go
