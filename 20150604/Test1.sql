USE RegisterCasesTest
GO

DECLARE @CaseDefined as TVP_CasePatient
DECLARE @idFile INT=66561,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)
/*
INSERT @CaseDefined 
SELECT rp.rf_idCase,rp.rf_idRegisterPatient
FROM dbo.t_RefCasePatientDefine rp
WHERE NOT EXISTS(SELECT * FROM dbo.t_ErrorProcessControl WHERE rf_idCase=rp.rf_idCase) AND rp.rf_idFiles=66561

exec usp_RunProcessControl @CaseDefined,@idFile 
*/
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear
from t_FileBack f inner join t_RegisterCaseBack rc on
					f.id=rc.rf_idFilesBack
							inner join oms_nsi.dbo.vw_sprT001 v on
					f.CodeM=v.CodeM		
where f.rf_idFiles=@idFile


create table #tmpPlan
		(
			CodeLPU varchar(6),
			UnitCode int,
			Vm int,
			Vdm int,
			Spred decimal(11,2),
			[month] tinyint
		)
EXEC dbo.usp_PlanOrders @codeLPU,@month,@year
go
DROP TABLE #tmpPlan
