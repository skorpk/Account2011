declare @t as table(guidCase uniqueidentifier)

insert @t
select c.GUID_Case
from t_Case c inner join (
							select GUID_Case
							from t_File f inner join t_RegistersCase r on
									f.id=r.rf_idFiles
											inner join t_RecordCase r1 on
									r.id=r1.rf_idRegistersCase
											inner join t_Case c on
									r1.id=c.rf_idRecordCase
							where CodeM='121125' and NumberRegister=4
					) t on c.GUID_Case=t.GUID_Case
group by c.GUID_Case
having COUNT(*)>1

--exec usp_RegisterCaseDelete 1736

select r.NumberRegister
from t_File f inner join t_RegistersCase r on
		f.id=r.rf_idFiles
			inner join t_RecordCase r1 on
	   r.id=r1.rf_idRegistersCase
			inner join t_Case c on
		r1.id=c.rf_idRecordCase
			inner join @t t on
		c.GUID_Case=t.guidCase
--where c.GUID_Case='6A402B2B-97ED-4894-BDAB-D0483E98D049'
group by r.NumberRegister