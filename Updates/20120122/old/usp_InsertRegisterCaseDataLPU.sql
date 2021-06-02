USE [RegisterCases]
GO

/****** Object:  StoredProcedure [dbo].[usp_InsertRegisterCaseDataLPU]    Script Date: 01/22/2012 13:34:37 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_InsertRegisterCaseDataLPU]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_InsertRegisterCaseDataLPU]
GO

USE [RegisterCases]
GO

/****** Object:  StoredProcedure [dbo].[usp_InsertRegisterCaseDataLPU]    Script Date: 01/22/2012 13:34:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[usp_InsertRegisterCaseDataLPU]
			@doc xml,
			@patient xml,
			@file varbinary(max),
			@countSluch int
as
DECLARE @idoc int,
		@ipatient int,
		@id int,
		@idFile int
/* 
1.процедура разбирает xml потоки и раскладывает данные по таблицам. 
2. производим определение страховой принадлежности на РС ЕРЗ( процедура usp_DefineSMOIteration1_3). 
3. на случаях по которым определена страховая принадлежность производим технологический контроль (процедура usp_RunProcessControl)
4. формируем реестр СП и ТК т.е. раскладываем данные по таблицам из которых затем формируется реестр СП и ТК (usp_FillBackTables).
5. случаи по которым не определена страховая принадлежность раскладываются по таблицам для отправки в ЦС ЕРЗ (процедура usp_DefineSMOIteration2_4)
6. вслучае отката транзакции возвращается сообщение об ошибку и транзакции откатываются.

*/
---create tempory table----------------------------------------------

declare @t1 as table([VERSION] char(5),DATA date,[FILENAME] varchar(26))

declare @t2 as table(CODE int,CODE_MO int,[YEAR] smallint,[MONTH] tinyint,NSCHET int,DSCHET date,SUMMAV numeric(11, 2),COMENTS nvarchar(250)) 

declare @t3 as table(N_ZAP int,PR_NOV tinyint,ID_PAC nvarchar(36),VPOLIS tinyint,SPOLIS nchar(10),NPOLIS nchar(20),SMO nchar(5),NOVOR nchar(9))


declare @t5 as table(N_ZAP int,ID_PAC nvarchar(36),IDCASE int,ID_C uniqueidentifier,USL_OK tinyint,VIDPOM smallint,NPR_MO nchar(6),EXTR tinyint,LPU nchar(6),PROFIL smallint,
					 DET tinyint,NHISTORY nvarchar(50),DATE_1 date,DATE_2 date,DS0 nchar(10),DS1 nchar(10),DS2 nchar(10),CODE_MES1 nchar(16),RSLT smallint,
					 ISHOD smallint,PRVS bigint,OS_SLUCH tinyint,IDSP tinyint,ED_COL numeric(5, 2),TARIF numeric(15, 2),SUMV numeric(15, 2),REFREASON tinyint,
					 SANK_MEK numeric(15, 2),SANK_MEE numeric(15, 2),SANK_EKMP numeric(15, 2),COMENTSL nvarchar(250))
					 
declare @t6 as table (ID_C uniqueidentifier,IDSERV int,ID_U uniqueidentifier,LPU nchar(6),PROFIL smallint,DET tinyint,DATE_IN date,DATE_OUT date,
					   DS nchar(10),CODE_USL nchar(16),KOL_USL numeric(6, 2),TARIF numeric(15, 2),SUMV_USL numeric(15, 2),PRVS bigint,COMENTU nvarchar(250))
					   
declare @t7 as table([VERSION] nchar(5),DATA date,[FILENAME] nchar(26),FILENAME1 nchar(26))

declare @t8 as table(ID_PAC nvarchar(36),FAM nvarchar(40),IM nvarchar(40),OT nvarchar(40),W tinyint,DR date,FAM_P nvarchar(40),IM_P nvarchar(40),OT_P nvarchar(40),
					W_P tinyint,DR_P date,MR nvarchar(100),DOCTYPE nchar(2),DOCSER nchar(10),DOCNUM nchar(20),SNILS nchar(14),OKATOG nchar(11),OKATOP nchar(11),
					COMENTP nvarchar(250))

declare @tempID as table(id int, ID_PAC nvarchar(36),N_ZAP int)

