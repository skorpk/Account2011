use RegisterCases
go
select fb.FileNameHRBack
from vw_getIdFileNumber v inner join t_FileBack fb on
		v.id=fb.rf_idFiles
where v.CodeM='141023' and ReportMonth=4 and ReportYear=2012
group by fb.FileNameHRBack
having COUNT(*)>1

select MAX(id),FileNameHRBack
from t_FileBack where FileNameHRBack in (select fb.FileNameHRBack
										 from vw_getIdFileNumber v inner join t_FileBack fb on
													v.id=fb.rf_idFiles
										 where v.CodeM='141023' and ReportMonth=4 and ReportYear=2012
										 group by fb.FileNameHRBack
										 having COUNT(*)>1
										)
group by FileNameHRBack
order by FileNameHRBack
go
select a.NumberRegister,count(distinct r.ID_Patient) as TotalRecords
from vw_getIdFileNumber v inner join t_RegistersCase a on
		v.id=a.rf_idFiles
						inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
where v.CodeM='141023' and v.ReportMonth=4 and v.ReportYear=2012
group by a.NumberRegister
order by TotalRecords desc