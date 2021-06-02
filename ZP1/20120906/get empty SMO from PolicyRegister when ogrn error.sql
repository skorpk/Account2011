use RegisterCases
go
declare @idFile int =11492

--select * from vw_getFileBack v where v.rf_idFiles=@idFile
--if NOT EXISTS(
--				select * from vw_getFileBack v where v.rf_idFiles=@idFile and v.PropertyNumberRegister=0
--				union all
--				select * from vw_getFileBack v where v.rf_idFiles=@idFile and v.PropertyNumberRegister=2
--			 )
--begin
		declare @property tinyint=2

		declare @fileName varchar(29),
				@idFileBack int,
				@idRegisterCaseBack int
		declare @idRecordCaseBack as table(rf_idRecordCaseBack int,rf_idCase bigint)

		--им€ реестра —ѕ и “ 
		select @fileName=dbo.fn_GetFileNameBack(@idFile)
		--временна€ таблица дл€ того что бы не было двойных записей по пациентам
		--данные индекс будит вдальнейшем висеть на таблице t_PatientBack, сейчас пока не вычестил двойников из нее.
		CREATE TABLE #PatientBack
		(
			rf_idRecordCaseBack int NOT NULL,
			rf_idF008 tinyint NOT NULL,
			SeriaPolis varchar(10) NULL,
			NumberPolis varchar(20) NOT NULL,
			rf_idSMO char(5) NOT NULL,
			OKATO char(5) NULL
		)
		CREATE TABLE #tmp_RecordCaseBack
		(
			[id] [int] IDENTITY(1,1) NOT NULL,
			[rf_idRegisterCaseBack] [int] NOT NULL,
			[rf_idRecordCase] [int] NOT NULL,
			[rf_idCase] [bigint] NOT NULL
		)


		create unique nonclustered index UQ_IDRecordCaseBack on #PatientBack(rf_idRecordCaseBack) with IGNORE_DUP_KEY


		declare @CaseDefined TVP_CasePatient,--обща€
				@CaseDefined1 TVP_CasePatient,--дл€ местных
				@CaseDefined2 TVP_CasePatient --дл€ иногородних

		insert @CaseDefined(rf_idCase,ID_Patient)
		select rf_idCase,rf_idRegisterPatient
		from t_RefCasePatientDefine
		where rf_idFiles=@idFile and (IsUnloadIntoSP_TK is null)
		
		print 'insert @CaseDefined'
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
		print 'insert @CaseDefined1'
		---иногородние
		--сюда необходимо добавить выборку иногородних 05.02.2012
		insert @CaseDefined2(rf_idCase,ID_Patient)
		select rf.rf_idCase,rf.rf_idRegisterPatient
		from t_RefCasePatientDefine rf inner join t_CaseDefineZP1Found c on
					rf.id=c.rf_idRefCaseIteration
					and c.OKATO is not null
					and c.OKATO!='18000'									  
		where rf.rf_idFiles=@idFile and (rf.IsUnloadIntoSP_TK is null)
		--заполн€ем таблицу дл€ иногородних по тем у кого не определена страхова€ принадлежность, но есть ќ ј“ќ не волгоградской области
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
		print 'insert @CaseDefined2'

		insert #tmp_RecordCaseBack(rf_idRecordCase,rf_idRegisterCaseBack,rf_idCase)
		output inserted.id,inserted.rf_idCase into @idRecordCaseBack
		 select c.rf_idRecordCase,567,c.id
		 from @CaseDefined cd inner join t_Case c on
				cd.rf_idCase=c.id
			
		--т.к. определение страховой может быть как в таблице t_CaseDefine или t_CaseDefineZP1Found		
		--изменени€ от 02.07.2012
		insert #PatientBack(rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,rf_idSMO,OKATO)
		select rcb.rf_idRecordCaseBack,c.rf_idF008
				,case when c.rf_idF008=3 then null else c.SPolicy end as SPolicy
				,case when c.rf_idF008=3 then c.UniqueNumberPolicy else c.NPolcy end as NPolcy
				,c.SMO,18000
		from @CaseDefined cd inner join t_RefCasePatientDefine rf on
					cd.rf_idCase=rf.rf_idCase
							  inner join t_CaseDefine c on
					rf.id=c.rf_idRefCaseIteration
							  inner join t_CasePatientDefineIteration i on
					rf.id=i.rf_idRefCaseIteration
					and i.rf_idIteration=3
								inner join @idRecordCaseBack rcb on
					cd.rf_idCase=rcb.rf_idCase						
		group by rcb.rf_idRecordCaseBack,c.rf_idF008,c.SPolicy,c.NPolcy,c.SMO,c.UniqueNumberPolicy
		print '#PatientBack'			
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
									DateEnd date
								  )

		select distinct rf.rf_idCase,c.*, rcb.rf_idRecordCaseBack,cast(c.TypePolicy as tinyint)
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
		--изменени€ от 20.01.2012
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


		--добавл€ем записи в t_PatientBack  дл€ иногородних по тем у кого не определена страхова€ принадлежность, но есть ќ ј“ќ не волгоградской области
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

select rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,rf_idSMO,OKATO from #PatientBack

drop table #PatientBack
drop table #tmp_RecordCaseBack