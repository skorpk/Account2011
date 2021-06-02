USE RegisterCases 
go
declare @CaseDefined TVP_CasePatient,		
		@idFile int
	
select top 1 @idFile=id from vw_getIdFileNumber where DateRegistration>'20121220' --order by CountSluch desc

select id, idRecordCase,Quantity,unitCode from vw_dataPlanOrder where rf_idFiles=@idFile order by idRecordCase


--select * from vw_getIdFileNumber  where id=@idFile

insert @CaseDefined(rf_idCase)
select c.id
from t_RegistersCase a inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
		and a.rf_idFiles=@idFile
						inner join t_Case c on
		r.id=c.rf_idRecordCase
						left join t_ErrorProcessControl e on
		c.id=e.rf_idCase
where e.rf_idCase is null

select rf_idCase,cast(SUM(Quantity) as decimal(11,2)),unitCode,idRecordCase
	from (
			select top 1000000 m.rf_idCase,c1.idRecordCase
				,cast((case when m.IsChildTariff=1 then m.Quantity*t1.ChildUET else m.Quantity*t1.AdultUET end) as decimal(11,2)) as Quantity
				,t1.unitCode
			from (
				  select c1.rf_idCase,c.idRecordCase 
				  from @CaseDefined  c1 inner join t_Case c on
								c1.rf_idCase=c.id										
				 ) c1
						inner join vw_MeduslugiMes m on
				c1.rf_idCase=m.rf_idCase							
						inner join dbo.vw_sprMU t1 on
						m.MUCode=t1.MU	
						and t1.unitCode is not null
				--order by c1.idRecordCase	
				) t
	group by rf_idCase,unitCode,idRecordCase
	order by idRecordCase asc