use RegisterCases
go
--select * 
--from t_File f inner join t_RegistersCase r on
--		f.id=r.rf_idFiles
--where CodeM='254504'

--exec usp_RegisterCaseDelete 1009
declare @codeLPU char(56)='103001'
select CodeLPU,Vm,Vdm,Spred,unitName,u.unitCode
from dbo.fn_PlanOrders(@codeLPU,12,2011) p inner join vw_sprUnit u on
   	  p.UnitCode=u.unitCode
 
 
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
		r.ReportMonth>0 and r.ReportMonth<=12 and
		r.ReportYear=2011
				inner join t_RecordCaseBack cb on
		c.id=cb.rf_idCase
				inner join t_PatientBack p on
		cb.id=p.rf_idRecordCaseBack
				inner join vw_sprSMO s on
			p.rf_idSMO=s.smocod
				inner join t_CaseBack ct on
		cb.id=ct.rf_idRecordCaseBack and ct.TypePay=1				
group by c.rf_idMO,t1.unitCode		 

select CodeLPU,unitCode,SUM(Rate)
from t_PlanOrders2011 
where CodeLPU='103001' and MonthRate<=12
group by CodeLPU,unitCode