declare @tableId as table(id int,ID_PAC nvarchar(36))
---------------------------------------------------------------------
EXEC sp_xml_preparedocument @idoc OUTPUT, @doc

insert @t1
SELECT [version],REPLACE(DATA,'-',''),[FILENAME]
FROM OPENXML (@idoc, 'ZL_LIST/ZGLV',2)
	WITH(
			[VERSION] NCHAR(5) './VERSION',
			[DATA] NCHAR(10) './DATA',
			[FILENAME] NCHAR(26) './FILENAME'
		)
		
insert @t2
select CODE,CODE_MO,[YEAR],[MONTH],NSCHET,replace(DSCHET,'-',''),SUMMAV,COMENTS
FROM OPENXML (@idoc, 'ZL_LIST/SCHET',2)
	WITH 
	(	
		CODE int './CODE',
		CODE_MO int './CODE_MO',
		[YEAR]	smallint './YEAR',
		[MONTH] tinyint './MONTH',
		NSCHET int './NSCHET',
		DSCHET nchar(10) './DSCHET',
		SUMMAV decimal(11,2) './SUMMAV',
		COMENTS nvarchar(250) './COMENTS'		
	)
	
insert @t3
SELECT N_ZAP,PR_NOV,ID_PAC,VPOLIS,SPOLIS,NPOLIS,SMO,NOVOR
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/PACIENT',2)
	WITH(
			N_ZAP int '../N_ZAP',
			PR_NOV tinyint '../PR_NOV',
			ID_PAC nvarchar(36),
			VPOLIS tinyint ,
			SPOLIS nchar(10),
			NPOLIS nchar(20),
			SMO nchar(5) ,
			NOVOR nchar(9) 
		)


insert @t5
SELECT N_ZAP,ID_PAC,IDCASE,ID_C,USL_OK,VIDPOM,NPR_MO,EXTR,LPU,PROFIL,DET,NHISTORY,replace(DATE_1,'-',''),replace(DATE_2,'-',''),DS0,DS1,DS2,CODE_MES1,RSLT,ISHOD,
		PRVS,OS_SLUCH,IDSP,ED_COL,TARIF,SUMV,REFREASON,SANK_MEK,SANK_MEE,SANK_EKMP,COMENTSL
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/SLUCH',3)
	WITH(
			N_ZAP int '../N_ZAP',
			ID_PAC nvarchar(36) '../PACIENT/ID_PAC',
			IDCASE int ,
			ID_C uniqueidentifier,
			USL_OK tinyint ,
			VIDPOM smallint,
			NPR_MO nchar(6),
			EXTR tinyint ,
			LPU nchar(6) ,
			PROFIL smallint,
			DET tinyint ,
			NHISTORY nvarchar(50) ,
			DATE_1 nchar(10) ,
			DATE_2 nchar(10) ,
			DS0 nchar(10) ,
			DS1 nchar(10) ,
			DS2 nchar(10) ,
			CODE_MES1 nchar(16) ,			
			RSLT smallint ,
			ISHOD smallint,
			PRVS bigint ,
			OS_SLUCH tinyint ,
			IDSP TINYINT ,
			ED_COL DECIMAL(5,2) ,
			TARIF DECIMAL(15,2) ,	
			SUMV DECIMAL(15,2) ,	
			REFREASON TINYINT ,
			SANK_MEK DECIMAL(15,2),
			SANK_MEE DECIMAL(15,2),
			SANK_EKMP DECIMAL(15,2),
			COMENTSL NVARCHAR(250) 
		)

insert @t6
SELECT ID_C,IDSERV,ID_U,LPU,PROFIL,DET,replace(DATE_IN,'-',''),replace(DATE_OUT,'-',''),DS,CODE_USL,KOL_USL,TARIF,SUMV_USL,PRVS,COMENTU
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/SLUCH/USL',3)
	WITH(
			ID_C uniqueidentifier '../ID_C',
			IDSERV INT ,
			ID_U uniqueidentifier ,
			LPU nchar(6) ,
			PROFIL smallint,
			DET tinyint ,
			DATE_IN nchar(10),
			DATE_OUT nchar(10),
			DS nchar(10),
			CODE_USL nchar(16),
			KOL_USL DECIMAL(6,2),
			TARIF DECIMAL(15,2) ,	
			SUMV_USL DECIMAL(15,2),	
			PRVS bigint ,
			COMENTU NVARCHAR(250) 
		)
