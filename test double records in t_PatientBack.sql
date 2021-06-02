use RegisterCases
go
--select d.*,r.*,i.rf_idIteration,z.*
--from t_FileBack fb inner join t_RegisterCaseBack ab on
--		fb.id=ab.rf_idFilesBack
--		and fb.CodeM='165310'
--		and ab.NumberRegister=227
--		and PropertyNumberRegister=2
--					inner join t_RecordCaseBack r on
--		ab.id=r.rf_idRegisterCaseBack
--					inner join t_PatientBack p on
--		r.id=p.rf_idRecordCaseBack
--					inner join t_RefCasePatientDefine d on
--		r.rf_idCase=d.rf_idCase
--					inner join t_CasePatientDefineIteration i on
--		d.id=i.rf_idRefCaseIteration
--					inner join t_CaseDefineZP1Found z on
--		d.id=z.rf_idRefCaseIteration
--where rf_idRecordCaseBack=7414360

--select * from vw_sprSMOGlobal where OGRN='1057746135325' and OKATO='18000'

declare @CaseDefined TVP_CasePatient
insert @CaseDefined(rf_idCase,ID_Patient)
select rf_idCase,rf_idRegisterPatient from t_RefCasePatientDefine where id=7722952

declare @idRecordCaseBack as table(rf_idRecordCaseBack int,rf_idCase bigint)

insert @idRecordCaseBack
select id,rf_idCase from t_RecordCaseBack where id=7414360

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

--select * from @tPatient


select t.rf_idRecordCaseBack,t.rf_idF008,t.SeriaPolis,t.NumberPolis,t.SMO,t.OKATO,typeQuery
from (
		select p.rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,p.SMO,OKATO,1 as typeQuery
		from @tPatient p
		where p.SMO='34'
		union all
		select p.rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,p.SMO,OKATO,2
		from @tPatient p left join vw_sprSMODisable s on
							p.SMO=s.SMO
		where p.OKATO='18000' and s.id is null
		union all
		select p.rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,p.SMO,OKATO,3
		from @tPatient p inner join vw_sprSMODisable s on
							p.SMO=s.SMO					
		where p.OKATO='18000' and p.DateEnd<s.DateEnd
		union all
		select p.rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,'00','00000',4
		from @tPatient p inner join vw_sprSMODisable s on
							p.SMO=s.SMO	
						left join dbo.ListPeopleFromPlotnikov lp on
							upper(p.Fam)=upper(lp.FAM)
							and upper(p.Im)=upper(lp.IM)
							and ISNULL(upper(p.Ot),'bla-bla')=ISNULL(upper(lp.OT),'bla-bla')
							and p.BirthDay=lp.DR				
		where p.OKATO='18000' and p.DateEnd>=s.DateEnd and lp.FAM is null
		union all
		select distinct p.rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,lp.Q as SMO,p.OKATO,5
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
group by t.rf_idRecordCaseBack,t.rf_idF008,t.SeriaPolis,t.NumberPolis,t.SMO,t.OKATO,typeQuery