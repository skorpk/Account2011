use RegisterCases
go
select a.ReportMonth,a.ReportYear,f.id,f.CountSluch,ft.UserName, t.NameS,f.FileNameHR,a.NumberRegister
from t_File f inner join t_RegistersCase a on
		f.id=a.rf_idFiles
				inner join t_FileTested ft on
		f.rf_idFileTested=ft.id
				inner join vw_sprT001 t on
		f.CodeM=t.CodeM
where ReportYear=2012
go
/*
exec usp_RegisterCaseDelete 1905
exec usp_RegisterCaseDelete 1915
exec usp_RegisterCaseDelete 1938
exec usp_RegisterCaseDelete 2058
exec usp_RegisterCaseDelete 1988
exec usp_RegisterCaseDelete 2125
exec usp_RegisterCaseDelete 1785
exec usp_RegisterCaseDelete 1908
exec usp_RegisterCaseDelete 2057
exec usp_RegisterCaseDelete 1960
exec usp_RegisterCaseDelete 2041
exec usp_RegisterCaseDelete 1869
exec usp_RegisterCaseDelete 1835
exec usp_RegisterCaseDelete 1788
exec usp_RegisterCaseDelete 2111
exec usp_RegisterCaseDelete 2118
exec usp_RegisterCaseDelete 1857
exec usp_RegisterCaseDelete 2094
*/

/*
select f.id,a.NumberRegister,f.FileNameHR,f.DateRegistration
from t_File f inner join t_RegistersCase a on
		f.id=a.rf_idFiles
where CodeM='165531' and NumberRegister=652

exec usp_RegisterCaseDelete 1500
exec usp_RegisterCaseDelete 1530
*/