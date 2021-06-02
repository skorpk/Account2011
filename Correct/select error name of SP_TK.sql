use RegisterCases
go
select f.id,f.FileNameHR,f.CodeM,fb.FileNameHRBack,fb.CodeM
from t_File f inner join t_FileBack fb on
		f.id=fb.rf_idFiles
		and f.CodeM<>fb.CodeM
order by f.id

select *
from t_FileBack where rf_idFiles=785