USE RegisterCases
go
IF OBJECT_ID('usp_InsertRegisterCaseDataLPU_test',N'P') IS NOT NULL
DROP PROC usp_InsertRegisterCaseDataLPU_test
GO
create proc usp_InsertRegisterCaseDataLPU_test
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

create table #t3(
				    N_ZAP int,PR_NOV tinyint,ID_PAC nvarchar(36),VPOLIS tinyint,
					SPOLIS nchar(10),NPOLIS nchar(20),SMO nchar(5),SMO_OK nchar(5),SMO_NAM nvarchar(100),NOVOR nchar(9),MO_PR nchar(6)
					)


create table #t5(N_ZAP int,ID_PAC nvarchar(36),IDCASE int,ID_C uniqueidentifier,USL_OK tinyint,VIDPOM smallint,NPR_MO nchar(6),EXTR tinyint,LPU nchar(6),PROFIL smallint,
					 DET tinyint,NHISTORY nvarchar(50),DATE_1 date,DATE_2 date,DS0 nchar(10),DS1 nchar(10),DS2 nchar(10),CODE_MES1 nchar(16),RSLT smallint,
					 ISHOD smallint,PRVS bigint,OS_SLUCH tinyint,IDSP tinyint,ED_COL numeric(5, 2),TARIF numeric(15, 2),SUMV numeric(15, 2),REFREASON tinyint,
					 SANK_MEK numeric(15, 2),SANK_MEE numeric(15, 2),SANK_EKMP numeric(15, 2),COMENTSL nvarchar(250),F_SP tinyint)
					 
create table #t6(IDCASE int,ID_C uniqueidentifier,IDSERV int,ID_U uniqueidentifier,LPU nchar(6),PROFIL smallint,DET tinyint,DATE_IN date,DATE_OUT date,
					   DS nchar(10),CODE_USL nchar(16),KOL_USL numeric(6, 2),TARIF numeric(15, 2),SUMV_USL numeric(15, 2),PRVS bigint,COMENTU nvarchar(250),PODR int)
					   
declare @t7 as table([VERSION] nchar(5),DATA date,[FILENAME] nchar(26),FILENAME1 nchar(26))

create table #t8 (ID_PAC nvarchar(36),FAM nvarchar(40),IM nvarchar(40),OT nvarchar(40),W tinyint,DR date,FAM_P nvarchar(40),IM_P nvarchar(40),OT_P nvarchar(40),
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
--добавил ОКАТО территории страхования. 04.02.2012
insert #t3
SELECT N_ZAP,PR_NOV,ID_PAC,VPOLIS,SPOLIS,NPOLIS,SMO,SMO_OK,SMO_NAM,NOVOR,MO_PR
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/PACIENT',2)
	WITH(
			N_ZAP int '../N_ZAP',
			PR_NOV tinyint '../PR_NOV',
			ID_PAC nvarchar(36),
			VPOLIS tinyint ,
			SPOLIS nchar(10),
			NPOLIS nchar(20),
			SMO nchar(5) ,
			SMO_OK nchar(5),
			SMO_NAM nvarchar(100),
			NOVOR nchar(9),
			MO_PR nchar(6) 
		)


insert #t5
SELECT N_ZAP,ID_PAC,IDCASE,ID_C,USL_OK,VIDPOM,NPR_MO,EXTR,LPU,PROFIL,DET,NHISTORY,replace(DATE_1,'-',''),replace(DATE_2,'-',''),DS0,DS1,DS2,CODE_MES1,RSLT,ISHOD,
		PRVS,OS_SLUCH,IDSP,ED_COL,TARIF,SUMV,REFREASON,SANK_MEK,SANK_MEE,SANK_EKMP,COMENTSL,F_SP
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
			COMENTSL NVARCHAR(250),
			F_SP TINYINT
		)

