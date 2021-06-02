alter database AccountOMS set single_user with rollback immediate
go
use AccountOMS
go
alter table t_Meduslugi add id2 bigint identity(1,1)
go
create table #tMed
(
	rf_idCase bigint not null,
	id int not null,
	GUID_MU uniqueidentifier not null,
	rf_idMO char(6) not null,
	rf_idSubMO char(6) null,
	rf_idDepartmentMO int null,
	rf_idV002 smallint not null,
	IsChildTariff bit not null,
	DateHelpBegin date not null,
	DateHelpEnd date not null,
	DiagnosisCode char(10) not null,
	MUGroupCode tinyint,
	MUUnGroupCode tinyint,
	MUCode smallint not null,
	Quantity decimal(6,2) not null,
	Price decimal(15,2) not null,
	TotalPrice decimal(15,2) not null,
	rf_idV004 int not null,
	rf_idDoctor char(16) null,
	Comments nvarchar(250) null,
	id2 bigint
)
go

---------------------------------------------------------������� ������ �� �� ��������� �� rf_idCase,GUID_MU---------------------------------------------------------------------
truncate table #tMed
insert #tMed
select  m.rf_idCase,m.id ,m.GUID_MU,m.rf_idMO,m.rf_idSubMO,m.rf_idDepartmentMO,m.rf_idV002,m.IsChildTariff,m.DateHelpBegin,m.DateHelpEnd,m.DiagnosisCode
		,m.MUGroupCode,m.MUUnGroupCode,m.MUCode,m.Quantity,m.Price,m.TotalPrice,m.rf_idV004,m.rf_idDoctor,m.Comments,m.id2
from t_Meduslugi m inner join (
								select m.rf_idCase,m.GUID_MU
								from t_RegistersAccounts a inner join t_RecordCasePatient r on
										a.id=r.rf_idRegistersAccounts
										--and a.ReportYear=2012
														inner join t_Case c on
										r.id=c.rf_idRecordCasePatient
										--and c.rf_idMO='103001'
														inner join t_Meduslugi m on
										c.id=m.rf_idCase
								group by m.rf_idCase,m.GUID_MU
								having COUNT(*)>1
								) m2 on
				m.rf_idCase=m2.rf_idCase
				and m.GUID_MU=m2.GUID_MU
delete from t_Meduslugi where id2 in (
										select t1.id2
										from #tMed t1 inner join (
																select rf_idCase,GUID_MU,max(id) as id
																from #tMed
																group by rf_idCase,GUID_MU
															  ) t2 on
												t1.rf_idCase=t2.rf_idCase
												and t1.GUID_MU=t2.GUID_MU
												and t1.id=t2.id
										)
go

drop table #tMed
go
alter table t_Meduslugi drop column id2
go
alter database AccountOMS set multi_user