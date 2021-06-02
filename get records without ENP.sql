USE RegisterCases
go
declare @idFile INT,
		@idFileBack INT


SELECT @idFile=f.id 
from vw_getIdFileNumber f WHERE CodeM='114504' AND ReportYear=2017 AND NumberRegister=2

SELECT @idFileBack=id FROM dbo.t_FileBack WHERE rf_idFiles=@idFile

 --EXEC dbo.usp_RegisterSP_TK @idFileBack 

SELECT cd.*
FROM dbo.t_Case c INNER JOIN dbo.t_RefCasePatientDefine rf ON
			c.id=rf.rf_idCase
					INNER JOIN dbo.t_CaseDefine cd ON
			rf.id=cd.rf_idRefCaseIteration                  
WHERE c.rf_idRecordCase=71605037

SELECT COUNT(distinct c.id),COUNT(DISTINCT cd.PID)
FROM dbo.t_Case c INNER JOIN dbo.t_RefCasePatientDefine rf ON
			c.id=rf.rf_idCase
					INNER JOIN dbo.t_CaseDefine cd ON
			rf.id=cd.rf_idRefCaseIteration                  
WHERE c.DateEnd>='20170101' AND cd.UniqueNumberPolicy IS null

SELECT EnP,* 
from vw_People WHERE id=1321436