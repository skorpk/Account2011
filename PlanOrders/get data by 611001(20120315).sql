select mes.*,mu.unitCode
from t_File f inner join t_RegistersCase a on
		f.id=a.rf_idFiles
				inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
				inner join t_Case c on
		r.id=c.rf_idRecordCase
				inner join t_MES mes on
		c.id=mes.rf_idCase
				inner join vw_sprMU mu on
		mes.MES=mu.MU
where f.CodeM='611001' and a.NumberRegister=14 and a.ReportYear=2012 and mes.MES='1.7.44'

select *
from dbo.fn_PlanOrders('611001',3,2012)

select c.rf_idMO
		,t1.unitCode
		,r.NumberRegister
		,r.PropertyNumberRegister		
		,SUM(case when m.IsChildTariff=1 then m.Quantity*t1.ChildUET else m.Quantity*t1.AdultUET end) as Quantity
from t_FileBack f inner join t_RegisterCaseBack r on
				f.id=r.rf_idFilesBack		
				and f.DateCreate<=GETDATE()
						  inner join t_RecordCaseBack cb on
				cb.rf_idRegisterCaseBack=r.id and
				r.ReportMonth>=1 and r.ReportMonth<=3 and
				r.ReportYear=2012
						inner join t_Case c on
				c.id=cb.rf_idCase
						inner join vw_MeduslugiMes m on
				c.id=m.rf_idCase and c.rf_idMO='611001'
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
group by c.rf_idMO,r.NumberRegister,r.PropertyNumberRegister,t1.unitCode
order by unitCode,r.NumberRegister

--select mes.*
--from t_Case c inner join t_MES mes on
--		c.id=mes.rf_idCase
--where c.GUID_Case='5AC6C68E-D1BE-A18C-0D06-8586D2FDF0AE'