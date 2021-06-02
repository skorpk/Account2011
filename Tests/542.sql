USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

select @idFile=id from vw_getIdFileNumber where CodeM='611001' and NumberRegister=171 and ReportYear=2018

select * from vw_getIdFileNumber where id=@idFile

select distinct c.id,542
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.IsCompletedCase=1
						left join vw_sprV08 f on
			c.rf_idV008=f.ID
where f.ID is null
---2015-01-30 Проверка на соответствие Код ЗС+КСГ и виду медицинской помощи. проверка была пропущенна мною, по каким то не известным причинам.
select distinct c.id,542, m.MES
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.IsCompletedCase=1
						INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase						
WHERE NOT EXISTS(SELECT * FROM dbo.vw_sprMUUnionV008 WHERE MU=m.MES AND V008=c.rf_idV008)  