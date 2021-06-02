use RegisterCases
go
--select *--r.rf_idFiles ,cp.rf_idIteration
--from t_RefCasePatientDefine r inner join t_CaseDefineZP1Found zp1 on
--			r.id=zp1.rf_idRefCaseIteration
--							inner join t_CasePatientDefineIteration cp on
--			r.id=cp.rf_idRefCaseIteration
--where rf_idFiles=5
----group by r.rf_idFiles,cp.rf_idIteration
select * 
from t_RefCasePatientDefine c left join t_CasePatientDefineIteration p on
				c.id=p.rf_idRefCaseIteration
where rf_idFiles=15

--select * from t_File 

--exec usp_GetProcessingZP1Data
select * from vw_CaseNotDefineYeat
go
use PolicyRegister
go
--select * from ZP1LOG
--delete from ZP1LOG where ID in (58,59,61,62,63,64,65,66,67,68,69)
--select * from ZP1LOG
select * 
from ZP1LOG zl inner join ZP1 z on
		zl.ID=z.ZID
where z.ZID>51 and z.REPL is not null



