use RegisterCases
go
select *
from vw_getIdFileNumber v inner join t_FileBack fb on
		v.id=fb.rf_idFiles
where v.CodeM='101321' and NumberRegister=20 and v.ReportYear=2012
go
	exec dbo.usp_PlanOrdersReport 6419,11771
go