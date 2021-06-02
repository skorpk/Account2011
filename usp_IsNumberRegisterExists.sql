use RegisterCases

if OBJECT_ID('usp_IsNumberRegisterExists',N'P') is not null
drop proc usp_IsNumberRegisterExists
go
create procedure usp_IsNumberRegisterExists
				@nSchet int,
				@year int,
				@codeLPU char(6)
as
select COUNT(*)
from t_File f inner join t_RegistersCase r on
		f.id=r.rf_idFiles
where f.CodeM=@codeLPU and r.ReportYear=@year and r.NumberRegister=@nSchet
go
	