USE RegisterCases
go
declare @idFile INT

SELECT @idFile=f.id 
from vw_getIdFileNumber f WHERE CodeM='101801' AND ReportYear=2018 AND NumberRegister=11300
SELECT * FROM dbo.vw_getIdFileNumber WHERE id=@idFile									  

--SELECT ErrorNumber,COUNT(rf_idCase) FROM dbo.t_ErrorProcessControl WHERE rf_idFile=@idFile GROUP BY ErrorNumber

EXEC dbo.usp_RunRepeatTestAndDefineSMO @idFile
