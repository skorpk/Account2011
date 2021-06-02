use RegisterCases
go
select * from vw_getIdFileNumber where CodeM='251008' and NumberRegister=12008 and ReportYear=2012


--select t1.rf_idFiles
--from(
--		select COUNT(distinct id) as TotalRow,rf_idFiles
--		from t_RefCasePatientDefine 		
--		where IsUnloadIntoSP_TK is null and rf_idFiles=3053
--		group by rf_idFiles
--	) t1 inner join (
--						select COUNT(distinct r.id) as DefineRow,rf_idFiles
--						from t_RefCasePatientDefine r inner join t_CasePatientDefineIteration i on
--								r.id=i.rf_idRefCaseIteration
--						where IsUnloadIntoSP_TK is null and rf_idFiles=3053
--						group by rf_idFiles	
--					) t2 on 
--			t1.rf_idFiles=t2.rf_idFiles
--			and t1.TotalRow=t2.DefineRow
			
select r.id,rf_idFiles
from t_RefCasePatientDefine r inner join t_CasePatientDefineIteration i on
								r.id=i.rf_idRefCaseIteration
where IsUnloadIntoSP_TK is null and rf_idFiles=3053
--group by rf_idFiles	

select distinct r.rf_idFiles,f.DateRegistration
from t_RefCasePatientDefine r inner join t_CaseDefineZP1 z on
			r.id=z.rf_idRefCaseIteration
							inner join PolicyRegister.dbo.ZP1 zp1 on							
			z.rf_idZP1=zp1.ID							
							inner join t_File f on
			r.rf_idFiles=f.id
where IsUnloadIntoSP_TK is null --and rf_idFiles=3053
		and f.DateRegistration>'20120118' and f.DateRegistration<'20120207 08:00:00'
order by f.DateRegistration


