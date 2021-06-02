USE RegisterCases
GO
DECLARE 	@idFile INT=178904

if NOT EXISTS(
				select * from vw_getFileBack v where v.rf_idFiles=@idFile and v.PropertyNumberRegister=0
				union all
				select * from vw_getFileBack v where v.rf_idFiles=@idFile and v.PropertyNumberRegister=2
			 )

		declare @property tinyint=2

		declare @fileName varchar(29),
				@idFileBack int,
				@idRegisterCaseBack int
		declare @idRecordCaseBack as table(rf_idRecordCaseBack int,rf_idCase BIGINT, STep TINYINT)

		--имя реестра СП и ТК
		select @fileName=dbo.fn_GetFileNameBack(@idFile)

		
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
			AttachLPU VARCHAR(6),
			ENP VARCHAR(16),
			CodeSMO34 CHAR(5)
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

		
		--12.01.2017
		--По иногородним должна быть определена страховая принадлежность т.к. другие регионы нам отказывают в оплате
		---иногородние
		--сюда необходимо добавить выборку иногородних 05.02.2012
		insert @CaseDefined2(rf_idCase,ID_Patient)
		select rf.rf_idCase,rf.rf_idRegisterPatient
		from t_RefCasePatientDefine rf inner join t_CaseDefineZP1Found c on
					rf.id=c.rf_idRefCaseIteration
					and c.OKATO is not null
					and c.OKATO!='18000'									  
		where rf.rf_idFiles=@idFile and (rf.IsUnloadIntoSP_TK is null)
		
		--производим технологический контроль для застрахованных в других территориях
		--убрал проверку 28.03.2012 т.к. все проверки реализованный на ТК1
		--exec usp_RunProcessControl2 @CaseDefined2,@idFile

		
		DECLARE @version VARCHAR(5)

		 --SELECT @version=(CASE WHEN ReportYear<2014 THEN '1.2' ELSE '2.11' END) from t_RegistersCase c where c.rf_idFiles=@idFile
		
			SELECT @version='3.11'
