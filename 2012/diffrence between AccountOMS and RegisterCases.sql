select a.*
from RegisterCases.dbo.vw_getIdFileNumber r right join AccountOMS.dbo.vw_getIdFileNumber a on
				r.CodeM=a.CodeM
				and r.NumberRegister=a.NumberRegister
				and r.ReportYear=a.ReportYear
where r.id is null