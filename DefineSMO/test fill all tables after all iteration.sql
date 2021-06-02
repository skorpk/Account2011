USE RegisterCases
GO
DECLARE @idFile INT=127144

--SELECT z.*,rd.rf_idFiles,i.rf_idIteration
--FROM dbo.t_Case c INNER JOIN dbo.t_RefCasePatientDefine rd ON
--			c.id=rd.rf_idCase
--					INNER JOIN dbo.t_CaseDefineZP1Found z ON
--			rd.id=z.rf_idRefCaseIteration 
--					INNER JOIN dbo.t_CasePatientDefineIteration i ON
--			rd.id=i.rf_idRefCaseIteration                   
--WHERE c.GUID_Case='5a5a9b0b-1ea8-493e-93da-e9fff3bd3e4a'

declare @property tinyint=2

		declare @fileName varchar(29),
				@idFileBack int,
				@idRegisterCaseBack int
		declare @idRecordCaseBack as table(rf_idRecordCaseBack int,rf_idCase BIGINT, STep TINYINT)

		--им€ реестра —ѕ и “ 
		select @fileName=dbo.fn_GetFileNameBack(@idFile)
		INSERT dbo.t_FileBackNumberOrder( FILENAMEBack) VALUES(@fileName)
		--временна€ таблица дл€ того что бы не было двойных записей по пациентам
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
			ENP VARCHAR(16)
		)

		create unique nonclustered index UQ_IDRecordCaseBack on #PatientBack(rf_idRecordCaseBack) with IGNORE_DUP_KEY


		declare @CaseDefined TVP_CasePatient,--обща€
				@CaseDefined1 TVP_CasePatient,--дл€ местных
				@CaseDefined2 TVP_CasePatient --дл€ иногородних

		insert @CaseDefined(rf_idCase,ID_Patient)
		select rf_idCase,rf_idRegisterPatient
		from t_RefCasePatientDefine rf inner join t_CasePatientDefineIteration i on
							rf.id=i.rf_idRefCaseIteration
		where rf_idFiles=@idFile --and (IsUnloadIntoSP_TK is null)
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
				where rf.rf_idFiles=@idFile --and (rf.IsUnloadIntoSP_TK is null)
				union all
				select rf.rf_idCase,rf.rf_idRegisterPatient
				from t_RefCasePatientDefine rf inner join t_CasePatientDefineIteration i on
							rf.id=i.rf_idRefCaseIteration
							and i.rf_idIteration in (3)			  
				where rf.rf_idFiles=@idFile --and (rf.IsUnloadIntoSP_TK is null)
				group by rf.rf_idCase,rf.rf_idRegisterPatient
			 ) rf

		
		--12.01.2017
		--ѕо иногородним должна быть определена страхова€ принадлежность т.к. другие регионы нам отказывают в оплате
		---иногородние
		--сюда необходимо добавить выборку иногородних 05.02.2012
		insert @CaseDefined2(rf_idCase,ID_Patient)
		select rf.rf_idCase,rf.rf_idRegisterPatient
		from t_RefCasePatientDefine rf inner join t_CaseDefineZP1Found c on
					rf.id=c.rf_idRefCaseIteration
					and c.OKATO is not null
					and c.OKATO!='18000'									  
		where rf.rf_idFiles=@idFile --and (rf.IsUnloadIntoSP_TK is null)
		
	
		SELECT * FROM @CaseDefined2
			
		INSERT @idRecordCaseBack( rf_idRecordCaseBack ,rf_idCase ,STep)
		SELECT rf_idRecordCase,rf_idCase,IdStep
		FROM dbo.t_FileBack f INNER JOIN dbo.t_RegisterCaseBack a ON
					f.id=a.rf_idFilesBack
							INNER JOIN dbo.t_RecordCaseBack r ON
					a.id=r.rf_idRegisterCaseBack
		WHERE f.rf_idFiles=@idFile 
		     
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
----------------------------------------------------------------------------------------------
--т.к. определение страховой может быть как в таблице t_CaseDefine или t_CaseDefineZP1Found		
		--изменени€ от 02.07.2012
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
					
		--вставл€ем записи по которым определена страхова€ принадлежность на 2 и 4 шаге.
		--если человек иногородний то замен€ем на значение по умолчанию			
		--»зменени€ от 03.01.2011------------------------------------------------------------------
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
									ENP VARCHAR(16)
								  )

		--изменени€ от 20.01.2012
		insert @tPatient	
		select distinct rcb.rf_idRecordCaseBack,cast(c.TypePolicy as tinyint)
				,case when c.TypePolicy=3 then null else c.SPolicy end as SPolicy
				,case when c.TypePolicy=3 then c.UniqueNumberPolicy else c.NPolcy end as NPolcy
				,case when s.SMOKOD='34001' THEN '34007' ELSE s.SMOKOD end,
				isnull(c.OKATO,'00000'),p.Fam,p.Im,p.Ot,p.rf_idV005,p.BirthDay,c1.DateEnd
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
							 inner join vw_RegisterPatient p on
					cd.ID_Patient=p.id
								inner join @idRecordCaseBack rcb on
					cd.rf_idCase=rcb.rf_idCase
								left join dbo.vw_sprSMOGlobal s on
					c.OGRN_SMO=s.OGRN
					and c.OKATO=s.OKATO
		where (OGRN_SMO is not null) and (NPolcy is not null) AND isnull(c.OKATO,'00000')='18000'

		insert @tPatient	
		select distinct rcb.rf_idRecordCaseBack,cast(c.TypePolicy as tinyint)
				,case when c.TypePolicy=3 then null else c.SPolicy end as SPolicy
				,case when c.TypePolicy=3 then c.UniqueNumberPolicy else c.NPolcy end as NPolcy
				,'34',
				isnull(c.OKATO,'00000'),p.Fam,p.Im,p.Ot,p.rf_idV005,p.BirthDay,c1.DateEnd
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
							 inner join vw_RegisterPatient p on
					cd.ID_Patient=p.id
								inner join @idRecordCaseBack rcb on
					cd.rf_idCase=rcb.rf_idCase
								left join dbo.vw_sprSMOGlobal s on
					c.OGRN_SMO=s.OGRN
					and c.OKATO=s.OKATO
		where (OGRN_SMO is not null) and (NPolcy is not null) AND isnull(c.OKATO,'00000')<>'18000'
		-----------------------------------------------03.01.2012-----------------------------------------------
		insert #PatientBack(rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,rf_idSMO,OKATO,ENP)
		select t.rf_idRecordCaseBack,t.rf_idF008,t.SeriaPolis,t.NumberPolis,t.SMO,t.OKATO,t.ENP
		from (
				select p.rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,p.SMO,OKATO,p.ENP
				from @tPatient p
				where p.SMO='34'
				union all
				select p.rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,p.SMO,OKATO,p.ENP
				from @tPatient p left join vw_sprSMODisable s on
									p.SMO=s.SMO
				where p.OKATO='18000' and s.id is null
				union all
				select p.rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,p.SMO,OKATO,p.ENP
				from @tPatient p inner join vw_sprSMODisable s on
									p.SMO=s.SMO					
				where p.OKATO='18000' and p.DateEnd<s.DateEnd
				union all
				select p.rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,'00','00000',p.ENP
				from @tPatient p inner join vw_sprSMODisable s on
									p.SMO=s.SMO
								left join dbo.ListPeopleFromPlotnikov lp on
									upper(p.Fam)=upper(lp.FAM)
									and upper(p.Im)=upper(lp.IM)
									and ISNULL(upper(p.Ot),'bla-bla')=ISNULL(upper(lp.OT),'bla-bla')
									and p.BirthDay=lp.DR				
				where p.OKATO='18000' and p.DateEnd>=s.DateEnd and lp.FAM is null		
				union all
				select distinct p.rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,lp.Q as SMO,p.OKATO,p.ENP
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
		group by t.rf_idRecordCaseBack,t.rf_idF008,t.SeriaPolis,t.NumberPolis,t.SMO,t.OKATO,t.ENP


		--добавл€ем записи в t_PatientBack  дл€ иногородних по тем у кого не определена страхова€ принадлежность, но есть ќ ј“ќ не волгоградской области
		insert #PatientBack(rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,rf_idSMO,OKATO,ENP)
		select rcb.rf_idRecordCaseBack,rc.rf_idF008,rc.SeriaPolis,rc.NumberPolis,34,p.OKATO,c.UniqueNumberPolicy
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

		select 57,@idFile,r.rf_idCase
		from @tPatient p inner join t_RecordCaseBack r on
							  p.rf_idRecordCaseBack=r.id
							inner join vw_sprSMODisable s on
									p.SMO=s.SMO					
		where p.OKATO='18000' and p.DateEnd>=s.DateEnd	AND NOT EXISTS(SELECT * FROM #PatientBack WHERE rf_idRecordCaseBack=p.rf_idRecordCaseBack AND rf_idSMO<>'00' )		

		--≈сть люди у которых есть полюса закрытых —ћќ, но их нету в таблице ListPeopleFromPlotnikov
		select 57,@idFile,r.rf_idCase
		from @tPatient p inner join t_RecordCaseBack r on
							  p.rf_idRecordCaseBack=r.id
						INNER JOIN #PatientBack p1 ON
							  p1.rf_idRecordCaseBack=p.rf_idRecordCaseBack							
		where p1.rf_idSMO='00'--EXISTS(SELECT * FROM #PatientBack WHERE rf_idRecordCaseBack=p.rf_idRecordCaseBack AND rf_idSMO='00' )		

		------------------------------insert t_PatientBack-----------------------------------------------------
		select rf_idRecordCaseBack,case when rf_idF008=0 then 3 else rf_idF008 end,SeriaPolis,NumberPolis,rf_idSMO,OKATO,AttachLPU,ENP
		from #PatientBack

GO
DROP TABLE #PatientBack