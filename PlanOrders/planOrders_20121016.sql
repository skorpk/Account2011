USE AccountOMS
go
SET NOCOUNT ON
select c.rf_idMO
				,t1.unitCode
				,t1.unitName
				,SUM(case when m.IsChildTariff=1 then m.Quantity*t1.ChildUET else m.Quantity*t1.AdultUET end) as Quantity
from t_File f inner join t_RegistersAccounts r on
				f.id=r.rf_idFiles
				and f.DateRegistration>='20120101'
				and f.DateRegistration<'20120930 23:59:59'								
				and f.CodeM='551001'
						  inner join t_RecordCasePatient cb on
				cb.rf_idRegistersAccounts=r.id and
				r.ReportMonth>=1 and r.ReportMonth<10 and
				r.ReportYear=2012
						inner join t_Case c on
				c.rf_idRecordCasePatient=cb.id
						inner join vw_MeduslugiMes m on
				c.id=m.rf_idCase and c.rf_idMO='551001'
						inner join dbo.vw_sprMU t1 on
				m.MUCode=t1.MU			
				and t1.unitCode is not null						
						inner join vw_sprSMO s on
					r.rf_idSMO=s.smocod						
					and s.smocod<>'34'
group by c.rf_idMO,t1.unitCode,t1.unitName

go