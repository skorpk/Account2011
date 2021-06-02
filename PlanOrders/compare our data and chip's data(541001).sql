use RegisterCases
go
declare @codeLPU char(6)='541001'

select c.rf_idMO
		,t1.unitCode
		,r.NumberRegister
		,r.PropertyNumberRegister
		,r.ReportMonth
		,cast(SUM(case when m.IsChildTariff=1 then m.Quantity*t1.ChildUET else m.Quantity*t1.AdultUET end) as money) as Quantity
from t_FileBack f inner join t_RegisterCaseBack r on
		f.id=r.rf_idFilesBack		
				  inner join t_RecordCaseBack cb on
		cb.rf_idRegisterCaseBack=r.id and
		r.ReportMonth>=1 and r.ReportMonth<=3 and
		r.ReportYear=2012
				inner join t_Case c on
		c.id=cb.rf_idCase
				inner join vw_MeduslugiMes m on
		c.id=m.rf_idCase and c.rf_idMO=@codeLPU
				inner join dbo.vw_sprMU t1 on
		m.MUCode=t1.MU			
		and t1.unitCode is not null
				inner join (
							select rf_idRecordCaseBack,rf_idSMO 
							from t_PatientBack
							group by rf_idRecordCaseBack,rf_idSMO 
							) p on
		cb.id=p.rf_idRecordCaseBack
				inner join vw_sprSMO s on
			p.rf_idSMO=s.smocod
				inner join t_CaseBack ct on
		cb.id=ct.rf_idRecordCaseBack and ct.TypePay=1				
where f.DateCreate<=GETDATE()
group by c.rf_idMO,t1.unitCode,r.NumberRegister,r.PropertyNumberRegister,r.ReportMonth
order by ReportMonth,NumberRegister,PropertyNumberRegister