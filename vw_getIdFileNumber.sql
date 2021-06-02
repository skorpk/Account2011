use RegisterCases
go
create view vw_getIdFileNumber
as
select f.id,f.CodeM,f.DateRegistration,f.FileNameHR,a.NumberRegister,a.ReportMonth,a.ReportYear
from t_File f inner join t_RegistersCase a on
		f.id=a.rf_idFiles
