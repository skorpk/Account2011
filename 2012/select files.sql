use RegisterCases
go
select f.id,rtrim(f.FileNameHR) as FileNameHR,a.NumberRegister,f.CountSluch,f.CodeM,t001.NameS
from t_File f inner join t_RegistersCase a on
		f.id=a.rf_idFiles
				inner join vw_sprT001 t001 on
		f.CodeM=t001.CodeM
where a.ReportYear=2012
order by CodeM,NumberRegister
go
