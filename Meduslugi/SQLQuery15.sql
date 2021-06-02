use RegisterCases
go
select c.rf_idMO
		,ab.NumberRegister
		,ab.PropertyNumberRegister
		,t1.unitCode
		,p.rf_idSMO		
		,sum(case when m.IsChildTariff=1 then m.Quantity*t1.ChildUET else m.Quantity*t1.AdultUET end) as Quantity
from t_Case c inner join (
							select rf_idCase,GUID_MU,MUCode,Quantity,IsChildTariff
							from t_Meduslugi
							group by rf_idCase,GUID_MU,MUCode,Quantity,IsChildTariff
						 ) m on
		c.id=m.rf_idCase 
		and c.rf_idMO='591001'
				inner join dbo.vw_sprMU t1 on
		rtrim(m.MUCode)=rtrim(t1.MU)
				inner join t_RecordCase rc on
		c.rf_idRecordCase=rc.id
				inner join t_RegistersCase r on
		rc.rf_idRegistersCase=r.id and
		r.ReportMonth>0 and r.ReportMonth<=12 and
		r.ReportYear=2011
		and r.NumberRegister=7
				inner join t_RecordCaseBack cb on
		c.id=cb.rf_idCase
				inner join (
							select rf_idRecordCaseBack,rf_idSMO 
							from t_PatientBack
							group by rf_idRecordCaseBack,rf_idSMO 
							) p on
		cb.id=p.rf_idRecordCaseBack
				left join vw_sprSMO s on
			p.rf_idSMO=s.smocod
			--and s.smocod='34002'
				inner join t_CaseBack ct on
		cb.id=ct.rf_idRecordCaseBack and ct.TypePay=1				
				inner join t_RegisterCaseBack ab on
		cb.rf_idRegisterCaseBack=ab.id
where unitCode=1
group by c.rf_idMO,ab.NumberRegister,ab.PropertyNumberRegister,t1.unitCode,p.rf_idSMO
order by NumberRegister,unitCode
go

use AccountOMS
go
select c.rf_idMO
		,r.NumberRegister
		,r.PrefixNumberRegister
		,r.PropertyNumberRegister
		,r.Letter
		,t1.unitCode
		,sum(case when m.IsChildTariff=1 then m.Quantity*t1.ChildUET else m.Quantity*t1.AdultUET end) as Quantity
from t_Case c inner join (
							select rf_idCase,GUID_MU,MUCode,MUGroupCode,MUUnGroupCode,Quantity,IsChildTariff
							from t_Meduslugi
							group by rf_idCase,GUID_MU,MUCode,MUGroupCode,MUUnGroupCode,Quantity,IsChildTariff
						 ) m on
				c.id=m.rf_idCase 
				and c.rf_idMO='591001'
						inner join dbo.vw_sprMU t1 on
				m.MUGroupCode=t1.MUGroupCode
				and m.MUUnGroupCode=t1.MUUnGroupCode
				and m.MUCode=t1.MUCode
						inner join t_RecordCasePatient rc on
				c.rf_idRecordCasePatient=rc.id
						inner join t_RegistersAccounts r on
				rc.rf_idRegistersAccounts=r.id and
				r.ReportMonth>0 and r.ReportMonth<=12 and
				r.ReportYear=2011
				and r.NumberRegister=7
				--and r.PrefixNumberRegister='34002'
				--and r.PropertyNumberRegister=1
						inner join (select * from vw_sprSMO where smocod<>'34') s on
				r.rf_idSMO=s.smocod				
where unitCode=1
group by c.rf_idMO,r.NumberRegister
		,r.PrefixNumberRegister,r.PropertyNumberRegister,r.Letter
		,t1.unitCode		
order by NumberRegister,unitCode

