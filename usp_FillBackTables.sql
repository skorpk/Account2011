use RegisterCases
go
--------------------------------------------------------------------------------------------------------------
if OBJECT_ID('usp_FillBackTables',N'P') is not null
	drop proc usp_FillBackTables
go			
create proc usp_FillBackTables
			@CaseDefined TVP_CasePatient READONLY,		
			@idFile int,
			@property tinyint	
as
declare @fileName varchar(29),
		@idFileBack int,
		@idRegisterCaseBack INT,
		@version VARCHAR(5)
		
declare @idRecordCaseBack as table(rf_idRecordCaseBack int,rf_idCase bigint)

--имя реестра СП и ТК
select @fileName=dbo.fn_GetFileNameBack(@idFile)

INSERT dbo.t_FileBackNumberOrder( FILENAMEBack) VALUES(@fileName)

SELECT @version=(CASE WHEN ReportYear<2014 THEN '1.2' ELSE '2.11' END) from t_RegistersCase c where c.rf_idFiles=@idFile

begin transaction
begin try
	--помечаем случаи из таблицы итерации, которые были отданы в Реестре СП и ТК
	update t_RefCasePatientDefine
	set IsUnloadIntoSP_TK=1
	from t_RefCasePatientDefine rf inner join @CaseDefined cd on
				rf.rf_idCase=cd.rf_idCase and
				rf.rf_idRegisterPatient=cd.ID_Patient
	where cd.ID_Patient is not null --добавил фильтр т.к. записи с ID_Patient =null не участвуют в определении страховой принадлежности


 insert t_FileBack(rf_idFiles,FileVersion,FileNameHRBack) values(@idFile,@version,@fileName)
 select @idFileBack=SCOPE_IDENTITY()
 
 insert t_RegisterCaseBack(rf_idFilesBack,ref_idF003,ReportYear,ReportMonth,DateCreate,NumberRegister,PropertyNumberRegister)
 select @idFileBack,c.rf_idMO,c.ReportYear,c.ReportMonth,GETDATE(),NumberRegister,@property
 from t_RegistersCase c
 where c.rf_idFiles=@idFile
 
 select @idRegisterCaseBack=SCOPE_IDENTITY()
 
 --изменения от 17.02.2012 брать случаи для реестра СП и ТК откинутые на ТК1 и соответственно данные случаи не были отправлены на определение СМО
 insert t_RecordCaseBack(rf_idRecordCase,rf_idRegisterCaseBack,rf_idCase)
	output inserted.id,inserted.rf_idCase into @idRecordCaseBack
 select c.rf_idRecordCase,@idRegisterCaseBack as idRegisterCaseBack,c.id
 from @CaseDefined cd inner join t_Case c on
				cd.rf_idCase=c.id

---Получаем  код МО приписки человека
--Вступает в силу с 01.01.2013
 insert t_PatientBack(rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,rf_idSMO,OKATO,AttachCodeM)
 select c.rf_idRecordCaseBack,c.rf_idF008,c.SPolicy,c.NPolicy,c.SMO,c.OKATO,c.AttachCodeM
 from (
		 select rcb.rf_idRecordCaseBack,c.rf_idF008,case when c.rf_idF008 IN (3,4) then null else c.SPolicy end as SPolicy
				,case when c.rf_idF008 IN(3,4) then COALESCE(c.UniqueNumberPolicy,c.NPolcy) else c.NPolcy end as NPolicy
				,c.SMO
				,'18000' as OKATO
				,c.AttachCodeM
		 from @CaseDefined cd inner join t_RefCasePatientDefine rf on
					cd.rf_idCase=rf.rf_idCase
							  inner join t_CaseDefine c on
					rf.id=c.rf_idRefCaseIteration
								inner join @idRecordCaseBack rcb on
					cd.rf_idCase=rcb.rf_idCase
		 union all
		 select rcb.rf_idRecordCaseBack, r.rf_idF008,r.SeriaPolis,r.NumberPolis,isnull(p.rf_idSMO,'00')
				, case when p.rf_idSMO is null then '00000' else isnull(p.OKATO,'00000')end
				,'000000'
		 from t_RegistersCase a inner join t_RecordCase r on
							a.id=r.rf_idRegistersCase
							and a.rf_idFiles=@idFile
										inner join t_PatientSMO p on
							r.id=p.ref_idRecordCase
										inner join t_Case c on
							r.id=c.rf_idRecordCase
										inner join @idRecordCaseBack rcb on
							c.id=rcb.rf_idCase
										inner join @CaseDefined cd on
							c.id=cd.rf_idCase
										left join t_RefCasePatientDefine rd on
							c.id=rd.rf_idCase
							and rd.rf_idFiles=@idFile
		 where rd.id is null
	) c
		
 insert t_CaseBack(rf_idRecordCaseBack,TypePay)		
 select rcb.rf_idRecordCaseBack,(case when e.ErrorNumber is null then 1 else 2 end) as TypePay
 from @CaseDefined cd inner join @idRecordCaseBack rcb on
			cd.rf_idCase=rcb.rf_idCase
					  left join t_ErrorProcessControl e on
			cd.rf_idCase=e.rf_idCase and
			e.rf_idFile=@idFile
---конец обработки
--возвращаем id файла реестра СП и ТК
	select @idFileBack
 

end try
begin catch
if @@TRANCOUNT>0
	select ERROR_MESSAGE()
	rollback transaction
end catch
if @@TRANCOUNT>0
	commit transaction
go