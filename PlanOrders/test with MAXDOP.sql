USE RegisterCases
go
dbcc freeproccache
go
declare @idFile int,
		@idFileBack int
select top 2 @idFile=rf_idFiles,@idFileBack=idFileBack 
from vw_getFileBack where DateCreate>'20121112' and AmountCasesPayed>1000 order by AmountCasesPayed desc

set statistics time on

exec usp_PlanOrdersReport @idFile,@idFileBack

set statistics time off
go