EXEC sp_xml_removedocument @idoc

---------------Patient----------------------------------
EXEC sp_xml_preparedocument @ipatient OUTPUT, @patient

insert @t7
SELECT [VERSION],replace(DATA,'-',''),[FILENAME],FILENAME1
FROM OPENXML (@ipatient, 'PERS_LIST/ZGLV',2)
	WITH(
			[VERSION] NCHAR(5) './VERSION',
			[DATA] NCHAR(10) './DATA',
			[FILENAME] NCHAR(26) './FILENAME',
			[FILENAME1] NCHAR(26) './FILENAME1'
		)
		
insert @t8
SELECT ID_PAC,FAM,IM,OT,W,replace(DR,'-',''),FAM_P,IM_P,OT_P,W_P,replace(DR_P,'-',''),MR,DOCTYPE,DOCSER,DOCNUM,SNILS,OKATOG,OKATOP,COMENTP
FROM OPENXML (@ipatient, 'PERS_LIST/PERS',2)
	WITH(
			ID_PAC NVARCHAR(36),
			FAM NVARCHAR(40),
			IM NVARCHAR(40),
			OT NVARCHAR(40),
			W TINYINT,
			DR NCHAR(10),
			FAM_P NVARCHAR(40),
			IM_P NVARCHAR(40),
			OT_P NVARCHAR(40),
			W_P TINYINT,
			DR_P NCHAR(10),
			MR NVARCHAR(100),
			DOCTYPE NCHAR(2),
			DOCSER NCHAR(10),
			DOCNUM NCHAR(20),
			SNILS NCHAR(14),
			OKATOG NCHAR(11),
			OKATOP NCHAR(11),
			COMENTP NVARCHAR(250)
		)		

EXEC sp_xml_removedocument @ipatient

--select * into t1 from @t1
--select * into t2 from @t2
--select * into t3 from @t3
--select * into t5 from @t5
--select * into t6 from @t6
--select * into t7 from @t7
--select * into t8 from @t8

declare @month tinyint,
		@year smallint,
		@codeLPU char(6)

begin transaction
begin try
------Insert into RegisterCase's tables------------------------------
insert t_FileTested(DateRegistration,[FileName],UserName) select GETDATE(),[FILENAME],ORIGINAL_LOGIN() from @t1

select @id=SCOPE_IDENTITY()

insert t_File(DateRegistration,FileVersion,DateCreate,FileNameHR,FileNameLR,rf_idFileTested,FileZIP,CountSluch)
select GETDATE(),[VERSION],DATA,FILENAME1,[FILENAME],@id,@file,@countSluch  from @t7

select @idFile=SCOPE_IDENTITY()

insert t_RegistersCase(rf_idFiles,idRecord,rf_idMO,ReportYear,ReportMonth,NumberRegister,DateRegister,AmountPayment,Comments)
select @idFile,CODE,CODE_MO,[YEAR],[MONTH],NSCHET,DSCHET,SUMMAV,COMENTS from @t2


select @id=SCOPE_IDENTITY()

insert t_RecordCase(rf_idRegistersCase,idRecord,IsNew,ID_Patient,rf_idF008,SeriaPolis,NumberPolis,NewBorn)
output inserted.id,inserted.ID_Patient,inserted.idRecord into @tempID
select @id,N_ZAP,PR_NOV,ID_PAC,VPOLIS,SPOLIS,NPOLIS,NOVOR from @t3 
group by N_ZAP,PR_NOV,ID_PAC,VPOLIS,SPOLIS,NPOLIS,NOVOR

insert t_PatientSMO(ref_idRecordCase,rf_idSMO)
select t2.id,t1.SMO
from @t3 t1 inner join @tempID t2 on
			t1.ID_PAC=t2.ID_PAC and
			t1.N_ZAP=t2.N_ZAP
where t1.SMO is not null
group by t2.id,t1.SMO

