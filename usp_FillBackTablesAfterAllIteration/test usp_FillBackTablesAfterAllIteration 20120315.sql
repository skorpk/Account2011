use RegisterCases
go
declare @idFile int=4568,
		@codeLPU char(5)='136003',
		@month tinyint=2,
		@year smallint=2012,
		@idRegisterCaseBack int=8651

declare @CaseDefined2 TVP_CasePatient,
		@CaseDefined TVP_CasePatient
declare @t1 as table(rf_idCase bigint,idRecordCase int,Quantity decimal(11,2),unitCode int,TotalRest int)

declare @idRecordCaseBack as table(rf_idRecordCaseBack int,rf_idCase bigint)

insert @CaseDefined(rf_idCase,ID_Patient)
select rf_idCase,rf_idRegisterPatient
from t_RefCasePatientDefine rf inner join t_CasePatientDefineIteration i on
			rf.id=i.rf_idRefCaseIteration
			and i.rf_idIteration in (2,3,4)	
where rf_idFiles=@idFile

insert @CaseDefined2(rf_idCase,ID_Patient)
select rf.rf_idCase,rf.rf_idRegisterPatient
from t_RefCasePatientDefine rf inner join t_CaseDefineZP1Found c on
			rf.id=c.rf_idRefCaseIteration
			and c.OKATO is not null
			and c.OKATO!='18000'							
							inner join t_CasePatientDefineIteration i on
			rf.id=i.rf_idRefCaseIteration
			and i.rf_idIteration in (2,4)		  
where rf.rf_idFiles=@idFile

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
								inner join t_CasePatientDefineIteration i on
			rf.id=i.rf_idRefCaseIteration
			and i.rf_idIteration=4
where rf.rf_idFiles=@idFile 

select distinct e.*
from t_ErrorProcessControl e inner join @CaseDefined2 cd on
			e.rf_idCase=cd.rf_idCase
			
select *
delete from t_ErrorProcessControl where rf_idFile=4568
/*

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

insert @idRecordCaseBack 
select r.id,r.rf_idCase
from t_FileBack f inner join t_RegisterCaseBack a on
		f.id=a.rf_idFilesBack		
						inner join t_RecordCaseBack r on
		a.id=r.rf_idRegisterCaseBack
		
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
select rcb.rf_idRecordCaseBack,cast(c.TypePolicy as tinyint)
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
*/