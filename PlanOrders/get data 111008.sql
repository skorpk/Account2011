use RegisterCases
go
declare @month tinyint=1,
		@year smallint=2012		
		--@codeLPU char(6)='111008'
		
declare @codeLPU as table(code char(6))
insert @codeLPU values('103001')

		
select c.rf_idMO
		,t1.unitName
		,c.GUID_Case
		,m.MUCode
		,cast(rb.NumberRegister as VARCHAR(10))+'-'+cast(rb.PropertyNumberRegister as VARCHAR(10))
		,cast(SUM(case when m.IsChildTariff=1 then m.Quantity*t1.ChildUET else m.Quantity*t1.AdultUET end) as money) as Quantity
from t_Case c inner join (select distinct rf_idCase,MUCode,IsChildTariff,Quantity from t_Meduslugi) m on
		c.id=m.rf_idCase and c.rf_idMO in (select code from @codeLPU)
				inner join dbo.vw_sprMU t1 on
		m.MUCode=t1.MU
		and t1.unitCode=1
				inner join t_RecordCase rc on
		c.rf_idRecordCase=rc.id
				inner join t_RegistersCase r on
		rc.rf_idRegistersCase=r.id and
		r.ReportMonth>0 and r.ReportMonth<=@month and
		r.ReportYear=@year		
				inner join t_RecordCaseBack cb on
		c.id=cb.rf_idCase
				inner join t_RegisterCaseBack rb on
		cb.rf_idRegisterCaseBack=rb.id
		and rb.NumberRegister =1
		--and rb.PropertyNumberRegister=1
				inner join t_PatientBack p on
		cb.id=p.rf_idRecordCaseBack
				inner join vw_sprSMO s on
			p.rf_idSMO=s.smocod
				inner join t_CaseBack ct on
		cb.id=ct.rf_idRecordCaseBack and ct.TypePay=1							
group by c.rf_idMO,r.NumberRegister,t1.unitName,c.GUID_Case
		,m.MUCode,cast(rb.NumberRegister as VARCHAR(10))+'-'+cast(rb.PropertyNumberRegister as VARCHAR(10))
order by 1,3