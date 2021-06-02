use RegisterCases
go
declare @CaseDefined TVP_CasePatient
declare @id int
declare @tError as table(rf_idCase bigint,ErrorNumber smallint)

select @id=id from vw_getIdFileNumber where CodeM='341001' and ReportYear=2012 and NumberRegister=15



insert @CaseDefined(rf_idCase,ID_Patient)
select c.id,p.id
from t_RegistersCase a inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
		and a.rf_idFiles=@id
						inner join t_Case c on
		r.id=c.rf_idRecordCase
						inner join vw_RegisterPatient p on
		r.id=p.rf_idRecordCase
		
declare @t1 as table(rf_idCase bigint,idRecordCase int,Quantity decimal(11,2),unitCode int,TotalRest int)
------------------------------------------------------

insert @t1(rf_idCase,Quantity,unitCode,idRecordCase)
select rf_idCase,cast(SUM(Quantity) as decimal(11,2)),unitCode,idRecordCase
from (
		select top 1000000 m.rf_idCase,c1.idRecordCase
							,cast((case when m.IsChildTariff=1 then m.Quantity*t1.ChildUET else m.Quantity*t1.AdultUET end) as decimal(11,2)) as Quantity
							,t1.unitCode
		from (
			  select c1.rf_idCase,c.idRecordCase 
			  from @CaseDefined  c1 inner join t_Case c on
							c1.rf_idCase=c.id
									left join @tError e on
							c1.rf_idCase=e.rf_idCase
			  where e.rf_idCase is null
		     ) c1
					inner join vw_MeduslugiMes m on
			c1.rf_idCase=m.rf_idCase							
					inner join dbo.vw_sprMU t1 on
					m.MUCode=t1.MU	
		--order by c1.idRecordCase	
		) t
group by rf_idCase,unitCode,idRecordCase
order by idRecordCase asc

select * from @t1