insert t_Case(rf_idRecordCase, idRecordCase, GUID_Case, rf_idV006, rf_idV008, rf_idDirectMO, HopitalisationType, rf_idMO, rf_idV002, IsChildTariff, 
				NumberHistoryCase, DateBegin, DateEnd, rf_idV009, rf_idV012, rf_idV004, IsSpecialCase, rf_idV010, AmountPayment, Comments,Age)
select t2.id,t1.IDCASE,t1.ID_C, t1.USL_OK,t1.VIDPOM, t1.NPR_MO,t1.EXTR,t1.LPU,t1.PROFIL,t1.DET,t1.NHISTORY,t1.DATE_1,t1.DATE_2,t1.RSLT,t1.ISHOD,
		t1.PRVS,t1.OS_SLUCH,t1.IDSP,t1.SUMV,t1.COMENTSL,dbo.fn_FullYear(t3.DR,t1.DATE_1)		
from @t5 t1 inner join @tempID t2 on
		t1.N_ZAP=t2.N_ZAP and
		t1.ID_PAC=t2.ID_PAC
			left join @t8 t3 on
		t1.ID_PAC=t3.ID_PAC
group by t2.id,t1.IDCASE,t1.ID_C, t1.USL_OK,t1.VIDPOM, t1.NPR_MO,t1.EXTR,t1.LPU,t1.PROFIL,t1.DET,t1.NHISTORY,t1.DATE_1,t1.DATE_2,t1.RSLT,t1.ISHOD,
		t1.PRVS,t1.OS_SLUCH,t1.IDSP,t1.SUMV,t1.COMENTSL,dbo.fn_FullYear(t3.DR,t1.DATE_1)
			
			
------------------------------------------------------------------------------------------------------------------
insert t_Diagnosis(DiagnosisCode,rf_idCase,TypeDiagnosis)
select DS0,c.id,2 
from t_Case c inner join @t5 t1 on
		c.GUID_Case=t1.ID_C
where DS0 is not null
union all
select DS1,c.id,1 
from t_Case c inner join @t5 t1 on
		c.GUID_Case=t1.ID_C
union all
select DS2,c.id,3 
from t_Case c inner join @t5 t1 on
		c.GUID_Case=t1.ID_C		
where DS2 is not null
--------------------------------------------------------------------------------------------------------------------

insert t_MES(MES,rf_idCase,TypeMES,Quantity,Tariff)
select t1.CODE_MES1,c.id,1,t1.ED_COL,t1.TARIF
from t_Case c inner join @t5 t1 on
		c.GUID_Case=t1.ID_C
where t1.CODE_MES1 is not null
---------------------------------------------------------------------------------------------------------------------

insert t_ReasonPaymentCancelled(rf_idCase,rf_idPaymentAccountCanseled)
select c.id,t1.REFREASON
from t_Case c inner join @t5 t1 on
		c.GUID_Case=t1.ID_C
where t1.REFREASON is not null
----------------------------------------------------------------------------------------------------------------------
insert t_FinancialSanctions(rf_idCase,Amount,TypeSanction)
select c.id,t1.SANK_MEK,1
from t_Case c inner join @t5 t1 on
		c.GUID_Case=t1.ID_C
where t1.SANK_MEK is not null
union all
select c.id,t1.SANK_MEE,2
from t_Case c inner join @t5 t1 on
		c.GUID_Case=t1.ID_C
where t1.SANK_MEE is not null
union all
select c.id,t1.SANK_EKMP,3
from t_Case c inner join @t5 t1 on
		c.GUID_Case=t1.ID_C
where t1.SANK_EKMP is not null

-------------------------------------------------------------------------------------------------------------------------

insert t_Meduslugi(rf_idCase,id,GUID_MU,rf_idMO, rf_idV002, IsChildTariff, DateHelpBegin, DateHelpEnd, DiagnosisCode, 
					MUCode, Quantity, Price, TotalPrice, rf_idV004, Comments)
select c.id,t1.IDSERV, t1.ID_U, t1.LPU, t1.PROFIL, t1.DET,t1.DATE_IN,t1.DATE_OUT,t1.DS,t1.CODE_USL,t1.KOL_USL,t1.TARIF,t1.SUMV_USL,t1.PRVS,t1.COMENTU
from @t6 t1 inner join t_Case c on
			t1.ID_C=c.GUID_Case
