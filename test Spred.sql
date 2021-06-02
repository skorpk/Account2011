declare @codeLPU char(6)='171004'
		,@month tinyint=10
		,@year smallint=2011

declare @t as table(CodeLPU char(6),unitCode tinyint,Rate int)

insert @t
select c.rf_idMO
		,t1.unitCode
		,SUM(m.Quantity) as Quantity
from t_Case c inner join t_Meduslugi m on
		c.id=m.rf_idCase and c.rf_idMO=@codeLPU
				inner join dbo.vw_sprMU t1 on
		m.MUCode=t1.MU
				inner join t_RecordCase rc on
		c.rf_idRecordCase=rc.id
				inner join t_RegistersCase r on
		rc.rf_idRegistersCase=r.id and
		r.ReportMonth=@month and
		r.ReportYear=@year
				inner join t_RecordCaseBack cb on
		c.id=cb.rf_idCase
				inner join t_CaseBack ct on
		cb.id=ct.rf_idRecordCaseBack and ct.TypePay=1				
group by c.rf_idMO,t1.unitCode			

			

select * from @t

insert @t
select CodeLPU,unitCode,RATE
from t_PlanOrders2011 where CodeLPU=@codeLPU

select * from @t
--select CodeLPU,unitCode,SUM(Rate)
--from @t
--group by CodeLPU,unitCode
select CodeLPU,unitCode,Rate from t_PlanOrders2011 where CodeLPU=@codeLPU

select *
from dbo.fn_PlanOrders(@codeLPU,@month,@year)
