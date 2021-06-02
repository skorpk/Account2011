use AccountOMS
go
select *
from (
	select c.GUID_Case,m.GUID_MU,m.Quantity
	from AccountOMS.dbo.t_RegistersAccounts a inner join AccountOMS.dbo.t_RecordCasePatient r on
					a.id=r.rf_idRegistersAccounts
					and a.ReportYear=2011
											inner join AccountOMS.dbo.t_Case c on
					r.id=c.rf_idRecordCasePatient
					and c.rf_idMO='591001'
											inner join AccountOMS.dbo.t_Meduslugi m on
					c.id=m.rf_idCase
	) m left join (
						select c.GUID_Case,m.GUID_MU,m.Quantity
						from RegisterCases.dbo.t_RegistersCase a inner join RegisterCases.dbo.t_RecordCase r on
										a.id=r.rf_idRegistersCase
										and a.ReportYear=2011
																inner join RegisterCases.dbo.t_Case c on
										r.id=c.rf_idRecordCase
										and c.rf_idMO='591001'
																inner join RegisterCases.dbo.t_Meduslugi m on
										c.id=m.rf_idCase
					) m1 on m.GUID_Case=m.GUID_Case
							and m.GUID_MU=m1.GUID_MU
where m1.GUID_Case is null

select m1.GUID_MU,m1.Quantity1,m2.Quantity2
from (
		select c.GUID_Case,m.GUID_MU,SUM(Quantity) as Quantity1,COUNT(*) as CountRows1
		from AccountOMS.dbo.t_RegistersAccounts a inner join AccountOMS.dbo.t_RecordCasePatient r on
						a.id=r.rf_idRegistersAccounts
						and a.ReportYear=2011
													inner join AccountOMS.dbo.t_Case c on
							r.id=c.rf_idRecordCasePatient
							and c.rf_idMO='591001'
													inner join AccountOMS.dbo.t_Meduslugi m on
							c.id=m.rf_idCase
		group by c.GUID_Case,m.GUID_MU
	) m1 inner join (
						select c.GUID_Case,m.GUID_MU,SUM(Quantity) as Quantity2,COUNT(*) as CountRows2
						from RegisterCases.dbo.t_RegistersCase a inner join RegisterCases.dbo.t_RecordCase r on
										a.id=r.rf_idRegistersCase
										and a.ReportYear=2011
																inner join RegisterCases.dbo.t_Case c on
										r.id=c.rf_idRecordCase
										and c.rf_idMO='591001'
																inner join RegisterCases.dbo.t_Meduslugi m on
										c.id=m.rf_idCase
						group by c.GUID_Case,m.GUID_MU
					) m2 on m1.GUID_Case=m2.GUID_Case and m1.GUID_MU=m2.GUID_MU
where m1.Quantity1<>m2.Quantity2
											
