declare @idFile int=28
declare @property tinyint=2

declare @fileName varchar(29),
		@idFileBack int,
		@idRegisterCaseBack int
declare @idRecordCaseBack as table(rf_idRecordCaseBack int,rf_idCase bigint)

--имя реестра СП и ТК
select @fileName=dbo.fn_GetFileNameBack(@idFile)


declare @CaseDefined TVP_CasePatient,--общая
		@CaseDefined1 TVP_CasePatient,--для местных
		@CaseDefined2 TVP_CasePatient --для иногородних

insert @CaseDefined(rf_idCase,ID_Patient)
select rf_idCase,rf_idRegisterPatient
from t_RefCasePatientDefine
where rf_idFiles=@idFile and (IsUnloadIntoSP_TK is null)


begin transaction
--begin try
	--помечаем случаи из таблицы итерации, которые были отданы в Реестре СП и ТК
	update t_RefCasePatientDefine
	set IsUnloadIntoSP_TK=1
	from t_RefCasePatientDefine rf inner join @CaseDefined cd on
				rf.rf_idCase=cd.rf_idCase and
				rf.rf_idRegisterPatient=cd.ID_Patient



 insert t_FileBack(rf_idFiles,FileNameHRBack) values(@idFile,@fileName)
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
		
--т.к. определение страховой может быть как в таблице t_CaseDefine или t_CaseDefineZP1Found		
insert t_PatientBack(rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,rf_idSMO,OKATO)
select rcb.rf_idRecordCaseBack,c.rf_idF008,c.SPolicy,c.NPolcy,c.SMO,18000
from @CaseDefined cd inner join t_RefCasePatientDefine rf on
			cd.rf_idCase=rf.rf_idCase
					  inner join t_CaseDefine c on
			rf.id=c.rf_idRefCaseIteration
					  inner join t_CasePatientDefineIteration i on
			rf.id=i.rf_idRefCaseIteration
			and i.rf_idIteration=3
						inner join @idRecordCaseBack rcb on
			cd.rf_idCase=rcb.rf_idCase
			
--вставляем записи по которым определена страховая принадлежность на 2 и 4 шаге.
--если человек иногородний то заменяем на значение по умолчанию			
--insert t_PatientBack(rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,rf_idSMO,OKATO)
select distinct rcb.rf_idRecordCaseBack,cast(c.TypePolicy as tinyint),c.SPolicy,c.NPolcy,
		case when isnull(c.OKATO,'00000')='18000' then s.SMOKOD else '34' end,
		case when isnull(c.OKATO,'00000')='18000' then c.OKATO else '00000' end,cd.rf_idCase,s.SMOKOD,c.OKATO,c.OGRN_SMO
from @CaseDefined cd inner join t_RefCasePatientDefine rf on
			cd.rf_idCase=rf.rf_idCase
					  inner join t_CaseDefineZP1Found c on
			rf.id=c.rf_idRefCaseIteration
					  inner join t_CasePatientDefineIteration i on
			rf.id=i.rf_idRefCaseIteration
			and i.rf_idIteration in (2,4)
						inner join @idRecordCaseBack rcb on
			cd.rf_idCase=rcb.rf_idCase
						left join dbo.vw_sprSMOGlobal s on
			c.OGRN_SMO=s.OGRN
			and c.OKATO=s.OKATO
where (OGRN_SMO is not null) and (NPolcy is not null)

insert t_PatientBack(rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,rf_idSMO,OKATO)
select distinct rcb.rf_idRecordCaseBack,rc.rf_idF008,rc.SeriaPolis,rc.NumberPolis,'00','00000'
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
			--			inner join t_RegistersCase reg on
			--rc.rf_idRegistersCase=reg.id					
where (OGRN_SMO is null) and (NPolcy is null)			
			
-------------------------------------------------------------------------------------------------------
 insert t_CaseBack(rf_idRecordCaseBack,TypePay)		
 select rcb.rf_idRecordCaseBack,(case when e.ErrorNumber is null then 1 else 2 end) as TypePay
 from @CaseDefined cd inner join @idRecordCaseBack rcb on
			cd.rf_idCase=rcb.rf_idCase
					  left join t_ErrorProcessControl e on
			cd.rf_idCase=e.rf_idCase and
			e.rf_idFile=@idFile

	rollback transaction

	--commit transaction
go