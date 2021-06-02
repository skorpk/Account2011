use RegisterCases
go
--------------------------------------------------------------------------------------------------------------
if OBJECT_ID('usp_FillBackTablesAfterAllIteration',N'P') is not null
	drop proc usp_FillBackTablesAfterAllIteration
go			
--подаем id файла реестра сведений по котором закончена определения страховой принадлежности
--запуск производится только в том случае если по всем случаям присутствет запись в t_CasePatientDefineIteration
create proc usp_FillBackTablesAfterAllIteration
			@idFile int
as
if NOT EXISTS(
				select * from vw_getFileBack v where v.rf_idFiles=@idFile and v.PropertyNumberRegister=0
				union all
				select * from vw_getFileBack v where v.rf_idFiles=@idFile and v.PropertyNumberRegister=2
			 )
begin
		declare @property tinyint=2

		declare @fileName varchar(29),
				@idFileBack int,
				@idRegisterCaseBack int
		declare @idRecordCaseBack as table(rf_idRecordCaseBack int,rf_idCase bigint)

		--имя реестра СП и ТК
		select @fileName=dbo.fn_GetFileNameBack(@idFile)
		INSERT dbo.t_FileBackNumberOrder( FILENAMEBack) VALUES(@fileName)
		--временная таблица для того что бы не было двойных записей по пациентам
		--данные индекс будит вдальнейшем висеть на таблице t_PatientBack, сейчас пока не вычестил двойников из нее.
		CREATE TABLE #PatientBack
		(
			rf_idRecordCaseBack int NOT NULL,
			rf_idF008 tinyint NOT NULL,
			SeriaPolis varchar(10) NULL,
			NumberPolis varchar(20) NOT NULL,
			rf_idSMO char(5) NOT NULL,
			OKATO char(5) NULL,
			AttachLPU VARCHAR(6)
		)

		create unique nonclustered index UQ_IDRecordCaseBack on #PatientBack(rf_idRecordCaseBack) with IGNORE_DUP_KEY


		declare @CaseDefined TVP_CasePatient,--общая
				@CaseDefined1 TVP_CasePatient,--для местных
				@CaseDefined2 TVP_CasePatient --для иногородних

		insert @CaseDefined(rf_idCase,ID_Patient)
		select rf_idCase,rf_idRegisterPatient
		from t_RefCasePatientDefine
		where rf_idFiles=@idFile and (IsUnloadIntoSP_TK is null)
		--не иногородние
		insert @CaseDefined1(rf_idCase,ID_Patient)
		select rf.rf_idCase,rf.rf_idRegisterPatient
		from (
				select rf.rf_idCase,rf.rf_idRegisterPatient
				from t_RefCasePatientDefine rf inner join t_CaseDefineZP1Found c on
							rf.id=c.rf_idRefCaseIteration
							and c.OKATO ='18000'		
										inner join t_CasePatientDefineIteration i on
							rf.id=i.rf_idRefCaseIteration
							and i.rf_idIteration in (2,4)			  
				where rf.rf_idFiles=@idFile and (rf.IsUnloadIntoSP_TK is null)
				union all
				select rf.rf_idCase,rf.rf_idRegisterPatient
				from t_RefCasePatientDefine rf inner join t_CasePatientDefineIteration i on
							rf.id=i.rf_idRefCaseIteration
							and i.rf_idIteration in (3)			  
				where rf.rf_idFiles=@idFile and (rf.IsUnloadIntoSP_TK is null)
				group by rf.rf_idCase,rf.rf_idRegisterPatient
			 ) rf

		---иногородние
		--сюда необходимо добавить выборку иногородних 05.02.2012
		insert @CaseDefined2(rf_idCase,ID_Patient)
		select rf.rf_idCase,rf.rf_idRegisterPatient
		from t_RefCasePatientDefine rf inner join t_CaseDefineZP1Found c on
					rf.id=c.rf_idRefCaseIteration
					and c.OKATO is not null
					and c.OKATO!='18000'									  
		where rf.rf_idFiles=@idFile and (rf.IsUnloadIntoSP_TK is null)
		--заполняем таблицу для иногородних по тем у кого не определена страховая принадлежность, но есть ОКАТО не волгоградской области
		insert @CaseDefined2(rf_idCase,ID_Patient)
		select rf.rf_idCase,rf.rf_idRegisterPatient
		from t_RefCasePatientDefine rf inner join t_CaseDefineZP1Found c on
					rf.id=c.rf_idRefCaseIteration
					and c.OGRN_SMO is null	
										inner join t_Case c1 on
					rf.rf_idCase=c1.id											  
										inner join t_RecordCase r on
					c1.rf_idRecordCase=r.id
										inner join t_PatientSMO p on
					r.id=p.ref_idRecordCase
					and p.OKATO!='18000' 
					and p.OKATO is not null
		where rf.rf_idFiles=@idFile and (rf.IsUnloadIntoSP_TK is null)



		--производим технологический контроль для застрахованных в других территориях
		--убрал проверку 28.03.2012 т.к. все проверки реализованный на ТК1
		--exec usp_RunProcessControl2 @CaseDefined2,@idFile

		begin transaction T1
		begin try
		--записи по каторым не была определена страховая пр инадлежность. делаем пометку в таблице ошибок с номером 57
		--сюда необходимо добавить выборку иногородних 05.02.2012 что бы они не попадали в ошибки
			insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
			select 57,@idFile,c1.id
			from @CaseDefined cd inner join t_RefCasePatientDefine rf on
						cd.rf_idCase=rf.rf_idCase
								  inner join t_CaseDefineZP1Found c on
						rf.id=c.rf_idRefCaseIteration
								  inner join t_CasePatientDefineIteration i on
						rf.id=i.rf_idRefCaseIteration
						and i.rf_idIteration =4 --ошибка 57 может быть определена только на 4 шаге
									inner join t_Case c1 on
						cd.rf_idCase=c1.id
									inner join t_RecordCase rc on
						c1.rf_idRecordCase=rc.id
									inner join t_RegistersCase reg on
						rc.rf_idRegistersCase=reg.id
									left join @CaseDefined2 cd2 on
						cd.rf_idCase=cd.rf_idCase
						and cd.ID_Patient=cd2.ID_Patient					
			where (c.OGRN_SMO is null) and (c.NPolcy is null) and (cd2.rf_idCase is null)
			group by c1.id
			
			--производим технологический контроль для застрахованных в Волгоградской области
			if(select @@SERVERNAME)!='TSERVER'
			begin
				--проверка услуг скорой помощи для иногородних.
				IF EXISTS(SELECT * 
						  FROM dbo.vw_getIdFileNumber f INNER JOIN OMS_NSI.dbo.vw_sprT001 l ON
										f.CodeM=l.CodeM
						  WHERE f.id=@idFile AND l.pfs=1
						  )
				BEGIN		  
				---------------------------2012-12-20---------------------------------------
					insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
					select 589,@idFile,c.id
					from @CaseDefined2 cd inner join t_Case c on
									cd.rf_idCase=c.id
									and c.rf_idV006=4									
										inner join t_Meduslugi m on
									c.id=m.rf_idCase
										left join vw_sprMUSplitByGroup mu on
									m.MUCode=mu.MU
									and mu.MUGroupCode=71
									and mu.MUUnGroupCode=2
					where mu.MUCode is null group by c.id
				END		
				------------------------------------------------------------------
				/*
				Ошибка по счетам с литерами O,R,F,V,U. Если застрахованный является нашим, то надо проверять в таблице t_RefCaseAttachLPUItearion2. Для
				определения код МО прикрепления. Если случай там за фиксированн, то не попадает в 513 ошибку.
				*/
				-------------------------2014-02-28-----------------------------------------
				insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
				SELECT 513,@idFile,r.rf_idCase
				FROM (
						select rf.rf_idCase,rf.rf_idRegisterPatient
						from t_RefCasePatientDefine rf inner join t_CaseDefineZP1Found c on
									rf.id=c.rf_idRefCaseIteration
									and c.OKATO ='18000'		
												inner join t_CasePatientDefineIteration i on
									rf.id=i.rf_idRefCaseIteration
									and i.rf_idIteration in (2,4)			  
						where rf.rf_idFiles=@idFile and (rf.IsUnloadIntoSP_TK is null)
					 ) r inner join t_Case c on
							r.rf_idCase=c.id
										INNER JOIN dbo.t_Meduslugi m ON
							c.id=m.rf_idCase
										INNER JOIN (SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='O'
													UNION ALL
													SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='R'
													UNION ALL
													SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='F'
													UNION ALL
													SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='V'
													UNION ALL
													SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='U') l ON
							m.MUCode=l.MU
				WHERE m.Price>0 AND NOT EXISTS(SELECT * FROM t_RefCaseAttachLPUItearion2 WHERE rf_idFiles=@idFile AND rf_idCase=r.rf_idCase AND AttachLPU=c.rf_idMO)
				
				insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
				SELECT 513,@idFile,r.rf_idCase
				FROM (
						select rf.rf_idCase,rf.rf_idRegisterPatient
						from t_RefCasePatientDefine rf inner join t_CaseDefineZP1Found c on
									rf.id=c.rf_idRefCaseIteration
									and c.OKATO ='18000'		
												inner join t_CasePatientDefineIteration i on
									rf.id=i.rf_idRefCaseIteration
									and i.rf_idIteration in (2,4,3)			  
						where rf.rf_idFiles=@idFile and (rf.IsUnloadIntoSP_TK is null)
					 ) r inner join t_Case c on
							r.rf_idCase=c.id
										INNER JOIN dbo.t_MES m ON
							c.id=m.rf_idCase
										INNER JOIN (SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='O'
													UNION ALL
													SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='R'
													UNION ALL
													SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='F'
													UNION ALL
													SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='V'
													UNION ALL
													SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='U') l ON
							m.MES=l.MU
				 WHERE NOT EXISTS(SELECT * FROM t_RefCaseAttachLPUItearion2 WHERE rf_idFiles=@idFile AND rf_idCase=r.rf_idCase AND AttachLPU=c.rf_idMO)
				 ------------------------------Случаи на 3 итерации
				 insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
				SELECT 513,@idFile,r.rf_idCase
				FROM (
						select rf.rf_idCase,rf.rf_idRegisterPatient,c.AttachCodeM
						from t_RefCasePatientDefine rf inner join dbo.t_CaseDefine c on
									rf.id=c.rf_idRefCaseIteration
												inner join t_CasePatientDefineIteration i on
									rf.id=i.rf_idRefCaseIteration
									and i.rf_idIteration=3			  
						where rf.rf_idFiles=@idFile and (rf.IsUnloadIntoSP_TK is null)
					 ) r inner join t_Case c on
							r.rf_idCase=c.id
										INNER JOIN dbo.t_Meduslugi m ON
							c.id=m.rf_idCase
										INNER JOIN (SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='O'
													UNION ALL
													SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='R'
													UNION ALL
													SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='F'
													UNION ALL
													SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='V'
													UNION ALL
													SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='U') l ON
							m.MUCode=l.MU
				WHERE m.Price>0 AND r.AttachCodeM<>c.rf_idMO
				
				insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
				SELECT 513,@idFile,r.rf_idCase
				FROM (
						select rf.rf_idCase,rf.rf_idRegisterPatient,c.AttachCodeM
						from t_RefCasePatientDefine rf inner join dbo.t_CaseDefine c on
									rf.id=c.rf_idRefCaseIteration
												inner join t_CasePatientDefineIteration i on
									rf.id=i.rf_idRefCaseIteration
									and i.rf_idIteration=3
						where rf.rf_idFiles=@idFile and (rf.IsUnloadIntoSP_TK is null)
					 ) r inner join t_Case c on
							r.rf_idCase=c.id
										INNER JOIN dbo.t_MES m ON
							c.id=m.rf_idCase
										INNER JOIN (SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='O'
													UNION ALL
													SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='R'
													UNION ALL
													SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='F'
													UNION ALL
													SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='V'
													UNION ALL
													SELECT MU FROM dbo.vw_sprMuWithParamAccount WHERE AccountParam='U') l ON
							m.MES=l.MU
				 WHERE r.AttachCodeM<>c.rf_idMO
				 
				----------------------------------------------------------------------------
				exec usp_RunProcessControl @CaseDefined1,@idFile
			end
			--помечаем случаи из таблицы итерации, которые были отданы в Реестре СП и ТК
			update t_RefCasePatientDefine
			set IsUnloadIntoSP_TK=1
			from t_RefCasePatientDefine rf inner join @CaseDefined cd on
						rf.rf_idCase=cd.rf_idCase and
						rf.rf_idRegisterPatient=cd.ID_Patient

		 DECLARE @version VARCHAR(5)
		 SELECT @version=(CASE WHEN ReportYear<2014 THEN '1.2' ELSE '2.11' END) from t_RegistersCase c where c.rf_idFiles=@idFile

		 insert t_FileBack(rf_idFiles,FileVersion,FileNameHRBack) values(@idFile,@version,@fileName)
		 select @idFileBack=SCOPE_IDENTITY()
		 
		 insert t_RegisterCaseBack(rf_idFilesBack,ref_idF003,ReportYear,ReportMonth,DateCreate,NumberRegister,PropertyNumberRegister)
		 select @idFileBack,c.rf_idMO,c.ReportYear,c.ReportMonth,GETDATE(),NumberRegister,@property
		 from t_RegistersCase c
		 where c.rf_idFiles=@idFile
		 select @idRegisterCaseBack=SCOPE_IDENTITY()
		 
		 
		 insert t_RecordCaseBack(rf_idRecordCase,rf_idRegisterCaseBack,rf_idCase)
			output inserted.id,inserted.rf_idCase into @idRecordCaseBack
		 select c.rf_idRecordCase,@idRegisterCaseBack,c.id
		 from @CaseDefined cd inner join t_Case c on
				cd.rf_idCase=c.id
		end try
		begin catch
		if @@TRANCOUNT>0
			select ERROR_MESSAGE()
			rollback transaction T1
			goto END_Point1
		end catch
		if @@TRANCOUNT>0
			commit transaction T1

			
		--т.к. определение страховой может быть как в таблице t_CaseDefine или t_CaseDefineZP1Found		
		--изменения от 02.07.2012
		insert #PatientBack(rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,rf_idSMO,OKATO,AttachLPU)
		select rcb.rf_idRecordCaseBack,c.rf_idF008
				,case when c.rf_idF008=3 then null else c.SPolicy end as SPolicy
				,case when c.rf_idF008=3 then c.UniqueNumberPolicy else c.NPolcy end as NPolcy
				,c.SMO,18000,c.AttachCodeM
		from @CaseDefined cd inner join t_RefCasePatientDefine rf on
					cd.rf_idCase=rf.rf_idCase
							  inner join t_CaseDefine c on
					rf.id=c.rf_idRefCaseIteration
							  inner join t_CasePatientDefineIteration i on
					rf.id=i.rf_idRefCaseIteration
					and i.rf_idIteration=3
								inner join @idRecordCaseBack rcb on
					cd.rf_idCase=rcb.rf_idCase						
		group by rcb.rf_idRecordCaseBack,c.rf_idF008,c.SPolicy,c.NPolcy,c.SMO,c.UniqueNumberPolicy,c.AttachCodeM
					
		--вставляем записи по которым определена страховая принадлежность на 2 и 4 шаге.
		--если человек иногородний то заменяем на значение по умолчанию			
		--Изменения от 03.01.2011------------------------------------------------------------------
		declare @tPatient as table(
									rf_idRecordCaseBack int NOT NULL,
									rf_idF008 tinyint NOT NULL,
									SeriaPolis varchar(10) NULL,
									NumberPolis varchar(20) NOT NULL,
									SMO char(5) NOT NULL,
									OKATO char(5) NULL,
									Fam nvarchar(40) not null,
									Im nvarchar(40) not null,
									Ot nvarchar(40) null,
									rf_idV005 tinyint not null,
									BirthDay date not null,
									DateEnd date
								  )

		--изменения от 20.01.2012
		insert @tPatient	
		select distinct rcb.rf_idRecordCaseBack,cast(c.TypePolicy as tinyint)
				,case when c.TypePolicy=3 then null else c.SPolicy end as SPolicy
				,case when c.TypePolicy=3 then c.UniqueNumberPolicy else c.NPolcy end as NPolcy
				,case when isnull(c.OKATO,'00000')='18000' then s.SMOKOD else '34' end,
				isnull(c.OKATO,'00000'),p.Fam,p.Im,p.Ot,p.rf_idV005,p.BirthDay,c1.DateEnd
		from @CaseDefined cd inner join t_RefCasePatientDefine rf on
					cd.rf_idCase=rf.rf_idCase
							  inner join t_CaseDefineZP1Found c on
					rf.id=c.rf_idRefCaseIteration
							  inner join t_CasePatientDefineIteration i on
					rf.id=i.rf_idRefCaseIteration
					and i.rf_idIteration in (2,4)
							inner join t_Case c1 on
					cd.rf_idCase=c1.id
							 inner join vw_RegisterPatient p on
					cd.ID_Patient=p.id
								inner join @idRecordCaseBack rcb on
					cd.rf_idCase=rcb.rf_idCase
								left join dbo.vw_sprSMOGlobal s on
					c.OGRN_SMO=s.OGRN
					and c.OKATO=s.OKATO
		where (OGRN_SMO is not null) and (NPolcy is not null)
		-----------------------------------------------03.01.2012-----------------------------------------------
		insert #PatientBack(rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,rf_idSMO,OKATO)
		select t.rf_idRecordCaseBack,t.rf_idF008,t.SeriaPolis,t.NumberPolis,t.SMO,t.OKATO
		from (
				select p.rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,p.SMO,OKATO
				from @tPatient p
				where p.SMO='34'
				union all
				select p.rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,p.SMO,OKATO
				from @tPatient p left join vw_sprSMODisable s on
									p.SMO=s.SMO
				where p.OKATO='18000' and s.id is null
				union all
				select p.rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,p.SMO,OKATO
				from @tPatient p inner join vw_sprSMODisable s on
									p.SMO=s.SMO					
				where p.OKATO='18000' and p.DateEnd<s.DateEnd
				union all
				select p.rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,'00','00000'
				from @tPatient p inner join vw_sprSMODisable s on
									p.SMO=s.SMO
								left join dbo.ListPeopleFromPlotnikov lp on
									upper(p.Fam)=upper(lp.FAM)
									and upper(p.Im)=upper(lp.IM)
									and ISNULL(upper(p.Ot),'bla-bla')=ISNULL(upper(lp.OT),'bla-bla')
									and p.BirthDay=lp.DR				
				where p.OKATO='18000' and p.DateEnd>=s.DateEnd and lp.FAM is null		
				union all
				select distinct p.rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,lp.Q as SMO,p.OKATO
				from @tPatient p inner join vw_sprSMODisable s on
									p.SMO=s.SMO
									--and p.OKATO='18000'
											 inner join dbo.ListPeopleFromPlotnikov lp on
									upper(p.Fam)=upper(lp.FAM)
									and upper(p.Im)=upper(lp.IM)
									and ISNULL(upper(p.Ot),'bla-bla')=ISNULL(upper(lp.OT),'bla-bla')
									and p.BirthDay=lp.DR
				where p.OKATO='18000' and p.DateEnd>=s.DateEnd
			) t 
		group by t.rf_idRecordCaseBack,t.rf_idF008,t.SeriaPolis,t.NumberPolis,t.SMO,t.OKATO


		--добавляем записи в t_PatientBack  для иногородних по тем у кого не определена страховая принадлежность, но есть ОКАТО не волгоградской области
		insert #PatientBack(rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,rf_idSMO,OKATO)
		select rcb.rf_idRecordCaseBack,rc.rf_idF008,rc.SeriaPolis,rc.NumberPolis,34,p.OKATO
		from @CaseDefined cd inner join t_RefCasePatientDefine rf on
					cd.rf_idCase=rf.rf_idCase
							  inner join t_CaseDefineZP1Found c on
					rf.id=c.rf_idRefCaseIteration
							  inner join t_CasePatientDefineIteration i on
					rf.id=i.rf_idRefCaseIteration
					and i.rf_idIteration in (2,4)
								inner join @idRecordCaseBack rcb on
					cd.rf_idCase=rcb.rf_idCase	
								inner join t_Case c1 on
					cd.rf_idCase=c1.id
								inner join t_RecordCase rc on
					c1.rf_idRecordCase=rc.id										
								inner join t_PatientSMO p on
					rc.id=p.ref_idRecordCase
					and p.OKATO!='18000' 
					and p.OKATO is not null						
		where (OGRN_SMO is null) and (NPolcy is null) 

		insert #PatientBack(rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,rf_idSMO,OKATO)
		select rcb.rf_idRecordCaseBack,rc.rf_idF008,rc.SeriaPolis,rc.NumberPolis,isnull(reg.rf_idSMO,'00'),'00000'
		from @CaseDefined cd inner join t_RefCasePatientDefine rf on
					cd.rf_idCase=rf.rf_idCase
							  inner join t_CaseDefineZP1Found c on
					rf.id=c.rf_idRefCaseIteration
							  inner join t_CasePatientDefineIteration i on
					rf.id=i.rf_idRefCaseIteration
					and i.rf_idIteration =4
								inner join @idRecordCaseBack rcb on
					cd.rf_idCase=rcb.rf_idCase	
								inner join t_Case c1 on
					cd.rf_idCase=c1.id
								inner join t_RecordCase rc on
					c1.rf_idRecordCase=rc.id
								inner join t_RegistersCase reg on
					rc.rf_idRegistersCase=reg.id		
								left join @CaseDefined2 cd2 on
					cd.rf_idCase=cd.rf_idCase
					and cd.ID_Patient=cd2.ID_Patient							
		where (OGRN_SMO is null) and (NPolcy is null)  and (cd2.rf_idCase is null)	

		begin transaction T2	
		begin try

		-----------------------------------------------02.07.2012-----------------------------------------------
		--федеральный регистр застрахованных может вернуть гражданина который не застрахован в действующей СМО.
		--делаем пометку в таблице ошибок с номером 57
		-----------04/02/2015
		----добавил условие, что если страхование у ЗЛ принадлежит не действующим СМО, то выкидывать его в 57 ошибку
		insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
		select 57,@idFile,r.rf_idCase
		from @tPatient p inner join t_RecordCaseBack r on
							  p.rf_idRecordCaseBack=r.id
							inner join vw_sprSMODisable s on
									p.SMO=s.SMO					
		where p.OKATO='18000' and p.DateEnd>=s.DateEnd	AND NOT EXISTS(SELECT * FROM #PatientBack WHERE rf_idRecordCaseBack=p.rf_idRecordCaseBack AND rf_idSMO<>'00' )		
		--Есть люди у которых есть полюса закрытых СМО, но их нету в таблице ListPeopleFromPlotnikov
		insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
		select 57,@idFile,r.rf_idCase
		from @tPatient p inner join t_RecordCaseBack r on
							  p.rf_idRecordCaseBack=r.id
						INNER JOIN #PatientBack p1 ON
							  p1.rf_idRecordCaseBack=p.rf_idRecordCaseBack							
		where p1.rf_idSMO='00'--EXISTS(SELECT * FROM #PatientBack WHERE rf_idRecordCaseBack=p.rf_idRecordCaseBack AND rf_idSMO='00' )		

		------------------------------insert t_PatientBack-----------------------------------------------------
		insert t_PatientBack(rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,rf_idSMO,OKATO,AttachCodeM) 
		select rf_idRecordCaseBack,case when rf_idF008=0 then 3 else rf_idF008 end,SeriaPolis,NumberPolis,rf_idSMO,OKATO,AttachLPU
		from #PatientBack
		-------------------------------------------------------------------------------------------------------
		 insert t_CaseBack(rf_idRecordCaseBack,TypePay)		
		 select rcb.rf_idRecordCaseBack,(case when e.ErrorNumber is null then 1 else 2 end) as TypePay
		 from @CaseDefined cd inner join @idRecordCaseBack rcb on
					cd.rf_idCase=rcb.rf_idCase
							  left join t_ErrorProcessControl e on
					cd.rf_idCase=e.rf_idCase and
					e.rf_idFile=@idFile
		group by rcb.rf_idRecordCaseBack,(case when e.ErrorNumber is null then 1 else 2 end)
					
		--------------------------------данные для отчета по плану заказов---------------------------------------------
			declare @month tinyint,
					@year smallint,
					@codeLPU char(6)		
			if @idFileBack is not null		
			BEGIN
			
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
				
			end
			------------------------------------------------------------------------------------------------------------------			
		end try
		begin catch
		if @@TRANCOUNT>0
			select ERROR_MESSAGE()
			rollback transaction T2
			goto END_Point1			
		end catch
		if @@TRANCOUNT>0
			commit transaction T2
		
		goto END_Point2

end
else 
begin
	select 'Данный реестр СП и ТК был сформирован ранее'
	goto END_Point2
end
END_Point1:
		---зачищаем все следы			
			delete from t_FileBack where id=@idFileBack

			update t_RefCasePatientDefine 
			set IsUnloadIntoSP_TK=null
			from t_RefCasePatientDefine r inner join t_CasePatientDefineIteration i on
					r.id=i.rf_idRefCaseIteration
			where rf_idFiles =@idFile and i.rf_idIteration<>1
			
END_Point2:

go