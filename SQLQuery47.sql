use RegisterCases
go
select * from t_File
go
--delete from t_FileBack where id in (4,5)

--go
/*
delete from t_FileBack where id in (7)
delete from t_File where id in (6)
delete from t_RefCasePatientDefine where rf_idFiles in (6)
*/
go

select * from t_FileBack

select rf_idFiles
from t_RefCasePatientDefine c 
group by rf_idFiles
order by 1


