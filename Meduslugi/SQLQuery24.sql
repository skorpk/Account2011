
use AccountOMS
go
declare @t as table (GUID_MU uniqueidentifier)
insert @t
select m.GUID_MU
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
				and r.PrefixNumberRegister='34001'
				--and r.PropertyNumberRegister=1
						inner join (select * from vw_sprSMO where smocod<>'34') s on
				r.rf_idSMO=s.smocod				
where unitCode=1
--group by c.rf_idMO,r.NumberRegister,r.PrefixNumberRegister,r.PropertyNumberRegister,r.Letter,t1.unitCode		
order by NumberRegister,unitCode

delete from AccountOMS.dbo.t_Case 
where GUID_Case in (
					select distinct c.GUID_Case
					from RegisterCases.dbo.t_Meduslugi m inner join RegisterCases.dbo.t_Case c on
												m.rf_idCase=c.id
														inner join RegisterCases.dbo.t_RecordCaseBack rb on
														c.id=rb.rf_idCase
																inner join RegisterCases.dbo.t_CaseBack cb on
														rb.id=cb.rf_idRecordCaseBack	
																inner join RegisterCases.dbo.t_RegisterCaseBack ab on
														rb.rf_idRegisterCaseBack=ab.id
																inner join RegisterCases.dbo.t_PatientBack p on
														rb.id=p.rf_idRecordCaseBack
																inner join @t t on
														m.GUID_MU=t.GUID_MU																
					where cb.TypePay=2
					)