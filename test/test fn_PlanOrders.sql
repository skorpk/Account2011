use RegisterCases
go
--delete from t_FileBack where rf_idFiles in ()
--delete from t_RefCasePatientDefine where id in (74)
--delete from t_File where id in (79)
--go

select id,FileNameHR,CountSluch from t_File

select CodeM,rc.ReportMonth
from t_RegistersCase rc inner join oms_nsi.dbo.vw_sprT001 v on
				rc.rf_idMO=v.mcod
select * from t_FileBack-- where rf_idFiles in (71,72)
-----------------------------------------------------------------

/*
declare @RecordCase as TVP_CasePatient,
			@idRecordCaseNext as TVP_CasePatient,
			@idFile int=74

--insert @RecordCase			
select * from tRecordCase1

insert @idRecordCaseNext
exec usp_DefineSMOIteration1_3 @RecordCase,@iteration=1,@id=@idFile*/

declare @month tinyint=11,
		@monthMax tinyint,
		@year smallint=2011,
		@codeLPU char(6)='601001'
select *
from dbo.fn_PlanOrders(@codeLPU,@month,@year)
--select @monthMax=case when t.MonthRate>@month then t.MonthRate else @month end
--from(
--		select isnull(MAX(rc.ReportMonth),@month) as MonthRate
--		from t_RegistersCase rc inner join oms_nsi.dbo.vw_sprT001 v on
--						rc.rf_idMO=v.mcod
--		where v.CodeM=@codeLPU and rc.ReportYear=@year
--		union all
--		select MAX(MonthRate) from t_PlanOrders2011 where CodeLPU=@codeLPU
--	) t
--select @monthMax




---------------------------------------------------------------------
