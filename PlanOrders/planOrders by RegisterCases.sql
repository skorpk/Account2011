use RegisterCases
go
select l.CodeM,l.NameS,u.unitCode,u.unitName,t.Quantity
from (
		select c.rf_idMO
				,t1.unitCode
				,SUM(case when m.IsChildTariff=1 then m.Quantity*t1.ChildUET else m.Quantity*t1.AdultUET end) as Quantity
		from t_Case c inner join t_Meduslugi m on
				c.id=m.rf_idCase 
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
						inner join (select rf_idRecordCaseBack,rf_idSMO 
									from t_PatientBack
									group by rf_idRecordCaseBack,rf_idSMO 
									) p on
				cb.id=p.rf_idRecordCaseBack
						inner join vw_sprSMO s on
					p.rf_idSMO=s.smocod
						inner join t_CaseBack ct on
				cb.id=ct.rf_idRecordCaseBack and ct.TypePay=1				
		group by c.rf_idMO,t1.unitCode	
	) t inner join vw_sprT001 l on
		t.rf_idMO=l.CodeM
			inner join RegisterCases.dbo.vw_sprUnit u on
		t.unitCode=u.unitCode
order by CodeM,unitCode