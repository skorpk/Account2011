USE RegisterCases
go
SET NOCOUNT ON
DECLARE @number INT=28,
		@codeM CHAR(6)='256501',
		@idFile int
		
SELECT @idFile=id FROM dbo.vw_getIdFileNumber WHERE CodeM=@codeM AND NumberRegister=@number AND ReportYear=2013

SELECT * 
FROM dbo.t_RefCasePatientDefine r INNER JOIN dbo.t_CaseDefineZP1 z ON
			r.id=z.rf_idRefCaseIteration
WHERE r.rf_idFiles=@idFile AND r.IsUnloadIntoSP_TK IS null
go