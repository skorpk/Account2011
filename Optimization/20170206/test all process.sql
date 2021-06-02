USE RegisterCases
GO
USE RegisterCases
go
declare @idFile INT=99775

SELECT * FROM dbo.vw_getIdFileNumber WHERE id=@idFile

--exec usp_RunTestsDefineSMOCreateSPTK @idFile
begin try
declare @RecordCase as TVP_CasePatient,
		@idRecordCaseNext as TVP_CasePatient,
		@CaseDefined as TVP_CasePatient
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;		
-------------------------------------------------
DECLARE  @dtStart TIME=GETDATE()
--добавить здесь обработку записей которые были откинуты в ошибки при ТК1( хранимая процедура usp_RunFirstProcessControl)
-- данные записи не должны попадать в процедуру определения страховой принадлежности
--но эти записи должны включаться в реестр СП и ТК с кодом ошибки 
	exec usp_RunFirstProcessControl @idFile
	SELECT datediff(ss,@dtStart,CAST(GETDATE() AS TIME))
	SELECT @dtStart=CAST(GETDATE() AS TIME)
		
	insert @RecordCase	
	select c.id as rf_idCase,p.id as rf_idPatient 
	from (
		  select r.id,r.ID_Patient
		  from t_RegistersCase a inner join t_RecordCase r on
						a.id=r.rf_idRegistersCase
						and a.rf_idFiles=@idFile
		 ) rc inner join t_Case c on
				rc.id=c.rf_idRecordCase							
							  inner join (
											select r.rf_idRecordCase,p.id,p.rf_idFiles,p.ID_Patient,p.Fam,p.Im,p.Ot,p.rf_idV005,p.BirthDay,p.BirthPlace
											from t_RegisterPatient p left join t_RefRegisterPatientRecordCase r on
														p.id=r.rf_idRegisterPatient
											where p.rf_idFiles=@idFile
										) p on
					rc.id=p.rf_idRecordCase and
					rc.ID_Patient=p.ID_Patient
								left join t_ErrorProcessControl e on
					c.id=e.rf_idCase
					and e.rf_idFile=@idFile
			where e.rf_idCase is null
				
-----изменения от 22.01.2012-------------------------------------------------------------------			
	
--определение сстраховой принадлежности в РС ЕРЗ на 1-ой итерации.
--возвращает id ненайденых пациентов(по которым не определена страховая принадлежность)
--данные необходимо для того что бы определить страховую принадлежность на ЦС ЕРЗ на 2-ой итерации
--добавил в качестве параметра передачу id файла входящего
	
	
	insert @idRecordCaseNext exec usp_DefineSMOIteration1_3 @RecordCase,@iteration=1,@id=@idFile
	
	SELECT datediff(ss,@dtStart,CAST(GETDATE() AS TIME))
	SELECT @dtStart=CAST(GETDATE() AS TIME)
		