BEGIN TRANSACTION

		 insert t_FileBack(rf_idFiles,FileVersion,FileNameHRBack) values(@idFile,@version,@fileName)
		 select @idFileBack=SCOPE_IDENTITY()
		 
		 insert t_RegisterCaseBack(rf_idFilesBack,ref_idF003,ReportYear,ReportMonth,DateCreate,NumberRegister,PropertyNumberRegister)
		 select @idFileBack,c.rf_idMO,c.ReportYear,c.ReportMonth,GETDATE(),NumberRegister,2
		 from t_RegistersCase c
		 where c.rf_idFiles=@idFile
		 select @idRegisterCaseBack=SCOPE_IDENTITY()
		 
		 -----для тех людей, которые найдены на 2 и 4 шаге
		 insert t_RecordCaseBack(rf_idRecordCase,rf_idRegisterCaseBack,rf_idCase,IdStep)
			output inserted.id,inserted.rf_idCase, INSERTED.IdStep into @idRecordCaseBack
		 select c.rf_idRecordCase,@idRegisterCaseBack,c.id,0
		 from @CaseDefined cd inner join t_Case c on
				cd.rf_idCase=c.id
		 WHERE NOT EXISTS(SELECT * FROM dbo.t_ErrorProcessControl WHERE rf_idCase=c.id AND ErrorNumber=57)
				AND NOT EXISTS(SELECT * FROM vw_CasePatientDefine WHERE rf_idCase=c.id)
		 
		 -----для тех людей, которые найдены на 3 шаге
		 insert t_RecordCaseBack(rf_idRecordCase,rf_idRegisterCaseBack,rf_idCase,IdStep)
			output inserted.id,inserted.rf_idCase, INSERTED.IdStep into @idRecordCaseBack
		 select c.rf_idRecordCase,@idRegisterCaseBack,c.id,CASE WHEN d.idStep=1 THEN 0 ELSE 1 END 
		 from @CaseDefined cd inner join t_Case c on
				cd.rf_idCase=c.id
								INNER JOIN dbo.vw_CasePatientDefine d ON
				cd.rf_idCase=d.rf_idCase                              
		 WHERE NOT EXISTS(SELECT * FROM dbo.t_ErrorProcessControl WHERE rf_idCase=c.id AND ErrorNumber=57)


		 insert t_RecordCaseBack(rf_idRecordCase,rf_idRegisterCaseBack,rf_idCase,IdStep)
			output inserted.id,inserted.rf_idCase, INSERTED.IdStep into @idRecordCaseBack
		 select c.rf_idRecordCase,@idRegisterCaseBack,c.id,2
		 from @CaseDefined cd inner join t_Case c on
				cd.rf_idCase=c.id
		 WHERE EXISTS(SELECT * FROM dbo.t_ErrorProcessControl WHERE rf_idCase=c.id AND ErrorNumber=57)

			

			
		--т.к. определение страховой может быть как в таблице t_CaseDefine или t_CaseDefineZP1Found		
		--изменения от 02.07.2012
		insert #PatientBack(rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,rf_idSMO,OKATO,AttachLPU,ENP)
		SELECT DISTINCT rcb.rf_idRecordCaseBack,c.rf_idF008
				,case when c.rf_idF008=3 then null else c.SPolicy end as SPolicy
				,case when c.rf_idF008=3 then c.UniqueNumberPolicy else c.NPolcy end as NPolcy
				,CASE WHEN c.SMO='34001' AND c1.DateEnd>='20160801' THEN '34007' ELSE c.SMO END,18000,c.AttachCodeM
				,c.UniqueNumberPolicy AS ENP
		from @CaseDefined cd inner join t_RefCasePatientDefine rf on
					cd.rf_idCase=rf.rf_idCase
							  inner join t_CaseDefine c on
					rf.id=c.rf_idRefCaseIteration
							  inner join t_CasePatientDefineIteration i on
					rf.id=i.rf_idRefCaseIteration
					and i.rf_idIteration=3
								inner join @idRecordCaseBack rcb on
					cd.rf_idCase=rcb.rf_idCase		
								INNER JOIN dbo.t_Case c1 ON
					rf.rf_idCase=c1.id				
		--group by rcb.rf_idRecordCaseBack,c.rf_idF008,c.SPolicy,c.NPolcy,c.SMO,c.UniqueNumberPolicy,c.AttachCodeM
					
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
									DateEnd DATE,
									ENP VARCHAR(16),
									CodeSMO34 VARCHAR(5)
								  )

		--изменения от 20.01.2012
		
		;WITH cteSMO
		AS(
		select ROW_NUMBER() OVER (PARTITION BY rcb.rf_idRecordCaseBack ORDER BY s.DateEnd desc) AS idRow,
				rcb.rf_idRecordCaseBack,cast(c.TypePolicy as tinyint) AS TypePolicy
				,case when c.TypePolicy=3 then null else c.SPolicy end as SPolicy
				,case when c.TypePolicy=3 then c.UniqueNumberPolicy else c.NPolcy end as NPolcy
				,case when s.SMOKOD='34001' THEN '34007' ELSE s.SMOKOD END AS SMO,
				isnull(c.OKATO,'00000') OKATO,p.Fam,p.Im,p.Ot,p.rf_idV005,p.BirthDay,c1.DateEnd
				,c.UniqueNumberPolicy
		from @CaseDefined cd inner join t_RefCasePatientDefine rf on
					cd.rf_idCase=rf.rf_idCase
							  inner join t_CaseDefineZP1Found c on
					rf.id=c.rf_idRefCaseIteration
							  inner join t_CasePatientDefineIteration i on
					rf.id=i.rf_idRefCaseIteration
					and i.rf_idIteration in (2,4)
							inner join t_Case c1 on
					cd.rf_idCase=c1.id
							INNER JOIN dbo.t_CompletedCase cc ON
                     c1.rf_idRecordCase=cc.rf_idRecordCase
							 inner join vw_RegisterPatient p on
					cd.ID_Patient=p.id
								inner join @idRecordCaseBack rcb on
					cd.rf_idCase=rcb.rf_idCase
								inner join dbo.vw_sprSMOGlobal s on
					c.OGRN_SMO=s.OGRN
					and c.OKATO=s.OKATO
					AND cc.DateEnd BETWEEN s.dateBeg AND s.dateEnd
		where (OGRN_SMO is not null) and (NPolcy is not null) AND isnull(c.OKATO,'00000')='18000'
		)
		insert @tPatient SELECT c.rf_idRecordCaseBack, c.TypePolicy,c.SPolicy,c.NPolcy,c.SMO,c.OKATO,c.FAM,c.Im,c.Ot,c.rf_idV005,c.BirthDay,c.DateEnd,c.UniqueNumberPolicy,null
		 FROM cteSMO c WHERE c.idRow=1

		;WITH cteSMO34
		AS(	
		select ROW_NUMBER() OVER (PARTITION BY rcb.rf_idRecordCaseBack ORDER BY s.dateEnd desc) AS idRow,
			    rcb.rf_idRecordCaseBack,cast(c.TypePolicy as tinyint) AS TypePolicy
				,case when c.TypePolicy=3 then null else c.SPolicy end as SPolicy
				,case when c.TypePolicy=3 then c.UniqueNumberPolicy else c.NPolcy end as NPolcy
				,'34' AS SMO,
				isnull(c.OKATO,'00000') AS OKATO,p.Fam,p.Im,p.Ot,p.rf_idV005,p.BirthDay,c1.DateEnd
				,c.UniqueNumberPolicy,s.SMOKOD
		from @CaseDefined cd inner join t_RefCasePatientDefine rf on
					cd.rf_idCase=rf.rf_idCase
							  inner join t_CaseDefineZP1Found c on
					rf.id=c.rf_idRefCaseIteration
							  inner join t_CasePatientDefineIteration i on
					rf.id=i.rf_idRefCaseIteration
					and i.rf_idIteration in (2,4)
							inner join t_Case c1 on
					cd.rf_idCase=c1.id
							INNER JOIN dbo.t_CompletedCase cc ON
                     c1.rf_idRecordCase=cc.rf_idRecordCase
							 inner join vw_RegisterPatient p on
					cd.ID_Patient=p.id
								inner join @idRecordCaseBack rcb on
					cd.rf_idCase=rcb.rf_idCase
								inner join dbo.vw_sprSMOGlobal s on
					c.OGRN_SMO=s.OGRN
					and c.OKATO=s.OKATO
					AND cc.DateEnd BETWEEN s.dateBeg AND s.dateEnd
		where (OGRN_SMO is not null) and (NPolcy is not null) AND isnull(c.OKATO,'00000')<>'18000'
		)
		insert @tPatient SELECT c.rf_idRecordCaseBack, c.TypePolicy,c.SPolicy,c.NPolcy,c.SMO,c.OKATO,c.FAM,c.Im,c.Ot,c.rf_idV005,c.BirthDay,c.DateEnd,c.UniqueNumberPolicy,SMOKOD
		 FROM cteSMO34 c WHERE c.idRow=1
		-----------------------------------------------03.01.2012-----------------------------------------------
		insert #PatientBack(rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,rf_idSMO,OKATO,ENP,CodeSMO34)
		select t.rf_idRecordCaseBack,t.rf_idF008,t.SeriaPolis,t.NumberPolis,t.SMO,t.OKATO,t.ENP,t.CodeSMO34
		from (
				select p.rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,p.SMO,OKATO,p.ENP,p.CodeSMO34
				from @tPatient p
				where p.SMO='34'
				union all
				select p.rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,p.SMO,OKATO,p.ENP,p.CodeSMO34
				from @tPatient p left join vw_sprSMODisable s on
									p.SMO=s.SMO
				where p.OKATO='18000' and s.id is null
				union all
				select p.rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,p.SMO,OKATO,p.ENP,p.CodeSMO34
				from @tPatient p inner join vw_sprSMODisable s on
									p.SMO=s.SMO					
				where p.OKATO='18000' and p.DateEnd<s.DateEnd
				union all
				select p.rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,'00','00000',p.ENP,p.CodeSMO34
				from @tPatient p inner join vw_sprSMODisable s on
									p.SMO=s.SMO
								left join dbo.ListPeopleFromPlotnikov lp on
									upper(p.Fam)=upper(lp.FAM)
									and upper(p.Im)=upper(lp.IM)
									and ISNULL(upper(p.Ot),'bla-bla')=ISNULL(upper(lp.OT),'bla-bla')
									and p.BirthDay=lp.DR				
				where p.OKATO='18000' and p.DateEnd>=s.DateEnd and lp.FAM is null		
				union all
				select distinct p.rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,lp.Q as SMO,p.OKATO,p.ENP,p.CodeSMO34
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
		group by t.rf_idRecordCaseBack,t.rf_idF008,t.SeriaPolis,t.NumberPolis,t.SMO,t.OKATO,t.ENP, t.CodeSMO34


		--добавляем записи в t_PatientBack  для иногородних по тем у кого не определена страховая принадлежность, но есть ОКАТО не волгоградской области
		insert #PatientBack(rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,rf_idSMO,OKATO,ENP,CodeSMO34)
		select rcb.rf_idRecordCaseBack,rc.rf_idF008,rc.SeriaPolis,rc.NumberPolis,/*34*/ '00',p.OKATO,c.UniqueNumberPolicy,null
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
		where (c.OGRN_SMO is null) and (NPolcy is null) 

		insert #PatientBack(rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,rf_idSMO,OKATO,ENP)
		select rcb.rf_idRecordCaseBack,rc.rf_idF008,rc.SeriaPolis,rc.NumberPolis,isnull(reg.rf_idSMO,'00'),'00000'
		,c.UniqueNumberPolicy
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


		------------------------------insert t_PatientBack-----------------------------------------------------
		--insert t_PatientBack(rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,rf_idSMO,OKATO,AttachCodeM,ENP,CodeSMO34) 
		select rf_idRecordCaseBack,case when rf_idF008=0 then 3 else rf_idF008 end,SeriaPolis,NumberPolis,rf_idSMO,OKATO,AttachLPU,ENP,CodeSMO34
		from #PatientBack
rollback TRANSACTION
GO
DROP TABLE #PatientBack