use RegisterCases
go
declare @id int=2280
select f.CodeM,r.*,len(r.NumberPolis),e.ErrorNumber
from t_File f inner join t_RegistersCase a on
		f.id=a.rf_idFiles
				inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
				inner join t_Case c on
		r.id=c.rf_idRecordCase
				inner join t_ErrorProcessControl e on
		c.id=e.rf_idCase
where f.id=@id and e.ErrorNumber<>62
				
				
				
				
				
