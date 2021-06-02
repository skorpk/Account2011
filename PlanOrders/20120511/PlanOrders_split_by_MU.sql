use RegisterCases
go
select c.rf_idMO
		,r.ReportMonth
		,m.MUCode
		,SUM(case when m.IsChildTariff=1 then m.Quantity*t1.ChildUET else m.Quantity*t1.AdultUET end) as Quantity
from t_FileBack f inner join t_RegisterCaseBack r on
				f.id=r.rf_idFilesBack		
				--and f.DateCreate<=@dateCreate
						  inner join t_RecordCaseBack cb on
				cb.rf_idRegisterCaseBack=r.id and
				r.ReportMonth>=1 and r.ReportMonth<=3 and
				r.ReportYear=2012
				and cb.TypePay=1
						inner join t_Case c on
				c.id=cb.rf_idCase
						inner join vw_MeduslugiMes m on
				c.id=m.rf_idCase 
				and c.rf_idMO='102605'
						inner join dbo.vw_sprMU t1 on
				m.MUCode=t1.MU			
				and t1.unitCode =3
						inner join (
									select rf_idRecordCaseBack,rf_idSMO 
									from t_PatientBack
									group by rf_idRecordCaseBack,rf_idSMO 
								   ) p on
				cb.id=p.rf_idRecordCaseBack
						inner join vw_sprSMO s on
					p.rf_idSMO=s.smocod						
group by c.rf_idMO,r.ReportMonth,m.MUCode
order by ReportMonth, MUCode