where t1.ID_U is not null
group by c.id,t1.IDSERV, t1.ID_U, t1.LPU, t1.PROFIL, t1.DET,t1.DATE_IN,t1.DATE_OUT,t1.DS,t1.CODE_USL,t1.KOL_USL,t1.TARIF,t1.SUMV_USL,t1.PRVS,t1.COMENTU
----------------------------------------------------------------------------------------------------------------------
-----изменения от 22.01.2012-------------------------------------------------------------------
--insert t_RegisterPatient(rf_idFiles, ID_Patient, Fam, Im, Ot, rf_idV005, BirthDay, BirthPlace,rf_idRecordCase)
--	output inserted.id,inserted.ID_Patient into @tableId
--select @idFile,t1.ID_PAC,t1.FAM,t1.IM,case when t1.OT='НЕТ' then null else t1.OT end,t1.W,t1.DR,t1.MR,t2.id
--from @t8 t1 left join @tempID t2 on
--				t1.ID_PAC=t2.ID_PAC
--group by t1.ID_PAC,t1.FAM,t1.IM,case when t1.OT='НЕТ' then null else t1.OT end,t1.W,t1.DR,t1.MR,t2.id

insert t_RegisterPatient(rf_idFiles, ID_Patient, Fam, Im, Ot, rf_idV005, BirthDay, BirthPlace)
	output inserted.id,inserted.ID_Patient into @tableId
select @idFile,t1.ID_PAC,t1.FAM,t1.IM,case when t1.OT='НЕТ' then null else t1.OT end,t1.W,t1.DR,t1.MR
from @t8 t1 
group by t1.ID_PAC,t1.FAM,t1.IM,case when t1.OT='НЕТ' then null else t1.OT end,t1.W,t1.DR,t1.MR

insert t_RefRegisterPatientRecordCase(rf_idRecordCase,rf_idRegisterPatient)
select t2.id,t1.id
from  @tableId t1 inner join @tempID t2 on
				t1.ID_PAC=t2.ID_PAC
-----изменения от 22.01.2012-------------------------------------------------------------------

insert t_RegisterPatientDocument(rf_idRegisterPatient, rf_idDocumentType, SeriaDocument, NumberDocument, SNILS, OKATO, OKATO_Place, Comments)
select t2.id,t1.DOCTYPE,t1.DOCSER,t1.DOCNUM,t1.SNILS,t1.OKATOG,t1.OKATOP,t1.COMENTP
from @t8 t1 inner join @tableId t2 on
		t1.ID_PAC=t2.ID_PAC
where (t1.DOCTYPE is not null) or (t1.DOCSER is not null) or (t1.DOCNUM is not null)
group by t2.id,t1.DOCTYPE,t1.DOCSER,t1.DOCNUM,t1.SNILS,t1.OKATOG,t1.OKATOP,t1.COMENTP

insert t_RegisterPatientAttendant(rf_idRegisterPatient, Fam, Im, Ot, rf_idV005, BirthDay)
select t2.id,t1.FAM_P,t1.IM_P,t1.OT_P,t1.W_P,t1.DR_P
from @t8 t1 inner join @tableId t2 on
		upper(t1.ID_PAC)=upper(t2.ID_PAC)
where (t1.FAM_P is not null) and (t1.IM_P is not null) and (t1.W_P is not null) and (t1.DR_P is not null)
group by t2.id,t1.FAM_P,t1.IM_P,t1.OT_P,t1.W_P,t1.DR_P
end try
begin catch
	select ERROR_MESSAGE()
	select 'Error'
	if @@TRANCOUNT>0
	rollback transaction
goto Exit1--выходим из обработки данных
end catch
if @@TRANCOUNT>0
	commit transaction
	
	
------------------------------------------Определение страховой принадлежности на наш регистр---------------------
begin try
	declare @RecordCase as TVP_CasePatient,
			@idRecordCaseNext as TVP_CasePatient,
			@CaseDefined as TVP_CasePatient,
			@fileL varchar(26)=(select t.FILENAME1 from @t7 t)--имя файла для добавлениея в таблицу PolicyRegister.dbo.ZP1LOG
			
