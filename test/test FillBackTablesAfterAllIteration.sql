use RegisterCases
go
declare @CaseDefined TVP_CasePatient

--select rf_idFiles
--from t_RefCasePatientDefine
--where (IsUnloadIntoSP_TK is null)
--group by rf_idFiles


insert @CaseDefined(rf_idCase,ID_Patient)
select rf_idCase,rf_idRegisterPatient
from t_RefCasePatientDefine
where (IsUnloadIntoSP_TK is null)
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
						
insert @tPatient	
select rcb.rf_idRecordCaseBack,cast(c.TypePolicy as tinyint),c.SPolicy,c.NPolcy,
		case when isnull(c.OKATO,'00000')='18000' then s.SMOKOD else '34' end,
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
					 inner join t_RegisterPatient p on
			cd.ID_Patient=p.id
			--			inner join @idRecordCaseBack rcb on
			--cd.rf_idCase=rcb.rf_idCase
						left join dbo.vw_sprSMOGlobal s on
			c.OGRN_SMO=s.OGRN
			and c.OKATO=s.OKATO
where (OGRN_SMO is not null) and (NPolcy is not null) 

--select * from @tPatient p where SMO='34003'

select *
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
		select distinct p.rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,lp.Q as SMO,p.OKATO
		from @tPatient p inner join vw_sprSMODisable s on
							p.SMO=s.SMO
							--and p.OKATO='18000'
									 inner join PolicyRegister.dbo.ListPeopleFromPlotnikov lp on
							upper(p.Fam)=upper(lp.FAM)
							and upper(p.Im)=upper(lp.IM)
							and ISNULL(upper(p.Ot),'bla-bla')=ISNULL(upper(lp.OT),'bla-bla')
							and p.BirthDay=lp.DR
		where p.OKATO='18000' and p.DateEnd>=s.DateEnd
	) t
	
select distinct p.rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,lp.Q as SMO,p.OKATO
		from @tPatient p inner join vw_sprSMODisable s on
							p.SMO=s.SMO
							--and p.OKATO='18000'
									 inner join PolicyRegister.dbo.ListPeopleFromPlotnikov lp on
							upper(p.Fam)=upper(lp.FAM)
							and upper(p.Im)=upper(lp.IM)
							and ISNULL(upper(p.Ot),'bla-bla')=ISNULL(upper(lp.OT),'bla-bla')
							and p.BirthDay=lp.DR
		where p.OKATO='18000' and p.DateEnd>=s.DateEnd

