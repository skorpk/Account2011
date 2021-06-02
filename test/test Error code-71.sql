use RegisterCases
go
declare @tDoubleCase as table(rf_idCase bigint)

insert @tDoubleCase
select d.rf_idCase
from t_File f inner join t_RegistersCase r on
		f.id=r.rf_idFiles
				inner join t_RecordCase rc on
		r.id=rc.rf_idRegistersCase
				inner join t_Case c on
		rc.id=c.rf_idRecordCase
				inner join t_Diagnosis d on
		c.id=d.rf_idCase
		and d.TypeDiagnosis=1
where FileNameHR='HRM175405T34_111101'
group by d.rf_idCase
having COUNT(*)>1

select * from @tDoubleCase

select * from t_Case where id=220844
select * from t_Diagnosis where rf_idCase=220845

select c.GUID_Case,c.id
from t_Case c inner join @tDoubleCase t on
		c.id=t.rf_idCase
group by c.GUID_Case,c.id
order by 2

declare @id int
select @id=f.id
from t_File f inner join t_RegistersCase r on
		f.id=r.rf_idFiles
				inner join t_RecordCase rc on
		r.id=rc.rf_idRegistersCase
				inner join t_Case c on
		rc.id=c.rf_idRecordCase
				inner join t_Diagnosis d on
		c.id=d.rf_idCase
		and d.TypeDiagnosis=1
where FileNameHR='HRM175405T34_111101'
group by f.id

--exec usp_RegisterCaseDelete @id