-----изменения от 22.01.2012-------------------------------------------------------------------	
	--insert @RecordCase	
	--select c.id as rf_idCase,p.id as rf_idPatient 
	--from @tempID rc inner join t_Case c on
	--		rc.id=c.rf_idRecordCase
	--				  left join t_RegisterPatient p on
	--		rc.id=p.rf_idRecordCase and
	--		rc.ID_PAC=p.ID_Patient
			
			insert @RecordCase	
		select c.id as rf_idCase,p.id as rf_idPatient 
		from @tempID rc inner join t_Case c on
				rc.id=c.rf_idRecordCase
						  left join vw_RegisterPatient p on
				rc.id=p.rf_idRecordCase and
				rc.ID_PAC=p.ID_Patient
-----изменения от 22.01.2012-------------------------------------------------------------------			
	
--определение сстраховой принадлежности в РС ЕРЗ на 1-ой итерации.
--возвращает id ненайденых пациентов(по которым не определена страховая принадлежность)
--данные необходимо для того что бы определить страховую принадлежность на ЦС ЕРЗ на 2-ой итерации
--добавил в качестве параметра передачу id файла входящего
	
	insert @idRecordCaseNext
	exec usp_DefineSMOIteration1_3 @RecordCase,@iteration=1,@id=@idFile
	
--параметры которые подаются в процедуру, выполняющую технологический контроль
	insert @CaseDefined(rf_idCase,ID_Patient)
	select t.rf_idCase,t.ID_Patient
	from @RecordCase t left join @idRecordCaseNext t1 on
				t.rf_idCase=t1.rf_idCase and 
				t.ID_Patient=t1.ID_Patient
	where t1.rf_idCase is null
	
	if EXISTS(select * from @CaseDefined)
	begin	
	
		--процедура выполняющая тех.контроль, определение плана заказов и т.д.
		exec usp_RunProcessControl @CaseDefined,@idFile
		
		--раскладываем данные по таблицам для формирования реестров СП и ТК
		declare @property tinyint
		
		select @property=(case when COUNT(*)=0 then 0 else 1 end)
		from t_RegistersCase r inner join t_RecordCase rc on
				r.id=rc.rf_idRegistersCase
							inner join t_Case c on
				rc.id=c.rf_idRecordCase
							left join @CaseDefined cd on
				c.id=cd.rf_idCase
		where r.rf_idFiles=@idFile and cd.rf_idCase is null
		
		declare @tReturnVal as table(idFileBack int)
		
		insert @tReturnVal
		exec usp_FillBackTables @CaseDefined,@idFile,@property
		
		declare @idFileBack int
		select @idFileBack=idFileBack from @tReturnVal
		
		-------------------------возвращаем данные для формирования реестра СП и ТК--------------------------------
		exec usp_RegisterSP_TK @idFileBack
	end	
	
	--------------------------------данные для отчета по плану заказов---------------------------------------------
	if @idFileBack is not null		
	begin
		select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear
		from t_FileBack f inner join t_RegisterCaseBack rc on
					f.id=rc.rf_idFilesBack
							inner join oms_nsi.dbo.vw_sprT001 v on
					f.CodeM=v.CodeM		
		where f.id=@idFileBack
		
		insert t_PlanOrdersReport(rf_idFile,rf_idFileBack,CodeLPU,UnitCode,Vm,Vdm,Spred,MonthReport,YearReport)
		select @idFile,@idFileBack,f.CodeLPU,f.UnitCode,f.Vm,f.Vdm,f.Spred,@month,@year
		from dbo.fn_PlanOrders(@codeLPU,@month,@year) f
	end
	------------------------------------------------------------------------------------------------------------------	
	
	select @idFile,@idFileBack
		
	declare @fileName varchar(26)
	select @fileName=[FILENAME] from @t1
	
--определение страховой принадлежности на 2 и 4 итерации.Пока отключил ее для тестирования

	if EXISTS(select * from @idRecordCaseNext)
	begin
		exec usp_DefineSMOIteration2_4 @idRecordCaseNext,2,@fileName
	end
	--если все прошло хорошо 
	select 'Good'
	
end try
begin catch
select ERROR_MESSAGE()
--при ошибке производим откат данных 
if isnull(@idFile,0)<>0
begin
	exec usp_RegisterCaseDelete @idFile
	select 'Error'
end

end catch
Exit1:

GO

