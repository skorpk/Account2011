USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_RunProcessControl]    Script Date: 15.08.2017 10:13:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[usp_RunProcessControl]
			@CaseDefined TVP_CasePatient READONLY,		
			@idFile int
	
as
declare @tError as table(rf_idCase bigint,ErrorNumber smallint)

declare @month tinyint,
		@year smallint,
		@codeLPU char(6)
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile
------------------------------------------------------------------
IF EXISTS(SELECT * FROM oms_nsi.dbo.vw_sprT001 WHERE CodeM=@codeLPU AND pfs=1 )
BEGIN
	insert @tError
	select c.id,589
	from @CaseDefined cd inner join t_Case c on
					cd.rf_idCase=c.id
					and c.rf_idV006=4					
						inner join t_Meduslugi m on
					c.id=m.rf_idCase
						left join vw_sprMUSplitByGroup mu on
					m.MUCode=mu.MU
					and mu.MUGroupCode=71
					and mu.MUUnGroupCode IN (1 ,3) 						 
	where mu.MUCode is null group by c.id
END
----проверка на дулированность случая по пациенту в РС F от 15/08/2017
CREATE TABLE #tab(rf_idCase bigint,IdStep tinyint)
--собираем данные по файлу
--данные по застрахованным определенным на 1-ом этапе
INSERT #tab( rf_idCase, IdStep )
SELECT rf.rf_idCase,1
FROM dbo.t_RefCasePatientDefine rf INNER JOIN dbo.t_CasePatientDefineIteration i ON
				rf.id=i.rf_idRefCaseIteration		          
WHERE rf.rf_idFiles=@idFile AND i.rf_idIteration=1				                          

---для данных вернувшихся из ФФОМС
INSERT #tab( rf_idCase, IdStep )
SELECT rf.rf_idCase,2
FROM dbo.t_RefCasePatientDefine rf INNER JOIN dbo.t_CasePatientDefineIteration i ON
				rf.id=i.rf_idRefCaseIteration
								INNER JOIN @CaseDefined cd ON
				rf.rf_idCase=cd.rf_idCase                              
WHERE rf.rf_idFiles=@idFile AND i.rf_idIteration>1				                          

------------------------------------------------------------------
----проверка на дулированность случая по пациенту в РС F
IF EXISTS(SELECT 1 FROM t_File WHERE id=@idFile AND TypeFile='F')
BEGIN
	;WITH cteDouble
	AS
	(  
	SELECT ROW_NUMBER() OVER(PARTITION BY ENP,d.TypeDisp ORDER BY cd.IdStep,c.idRecordCase ASC) AS idRow, c.id,c.idRecordCase,pb.ENP,d.TypeDisp,cd.IdStep
	from #tab cd inner join t_Case c on
					cd.rf_idCase=c.id	
						 INNER JOIN dbo.t_RecordCaseBack rb ON
					c.id=rb.rf_idCase
						 left JOIN dbo.t_PatientBack pb ON
					rb.id=pb.rf_idRecordCaseBack
						INNER JOIN dbo.t_DispInfo d ON
					c.id=d.rf_idCase                    
	WHERE d.TypeDisp IN('ДВ1','ДВ2','ОПВ')   
	)
	insert @tError 
	SELECT distinct rf_idCase,71 FROM cteDouble WHERE idRow>1
						                        
END 	
DROP TABLE #tab				                        
----проверка на дулированность случая по пациенту в РС F от 15/08/2017
------------------------------------------------------------------
--Проверка N: проверка плана-заказа. Всегда должна быть последней
--внес корректировки с тем что некоторые МО просят сдать данные за предыдущий отчетный год

create table #tmpPlan
(
	CodeLPU varchar(6),
	UnitCode int,
	Vm DECIMAL(11,2),
	Vdm DECIMAL(11,2),
	Spred decimal(11,2),
	[month] tinyint
)
exec usp_PlanOrders @CodeLPU,@month,@year

if NOT EXISTS(select * from t_LPUPlanOrdersDisabled where CodeM=@codeLPU and ReportYear=@year and BeforeDate>=GETDATE())
begin
	declare @t1 as table(rf_idCase bigint,idRecordCase int,Quantity decimal(11,2),unitCode int,TotalRest decimal(11,2))
		------------------------------------------------------

	insert @t1(rf_idCase,Quantity,unitCode,idRecordCase)
	select id,Quantity,unitCode,idRecordCase 
	from vw_dataPlanOrder c inner join @CaseDefined cd on
				c.id=cd.rf_idCase
	where rf_idFiles=@idFile	
	order by idRecordCase asc
		
		--использую курсор т.к. на данный момент это проще всего, но его потом следует заменить
		declare cPlan cursor for
			select f.UnitCode,f.Vdm,f.Vm,f.Spred,f.Vdm+f.Vm-f.Spred from #tmpPlan f
			declare @unit int,@vdm decimal(11,2), @vm decimal(11,2), @spred decimal(11,2),@totalPlan decimal(11,2)
		open cPlan
		fetch next from cPlan into @unit,@vdm,@vm,@spred,@totalPlan
		while @@FETCH_STATUS = 0
		begin					
			update @t1 set @totalPlan=TotalRest=@totalPlan-Quantity where unitCode=@unit
			
			fetch next from cPlan into @unit,@vdm,@vm,@spred,@totalPlan
		end
		close cPlan
		deallocate cPlan

		insert @tError	select distinct rf_idCase,62 from @t1 where TotalRest<0
end

begin transaction
begin try
	insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
	select ErrorNumber,@idFile,rf_idCase from @tError
end try
begin catch
if @@TRANCOUNT>0
	select ERROR_MESSAGE()
	rollback transaction
end catch
if @@TRANCOUNT>0
	drop table #tmpPlan
	commit transaction
	
