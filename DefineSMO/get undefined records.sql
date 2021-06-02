use RegisterCases
go
---записи на которые не было ответа и ‘‘‘ќћ—
select distinct f.*,'exec usp_DefineSMOIteration2_4Repeat '+cast(f.id as varchar(8))
from vw_getIdFileNumber f inner join t_RefCasePatientDefine d on
		f.id=d.rf_idFiles
		and f.ReportYear=2012 and f.DateRegistration<DATEADD(DD,-4, GETDATE())
		and d.IsUnloadIntoSP_TK is null
						inner join t_CaseDefineZP1 z on
		d.id=z.rf_idRefCaseIteration
						inner join PolicyRegister.dbo.ZP1 zp1 on
		z.rf_idZP1=zp1.id
where zp1.REPL is null

select distinct f.*
from vw_getIdFileNumber f left join t_RefCasePatientDefine d on
		f.id=d.rf_idFiles		
where d.rf_idFiles is null and f.ReportYear=2012 and f.DateRegistration<'20120319'