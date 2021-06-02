use RegisterCases
go
select *
from vw_getIdFileNumber where CodeM='254506' and ReportYear=2012 and NumberRegister=12020

exec usp_DefineSMOIteration2_4Repeat 4307