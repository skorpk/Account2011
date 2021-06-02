use RegisterCases
go
--select c.id
--from t_Case c inner join vw_MeduslugiMes m on
--		c.id=m.rf_idCase
--group by c.id,c.AmountPayment
--having c.AmountPayment<>cast(SUM(m.Quantity*m.Price) as decimal(15,2)) 

select distinct rf_idFiles,v.CodeM,l.NameS
from(
		select c.id,a.rf_idFiles
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
								inner join t_Case c on
					r.id=c.rf_idRecordCase
								inner join vw_MeduslugiMes m on
					c.id=m.rf_idCase
		--where a.rf_idFiles=@idFile
		group by c.id,a.rf_idFiles,c.AmountPayment
		having c.AmountPayment<>cast(SUM(m.Quantity*m.Price) as decimal(15,2)) 
	) t inner join vw_getIdFileNumber v on
			t.rf_idFiles=v.id
					inner join vw_sprT001 l on
			v.CodeM=l.CodeM