use RegisterCases
go
declare @codeLPU varchar(6)='171006',
		@month tinyint=12,
		@year smallint=2011

select *
from dbo.fn_PlanOrders(@codeLPU,@month,@year)

select c.rf_idMO
		,t1.unitCode
		,SUM(case when m.IsChildTariff=1 then m.Quantity*t1.ChildUET else m.Quantity*t1.AdultUET end) as Quantity
from t_Case c inner join t_Meduslugi m on
		c.id=m.rf_idCase and c.rf_idMO=@codeLPU
				inner join dbo.vw_sprMU t1 on
		m.MUCode=t1.MU
				inner join t_RecordCase rc on
		c.rf_idRecordCase=rc.id
				inner join t_RegistersCase r on
		rc.rf_idRegistersCase=r.id and
		r.ReportMonth>0 and r.ReportMonth<=@month and
		r.ReportYear=@year
		and r.NumberRegister in (7)
				inner join t_RecordCaseBack cb on
		c.id=cb.rf_idCase
				inner join t_PatientBack p on
		cb.id=p.rf_idRecordCaseBack
				inner join vw_sprSMO s on
			p.rf_idSMO=s.smocod
				inner join t_CaseBack ct on
		cb.id=ct.rf_idRecordCaseBack and ct.TypePay=1
group by c.rf_idMO,t1.unitCode	
order by 2	

declare @number varchar(1000)=''
select @number=@number+','+PrefixNumberRegister+'-'+CAST(NumberRegister as varchar(6))+'-'+CAST(PropertyNumberRegister as CHAR(1))+ISNULL(Letter,'')
from AccountOMS.dbo.t_File f inner join AccountOMS.dbo.t_RegistersAccounts a on
			f.id=a.rf_idFiles
			and f.CodeM=@codeLPU
where a.ReportMonth>0 and a.ReportMonth<=@month  and NumberRegister in (7)

select @number