insert #t6
SELECT IDCASE,ID_C,IDSERV,ID_U,LPU,PROFIL,DET,replace(DATE_IN,'-',''),replace(DATE_OUT,'-',''),DS,CODE_USL,KOL_USL,TARIF,SUMV_USL,PRVS,COMENTU,PODR
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/SLUCH/USL',3)
	WITH(
			IDCASE int '../IDCASE',
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
			COMENTU NVARCHAR(250),
			PODR INT 
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
		
insert #t8
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
--select * into t3 from #t3
--select * into t5 from #t5
--select * into t6 from #t6
--select * into t7 from @t7
--select * into t8 from #t8

declare @month tinyint,
		@year smallint,
		@codeLPU char(6)
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
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
---добавить обработку ошибок по записям которые были отвергнуты на этапе ФЛК
----2012-01-02------------------
insert t_RecordCase(rf_idRegistersCase,idRecord,IsNew,ID_Patient,rf_idF008,SeriaPolis,NumberPolis,NewBorn,AttachLPU)
output inserted.id,inserted.ID_Patient,inserted.idRecord into @tempID
select @id,N_ZAP,PR_NOV,ID_PAC,VPOLIS,SPOLIS,NPOLIS,NOVOR,MO_PR
from #t3 
group by N_ZAP,PR_NOV,ID_PAC,VPOLIS,SPOLIS,NPOLIS,NOVOR,MO_PR
--12.03.2012
insert t_PatientSMO(ref_idRecordCase,rf_idSMO,OKATO,Name)
select t2.id,t1.SMO
/*case when t1.SMO_OK!='18000' and t1.SMO is null then '34' when t1.SMO_OK='18000' and t1.SMO is null then '00'	else t1.SMO end*/ 
					,t1.SMO_OK
		,case when rtrim(ltrim(t1.SMO_NAM))='' then null else t1.SMO_NAM end
from #t3 t1 inner join @tempID t2 on
			t1.ID_PAC=t2.ID_PAC and
			t1.N_ZAP=t2.N_ZAP
--where t1.SMO is not null
group by t2.id,t1.SMO,t1.SMO_OK,t1.SMO_NAM

declare @tmpCase as table(id int,idRecord int,GUID_CASE uniqueidentifier)

----2012-01-02--------------------
insert t_Case(rf_idRecordCase, idRecordCase, GUID_Case, rf_idV006, rf_idV008, rf_idDirectMO, HopitalisationType, rf_idMO, rf_idV002, IsChildTariff, 
				NumberHistoryCase, DateBegin, DateEnd, rf_idV009, rf_idV012, rf_idV004, IsSpecialCase, rf_idV010, AmountPayment, Comments,Age,[Emergency])
output inserted.id,inserted.idRecordCase,inserted.GUID_Case into @tmpCase
select t2.id,t1.IDCASE,t1.ID_C, t1.USL_OK,t1.VIDPOM, t1.NPR_MO,t1.EXTR,t1.LPU,t1.PROFIL,t1.DET,t1.NHISTORY,t1.DATE_1,t1.DATE_2,t1.RSLT,t1.ISHOD,
		t1.PRVS,t1.OS_SLUCH,t1.IDSP,t1.SUMV,t1.COMENTSL
		,DATEDIFF(YEAR,t3.DR,t1.DATE_1)-CASE WHEN 100*MONTH(t3.DR)+DAY(t3.DR)>100*MONTH(t1.DATE_1)+DAY(t1.DATE_1) THEN 1 ELSE 0 END, F_SP
from #t5 t1 inner join @tempID t2 on
		t1.N_ZAP=t2.N_ZAP and
		t1.ID_PAC=t2.ID_PAC
			left join #t8 t3 on
		t1.ID_PAC=t3.ID_PAC
group by t2.id,t1.IDCASE,t1.ID_C, t1.USL_OK,t1.VIDPOM, t1.NPR_MO,t1.EXTR,t1.LPU,t1.PROFIL,t1.DET,t1.NHISTORY,t1.DATE_1,t1.DATE_2,t1.RSLT,t1.ISHOD,
		t1.PRVS,t1.OS_SLUCH,t1.IDSP,t1.SUMV,t1.COMENTSL
		,DATEDIFF(YEAR,t3.DR,t1.DATE_1)-CASE WHEN 100*MONTH(t3.DR)+DAY(t3.DR)>100*MONTH(t1.DATE_1)+DAY(t1.DATE_1) THEN 1 ELSE 0 END,F_SP
			
			
------------------------------------------------------------------------------------------------------------------
insert t_Diagnosis(DiagnosisCode,rf_idCase,TypeDiagnosis)
select DS0,c.id,2 
from @tmpCase c inner join #t5 t1 on
		c.GUID_Case=t1.ID_C
		and c.idRecord=t1.IDCASE
where DS0 is not null
union all
select DS1,c.id,1 
from @tmpCase c inner join #t5 t1 on
		c.GUID_Case=t1.ID_C
		and c.idRecord=t1.IDCASE
union all
select DS2,c.id,3 
from @tmpCase c inner join #t5 t1 on
		c.GUID_Case=t1.ID_C	
		and c.idRecord=t1.IDCASE	
where DS2 is not null
--------------------------------------------------------------------------------------------------------------------

insert t_MES(MES,rf_idCase,TypeMES,Quantity,Tariff)
select t1.CODE_MES1,c.id,1,t1.ED_COL,t1.TARIF
from @tmpCase c inner join #t5 t1 on
		c.GUID_Case=t1.ID_C
		and c.idRecord=t1.IDCASE
where t1.CODE_MES1 is not null
group by t1.CODE_MES1,c.id,t1.ED_COL,t1.TARIF
---------------------------------------------------------------------------------------------------------------------

insert t_ReasonPaymentCancelled(rf_idCase,rf_idPaymentAccountCanseled)
select c.id,t1.REFREASON
from @tmpCase c inner join #t5 t1 on
		c.GUID_Case=t1.ID_C
		and c.idRecord=t1.IDCASE
where t1.REFREASON is not null
----------------------------------------------------------------------------------------------------------------------
insert t_FinancialSanctions(rf_idCase,Amount,TypeSanction)
select c.id,t1.SANK_MEK,1
from @tmpCase c inner join #t5 t1 on
		c.GUID_Case=t1.ID_C
		and c.idRecord=t1.IDCASE
where t1.SANK_MEK is not null
union all
select c.id,t1.SANK_MEE,2
from @tmpCase c inner join #t5 t1 on
		c.GUID_Case=t1.ID_C
		and c.idRecord=t1.IDCASE
where t1.SANK_MEE is not null
union all
select c.id,t1.SANK_EKMP,3
from @tmpCase c inner join #t5 t1 on
		c.GUID_Case=t1.ID_C
		and c.idRecord=t1.IDCASE
where t1.SANK_EKMP is not null

-------------------------------------------------------------------------------------------------------------------------

insert t_Meduslugi(rf_idCase,id,GUID_MU,rf_idMO, rf_idV002, IsChildTariff, DateHelpBegin, DateHelpEnd, DiagnosisCode, 
					MUCode, Quantity, Price, TotalPrice, rf_idV004, Comments,rf_idDepartmentMO)
select c.id,t1.IDSERV, t1.ID_U, t1.LPU, t1.PROFIL, t1.DET,t1.DATE_IN,t1.DATE_OUT,t1.DS,t1.CODE_USL,t1.KOL_USL,t1.TARIF,t1.SUMV_USL,t1.PRVS,t1.COMENTU,t1.PODR
from #t6 t1 inner join @tmpCase c on
			t1.ID_C=c.GUID_Case	
			and t1.IDCASE=c.idRecord		
where t1.ID_U is not null
group by c.id,t1.IDSERV, t1.ID_U, t1.LPU, t1.PROFIL, t1.DET,t1.DATE_IN,t1.DATE_OUT,t1.DS,t1.CODE_USL,t1.KOL_USL,t1.TARIF,t1.SUMV_USL,t1.PRVS,t1.COMENTU,t1.PODR
----------------------------------------------------------------------------------------------------------------------
-----изменения от 22.01.2012-------------------------------------------------------------------
insert t_RegisterPatient(rf_idFiles, ID_Patient, Fam, Im, Ot, rf_idV005, BirthDay, BirthPlace)
	output inserted.id,inserted.ID_Patient into @tableId
select @idFile,t1.ID_PAC,t1.FAM,t1.IM,case when t1.OT='НЕТ' then null else t1.OT end,t1.W,t1.DR,t1.MR
from #t8 t1 
group by t1.ID_PAC,t1.FAM,t1.IM,case when t1.OT='НЕТ' then null else t1.OT end,t1.W,t1.DR,t1.MR

insert t_RefRegisterPatientRecordCase(rf_idRecordCase,rf_idRegisterPatient)
select t2.id,t1.id
from  @tableId t1 inner join @tempID t2 on
				t1.ID_PAC=t2.ID_PAC
-----изменения от 22.01.2012-------------------------------------------------------------------

insert t_RegisterPatientDocument(rf_idRegisterPatient, rf_idDocumentType, SeriaDocument, NumberDocument, SNILS, OKATO, OKATO_Place, Comments)
select t2.id,t1.DOCTYPE,t1.DOCSER,t1.DOCNUM,t1.SNILS,t1.OKATOG,t1.OKATOP,t1.COMENTP
from #t8 t1 inner join @tableId t2 on
		t1.ID_PAC=t2.ID_PAC
where (t1.DOCTYPE is not null) or (t1.DOCSER is not null) or (t1.DOCNUM is not null)
group by t2.id,t1.DOCTYPE,t1.DOCSER,t1.DOCNUM,t1.SNILS,t1.OKATOG,t1.OKATOP,t1.COMENTP

insert t_RegisterPatientAttendant(rf_idRegisterPatient, Fam, Im, Ot, rf_idV005, BirthDay)
select t2.id,t1.FAM_P,t1.IM_P,t1.OT_P,t1.W_P,t1.DR_P
from #t8 t1 inner join @tableId t2 on
		upper(t1.ID_PAC)=upper(t2.ID_PAC)
where (t1.FAM_P is not null) and (t1.IM_P is not null) and (t1.W_P is not null) and (t1.DR_P is not null)
group by t2.id,t1.FAM_P,t1.IM_P,t1.OT_P,t1.W_P,t1.DR_P


select @idFile

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
	
Exit1:
drop table #t8

GO
----------------------------------------------------------------------------------------------------------------------