--параметры которые подаются в процедуру, выполняющую технологический контроль
	insert @CaseDefined(rf_idCase,ID_Patient)
	select t.rf_idCase,t.ID_Patient
	from @RecordCase t left join @idRecordCaseNext t1 on
				t.rf_idCase=t1.rf_idCase and 
				t.ID_Patient=t1.ID_Patient
	where t1.rf_idCase is null
	
	if EXISTS(
					select * from @CaseDefined
					union all
					select c.id,null --т.к. ID_Patient не нужен
					from t_RegistersCase a inner join t_RecordCase r on
								a.id=r.rf_idRegistersCase
								and a.rf_idFiles=@idFile								
											inner join t_Case c on
								r.id=c.rf_idRecordCase
											left join t_RefCasePatientDefine rd on
								c.id=rd.rf_idCase
								and rd.rf_idFiles=@idFile
					where rd.id is null
				)
	begin	
		if EXISTS(select * from @CaseDefined)
		begin
		--процедура выполняющая тех.контроль, определение плана заказов и т.д.
			exec usp_RunProcessControl @CaseDefined,@idFile
		end
		--раскладываем данные по таблицам для формирования реестров СП и ТК
		declare @property tinyint
		
		
		--расчитываем номер СП и ТК. Если страховая принадлежность определена сразу то 0 иначе 1
		if exists(select *
				  from t_RefCasePatientDefine t1 left join t_CasePatientDefineIteration t2 on
							t1.id=t2.rf_idRefCaseIteration			
				  where t1.rf_idFiles=@idFile and t2.rf_idRefCaseIteration is null
				)
		begin
			set @property=1
		end
		else
		begin 
			set @property=0
		end
		
		declare @tReturnVal as table(idFileBack int)
		
		---добавляем данные в @CaseDefined которые были откинуты на ТК1
		insert @CaseDefined(rf_idCase,ID_Patient)
		select c.id,null --т.к. ID_Patient не нужен
		from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile								
								inner join t_Case c on
					r.id=c.rf_idRecordCase
								left join t_RefCasePatientDefine rd on
					c.id=rd.rf_idCase
					and rd.rf_idFiles=@idFile
		where rd.id is null
	
		insert @tReturnVal
		exec usp_FillBackTables @CaseDefined,@idFile,@property
		
--закончить данную обработку
		
		declare @idFileBack int
		select @idFileBack=idFileBack from @tReturnVal
		
		-------------------------возвращаем данные для формирования реестра СП и ТК--------------------------------
		exec usp_RegisterSP_TK @idFileBack
	end	
	
	--------------------------------данные для отчета по плану заказов---------------------------------------------
	declare @month tinyint,
		@year smallint,
		@codeLPU char(6)
		
	if @idFileBack is not null		
	begin
		select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear
		from t_FileBack f inner join t_RegisterCaseBack rc on
					f.id=rc.rf_idFilesBack
							inner join oms_nsi.dbo.vw_sprT001 v on
					f.CodeM=v.CodeM		
		where f.id=@idFileBack
		
		create table #tmpPlan
		(
			CodeLPU varchar(6),
			UnitCode int,
			Vm int,
			Vdm int,
			Spred decimal(11,2),
			[month] tinyint
		)
		EXEC dbo.usp_PlanOrders @codeLPU,@month,@year
		
		insert t_PlanOrdersReport(rf_idFile,rf_idFileBack,CodeLPU,UnitCode,Vm,Vdm,Spred,MonthReport,YearReport)
		select @idFile,@idFileBack,f.CodeLPU,f.UnitCode,f.Vm,f.Vdm,f.Spred,@month,@year
		FROM #tmpPlan f
		
		DROP TABLE #tmpPlan
		
		--insert t_PlanOrdersReport(rf_idFile,rf_idFileBack,CodeLPU,UnitCode,Vm,Vdm,Spred,MonthReport,YearReport)
		--select @idFile,@idFileBack,f.CodeLPU,f.UnitCode,f.Vm,f.Vdm,f.Spred,@month,@year
		--FROM dbo.fn_PlanOrders(@codeLPU,@month,@year) f
	end
	------------------------------------------------------------------------------------------------------------------	
	
	select @idFile,@idFileBack
		
	declare @fileName varchar(26)
	select @fileName=rtrim(FileNameHR) from t_File where id=@idFile
	
--определение страховой принадлежности на 2 и 4 итерации.

	if EXISTS(select * from @idRecordCaseNext)
	begin
		exec usp_DefineSMOIteration2_4 @idFile,2,@fileName
	end
	--если все прошло хорошо 
	select 'Good'
	
end try
begin catch
select ERROR_MESSAGE()
if @@TRANCOUNT>0
	rollback transaction
goto Exit1
----при ошибке производим откат данных 
--if isnull(@idFile,0)<>0
--begin
--	exec usp_RegisterCaseDelete @idFile
--	select 'Error'
--end
end catch
Exit1:
GO