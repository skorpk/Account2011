USE RegisterCases
go
SET NOCOUNT ON

select e.ErrorNumber,COUNT(c.id)
from t_File f inner join t_RegistersCase a on
		f.id=a.rf_idFiles
		and f.CodeM='101003'
		and NumberRegister=1
		and ReportYear=2013
				inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
				inner join t_Case c on
		r.id=c.rf_idRecordCase
				inner join t_ErrorProcessControl e on
		c.id=e.rf_idCase
				
go
