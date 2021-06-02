select c.GUID_Case,c.idRecordCase,f.id,COUNT(*) as countDoubleRecord
from t_Case c inner join t_RecordCase r on
		c.rf_idRecordCase=r.id
			inner join t_RegistersCase a on
		r.rf_idRegistersCase=a.id
			inner join t_File f on
		a.rf_idFiles=f.id
		and f.DateRegistration>'20111223'
			left join t_ErrorProcessControl e on
		c.id=e.rf_idCase
where e.rf_idCase is null
group by c.GUID_Case,c.idRecordCase,f.id
having count(*)>1