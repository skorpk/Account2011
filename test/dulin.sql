use RegisterCases
go
select f.id,m.*
from t_File f inner join t_RegistersCase a on
		f.id=a.rf_idFiles
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
				inner join t_Case c on
		r.id=c.rf_idRecordCase
				inner join t_Meduslugi m on
		c.id=m.rf_idCase
where f.CodeM='255601' and NumberRegister=10004 --and c.GUID_Case='BDFBD063-C5BA-475C-8EC1-3CBCD1740C08'--and m.DateHelpBegin<'20000101'

order by DateHelpBegin
