USE [RegisterCases]
GO

/****** Object:  StoredProcedure [dbo].[usp_InsertRegisterCaseFileF]    Script Date: 10.01.2018 13:34:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER proc [dbo].[usp_InsertRegisterCaseFileF]
			@doc xml,
			@patient xml,
			@file varbinary(max),
			@countSluch INT=0
as
DECLARE @idoc int,
		@ipatient int,
		@id int,
		@idFile int

---create tempory table----------------------------------------------
declare @t1 as table([VERSION] char(5),DATA date,[FILENAME] varchar(26),SD_Z INT)

declare @t2 as table(CODE BIGINT,CODE_MO int,[YEAR] smallint,[MONTH] tinyint,NSCHET int,DSCHET date,SUMMAV numeric(11, 2),COMENTS nvarchar(250)) 

create table #t3(
				    N_ZAP int,
					PR_NOV tinyint,
					ID_PAC nvarchar(36),
					VPOLIS tinyint,
					SPOLIS nchar(10),
					NPOLIS nchar(20),
					ENP VARCHAR(16), 
					ST_OKATO VARCHAR(5), 
					SMO nchar(5),
					SMO_OK nchar(5),
					SMO_NAM nvarchar(100),
					NOVOR nchar(9),
					MO_PR nchar(6)									
					)

---new column in table 27.04.2016
create table #t5
(
	N_ZAP int,
	ID_PAC nvarchar(36),
	IDCASE bigint,
	ID_C UNIQUEIDENTIFIER,
	DISP NVARCHAR(3),
	USL_OK tinyint,
	VIDPOM smallint,
	FOR_POM tinyint,
	LPU nchar(6),
	PROFIL smallint,
	VBR tinyint, 
	NHISTORY nvarchar(50), 
	P_OTK TINYINT,
	DATE_1 date,
	DATE_2 date,
	DS1 nchar(10),
	DS1_PR TINYINT, 
	PR_D_N TINYINT,
	CODE_MES1 nchar(20),
	RSLT smallint,
	ISHOD smallint,
	PRVS bigint,
	IDDOCT VARCHAR(25),
	IDSP TINYINT,
	ED_COL numeric(5, 2),
	TARIF numeric(15, 2),
	SUMV numeric(15, 2),
	COMENTSL nvarchar(250)
)

CREATE TABLE #tPrescription(IDCASE int,ID_C UNIQUEIDENTIFIER, NAZR TINYINT, NAZ_SP SMALLINT,NAZ_V TINYINT,NAZ_PMP SMALLINT, NAZ_PK SMALLINT)
 
CREATE TABLE #tDS2_N(IDCASE int,ID_C UNIQUEIDENTIFIER,DS2 VARCHAR(10), DS2_PR TINYINT, PR_D TINYINT)   				 
					 
create table #t6(IDCASE int,ID_C uniqueidentifier,IDSERV nvarchar(36),ID_U uniqueidentifier,LPU nchar(6),PROFIL smallint,
			DATE_IN date,DATE_OUT date,P_OTK TINYINT,
			CODE_USL nchar(20),KOL_USL numeric(6, 2),TARIF numeric(15, 2),SUMV_USL numeric(15, 2),
			PRVS bigint,COMENTU nvarchar(250),CODE_MD VARCHAR(25)
			)
					   
declare @t7 as table([VERSION] nchar(5),DATA date,[FILENAME] nchar(26),FILENAME1 nchar(26))

create table #t8 (ID_PAC nvarchar(36),FAM nvarchar(40),IM nvarchar(40),OT nvarchar(40),W tinyint,DR date, TEL VARCHAR(10)
				 ,FAM_P nvarchar(40),IM_P nvarchar(40),OT_P nvarchar(40),
				  W_P tinyint,DR_P DATE
				  ,DOST_P TINYINT
				  ,MR nvarchar(100),DOCTYPE nchar(2),DOCSER nchar(10),DOCNUM nchar(20),SNILS nchar(14),OKATOG nchar(11),OKATOP nchar(11),
				  COMENTP nvarchar(250))

CREATE TABLE #tDost(ID_PAC nvarchar(36),DOST TINYINT, IsAttendant BIT)

declare @tempID as table(id int, ID_PAC nvarchar(36),N_ZAP int)

declare @tableId as table(id int,ID_PAC nvarchar(36))
---------------------------------------------------------------------
EXEC sp_xml_preparedocument @idoc OUTPUT, @doc

insert @t1
SELECT [version],REPLACE(DATA,'-',''),[FILENAME],SD_Z
FROM OPENXML (@idoc, 'ZL_LIST/ZGLV',2)
	WITH(
			[VERSION] NCHAR(5) './VERSION',
			[DATA] NCHAR(10) './DATA',
			[FILENAME] NCHAR(26) './FILENAME',
			SD_Z INT './SD_Z'
		)
--SELECT * FROM @t1
		
insert @t2
select CODE,CODE_MO,[YEAR],[MONTH],NSCHET,replace(DSCHET,'-',''),SUMMAV,COMENTS
FROM OPENXML (@idoc, 'ZL_LIST/SCHET',2)
	WITH 
	(	
		CODE bigint './CODE',
		CODE_MO int './CODE_MO',
		[YEAR]	smallint './YEAR',
		[MONTH] tinyint './MONTH',
		NSCHET int './NSCHET',
		DSCHET nchar(10) './DSCHET',
		SUMMAV decimal(11,2) './SUMMAV',
		COMENTS nvarchar(250) './COMENTS'		
	)

--SELECT * FROM @t2
--добавил Вес новорожденного 13.01.2014
insert #t3( N_ZAP ,PR_NOV ,ID_PAC ,VPOLIS ,SPOLIS ,NPOLIS ,ENP ,ST_OKATO ,SMO ,SMO_OK ,SMO_NAM ,NOVOR ,MO_PR)
SELECT N_ZAP,PR_NOV,ID_PAC,VPOLIS,SPOLIS,NPOLIS,ENP,ST_OKATO,SMO,SMO_OK,SMO_NAM,NOVOR,MO_PR
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/PACIENT',2)
	WITH(
			N_ZAP int '../N_ZAP',
			PR_NOV tinyint '../PR_NOV',
			ID_PAC nvarchar(36),
			VPOLIS tinyint ,
			SPOLIS nchar(10),
			NPOLIS nchar(20),
			ENP VARCHAR(16),
			ST_OKATO VARCHAR(5),
			SMO nchar(5) ,
			SMO_OK nchar(5),
			SMO_NAM nvarchar(100),
			NOVOR nchar(9),
			MO_PR nchar(6)			
		)

--SELECT * FROM #t3

insert #t5( N_ZAP, ID_PAC ,IDCASE ,ID_C ,DISP ,USL_OK ,VIDPOM ,FOR_POM ,LPU ,PROFIL ,VBR ,NHISTORY ,P_OTK ,DATE_1 ,DATE_2 ,DS1 ,
			DS1_PR ,PR_D_N ,CODE_MES1 ,RSLT ,ISHOD ,PRVS ,IDDOCT ,IDSP ,ED_COL ,TARIF ,SUMV ,COMENTSL)
SELECT     N_ZAP,ID_PAC, IDCASE, ID_C, DISP, USL_OK, VIDPOM,FOR_POM, LPU,PROFIL, VBR, NHISTORY,P_OTK,replace(DATE_1,'-',''),replace(DATE_2,'-',''),DS1
		   ,DS1_PR, PR_D_N, CODE_MES1,RSLT,ISHOD,PRVS, IDDOKT,IDSP,ED_COL,TARIF,SUMV,COMENTSL
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/SLUCH',3)
	WITH(
			N_ZAP int '../N_ZAP',
			ID_PAC nvarchar(36) '../PACIENT/ID_PAC',
			IDCASE bigint ,
			ID_C uniqueidentifier,
			DISP NVARCHAR(3),
			USL_OK tinyint ,
			VIDPOM smallint,
			FOR_POM tinyint,			
			LPU nchar(6) ,
			PROFIL smallint,	
			VBR TINYINT,		
			NHISTORY nvarchar(50) ,
			P_OTK tinyint,
			DATE_1 nchar(10) ,
			DATE_2 nchar(10) ,
			DS1 nchar(10) ,			
			DS1_PR tinyint,
			PR_D_N tinyint,
			CODE_MES1 nchar(20) ,			
			RSLT smallint ,
			ISHOD smallint,
			PRVS bigint ,			
			IDSP TINYINT ,
			ED_COL DECIMAL(5,2) ,
			TARIF DECIMAL(15,2) ,	
			SUMV DECIMAL(15,2) ,				
			COMENTSL NVARCHAR(250),				
			IDDOKT VARCHAR(25)			
		)

--SELECT * FROM #t5

---множественность диагнозов		
INSERT #tDS2_N( IDCASE, ID_C, DS2, DS2_PR, PR_D )
SELECT IDCASE,ID_C,DS2,DS2_PR,PR_D
FROM OPENXML (@idoc, '/ZL_LIST/ZAP/SLUCH/DS2_N',3)
WITH(
			IDCASE int '../IDCASE',
			ID_C uniqueidentifier '../ID_C',			
			DS2 nchar(10)  ,
			DS2_PR TINYINT,
			PR_D tinyint
	)

--SELECT * FROM #tDS2_N
	
INSERT #tPrescription( IDCASE ,ID_C ,NAZR ,NAZ_SP ,NAZ_V ,NAZ_PMP ,NAZ_PK)
SELECT IDCASE ,ID_C ,NAZR ,NAZ_SP ,NAZ_V ,NAZ_PMP ,NAZ_PK
FROM OPENXML (@idoc, '/ZL_LIST/ZAP/SLUCH/PRESCRIPTION/PRESCRIPTIONS',3)
WITH(
			IDCASE int '../../IDCASE',
			ID_C uniqueidentifier '../../ID_C',			
			NAZR TINYINT,
			NAZ_SP SMALLINT,
			NAZ_V TINYINT,
			NAZ_PMP SMALLINT,
			NAZ_PK SMALLINT
  )          

--SELECT * FROM #tPrescription            
		
insert #t6
SELECT IDCASE,ID_C,IDSERV,ID_U,LPU,PROFIL,
		replace(DATE_IN,'-',''),replace(DATE_OUT,'-',''),P_OTK
		,CODE_USL,KOL_USL,TARIF,SUMV_USL,PRVS,COMENTU,CODE_MD
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/SLUCH/USL',3)
	WITH(
			IDCASE int '../IDCASE',
			ID_C uniqueidentifier '../ID_C',
			IDSERV nvarchar(36) ,
			ID_U uniqueidentifier ,
			LPU nchar(6) ,
			PROFIL smallint,			
			DATE_IN nchar(10),
			DATE_OUT nchar(10),
			P_OTK TINYINT,
			CODE_USL nchar(20),
			KOL_USL DECIMAL(6,2),
			TARIF DECIMAL(15,2) ,	
			SUMV_USL DECIMAL(15,2),	
			PRVS bigint ,
			COMENTU NVARCHAR(250),
			CODE_MD VARCHAR(25) 
		)

--SELECT * FROM #t6

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
--SELECT * FROM @t7
		
INSERT #t8(ID_PAC, FAM, IM, OT, W, DR, TEL, FAM_P, IM_P, OT_P, W_P, DR_P, MR, DOCTYPE, DOCSER, DOCNUM, SNILS, OKATOG, OKATOP, COMENTP)
SELECT DISTINCT ID_PAC,CASE WHEN LEN(FAM)=0 THEN NULL ELSE FAM END ,CASE WHEN LEN(IM)=0 THEN NULL ELSE IM END ,
		CASE WHEN LEN(OT)=0 THEN NULL ELSE OT END ,W,replace(DR,'-',''), TEL,FAM_P,IM_P,OT_P,W_P,replace(DR_P,'-',''),MR,DOCTYPE,DOCSER,DOCNUM,SNILS,OKATOG,OKATOP,COMENTP
FROM OPENXML (@ipatient, 'PERS_LIST/PERS',2)
	WITH(
			ID_PAC NVARCHAR(36),
			FAM NVARCHAR(40),
			IM NVARCHAR(40),
			OT NVARCHAR(40),
			W TINYINT,
			DR NCHAR(10),
			TEL VARCHAR(10),
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
--SELECT * FROM #t8

--1- Код надежности относится к пациента
--2 Код надежности сопровождающего
INSERT #tDOST(ID_PAC, DOST,IsAttendant)				
SELECT DISTINCT ID_PAC,DOST,1
FROM OPENXML (@ipatient, 'PERS_LIST/PERS/DOST',2)
	WITH(
			ID_PAC NVARCHAR(36) '../ID_PAC',
			DOST tinyint  'text()'
		)

INSERT #tDOST(ID_PAC, DOST,IsAttendant)				
SELECT DISTINCT ID_PAC,DOST,2
FROM OPENXML (@ipatient, 'PERS_LIST/PERS/DOST_P',2)
	WITH(
			ID_PAC NVARCHAR(36) '../ID_PAC',
			DOST TINYINT 'text()'
		)  

--SELECT * FROM #tDOST
EXEC sp_xml_removedocument @ipatient

declare @month tinyint,
		@year smallint,
		@codeLPU char(6)

begin transaction
begin try

------Insert into RegisterCase's tables------------------------------
insert t_FileTested(DateRegistration,[FileName],UserName) select GETDATE(),[FILENAME],ORIGINAL_LOGIN() from @t1

select @id=SCOPE_IDENTITY()

SELECT @countSluch=SD_Z from @t1

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
insert t_PatientSMO(ref_idRecordCase,rf_idSMO,OKATO,Name,ENP,ST_OKATO)
select t2.id,t1.SMO,t1.SMO_OK,case when rtrim(ltrim(t1.SMO_NAM))='' then null else t1.SMO_NAM END
		,ENP,ST_OKATO
from #t3 t1 inner join @tempID t2 on
			t1.ID_PAC=t2.ID_PAC and
			t1.N_ZAP=t2.N_ZAP
group by t2.id,t1.SMO,t1.SMO_OK,t1.SMO_NAM,ENP,ST_OKATO
----------Disability-----------------------


declare @tmpCase as table(id int,idRecord bigint,GUID_CASE uniqueidentifier)

insert t_Case(rf_idRecordCase, idRecordCase, GUID_Case, rf_idV006, rf_idV008,
			  rf_idV014,rf_idMO, rf_idV002,
			  NumberHistoryCase, DateBegin, DateEnd, IsFirstDS,IsNeedDisp,rf_idV009, rf_idV012, rf_idV004, 
			  rf_idV010, AmountPayment, Comments,Age,rf_idDoctor)
output inserted.id,inserted.idRecordCase,inserted.GUID_Case into @tmpCase
select t2.id,t1.IDCASE,t1.ID_C, t1.USL_OK,t1.VIDPOM,
		t1.FOR_POM,
		t1.LPU,t1.PROFIL,t1.NHISTORY,t1.DATE_1,t1.DATE_2,t1.DS1_PR,t1.PR_D_N
		,t1.RSLT,t1.ISHOD,
		t1.PRVS,t1.IDSP,t1.SUMV,t1.COMENTSL		
		,DATEDIFF(YEAR,t3.DR,t1.DATE_1)-CASE WHEN 100*MONTH(t3.DR)+DAY(t3.DR)>100*MONTH(t1.DATE_1)+DAY(t1.DATE_1) THEN 1 ELSE 0 END
		,CASE WHEN t1.IDDOCT='0' THEN NULL ELSE t1.IDDOCT END
from #t5 t1 inner join @tempID t2 on
		t1.N_ZAP=t2.N_ZAP and
		t1.ID_PAC=t2.ID_PAC
			left join #t8 t3 on
		t1.ID_PAC=t3.ID_PAC
group by t2.id,t1.IDCASE,t1.ID_C, t1.USL_OK,t1.VIDPOM,
		t1.FOR_POM,
		t1.LPU,t1.PROFIL,t1.NHISTORY,t1.DATE_1,t1.DATE_2,t1.DS1_PR, t1.PR_D_N
		,t1.RSLT,t1.ISHOD,
		t1.PRVS,t1.IDSP,t1.SUMV,t1.COMENTSL		
		,DATEDIFF(YEAR,t3.DR,t1.DATE_1)-CASE WHEN 100*MONTH(t3.DR)+DAY(t3.DR)>100*MONTH(t1.DATE_1)+DAY(t1.DATE_1) THEN 1 ELSE 0 END
		,CASE WHEN t1.IDDOCT='0' THEN NULL ELSE t1.IDDOCT END
 -----------------------------------------------------------------------------------------------------------------
INSERT dbo.t_DispInfo( rf_idCase ,TypeDisp ,IsMobileTeam ,TypeFailure)
SELECT c.id,t1.DISP,t1.VBR,t1.P_OTK
from @tmpCase c inner join #t5 t1 on
		c.GUID_Case=t1.ID_C
		and c.idRecord=t1.IDCASE   
------------------------------------------------------------------------------------------------------------------
insert t_Diagnosis(DiagnosisCode,rf_idCase,TypeDiagnosis)
select DS1,c.id,1 
from @tmpCase c inner join #t5 t1 on
		c.GUID_Case=t1.ID_C
		and c.idRecord=t1.IDCASE
--------------------------------------------------------------------------------------------------------------------
---таблица для вставленных записей в t_MES. Будит использоваться взамен запуска триггера
CREATE TABLE #iTableMes (rf_idCase bigint,MES varchar(20))

insert t_MES(MES,rf_idCase,TypeMES,Quantity,Tariff)
OUTPUT INSERTED.rf_idCase,INSERTED.MES INTO #iTableMes
select t1.CODE_MES1,c.id,1,t1.ED_COL,t1.TARIF
from @tmpCase c inner join #t5 t1 on
		c.GUID_Case=t1.ID_C
		and c.idRecord=t1.IDCASE
where t1.CODE_MES1 is not null
group by t1.CODE_MES1,c.id,t1.ED_COL,t1.TARIF
------------------------------------------------------------------
INSERT dbo.t_DS2_Info( rf_idCase ,DiagnosisCode ,IsFirst ,IsNeedDisp)
SELECT DISTINCT c.id,t1.DS2, t1.DS2_PR, t1.PR_D
from @tmpCase c inner join #tDS2_N t1 on
		c.GUID_Case=t1.ID_C
		and c.idRecord=t1.IDCASE
-----------------------------------------------------------------
INSERT dbo.t_Prescriptions( rf_idCase ,NAZR ,rf_idV015 ,TypeExamination ,rf_dV002 ,rf_idV020)
SELECT DISTINCT c.id ,t1.NAZR ,t1.NAZ_SP ,t1.NAZ_V ,t1.NAZ_PMP ,t1.NAZ_PK
from @tmpCase c inner join #tPrescription t1 on
		c.GUID_Case=t1.ID_C
		and c.idRecord=t1.IDCASE

insert t_Meduslugi(rf_idCase,id,GUID_MU,rf_idMO, rf_idV002, DateHelpBegin, DateHelpEnd,MUCode, Quantity, Price, TotalPrice, rf_idV004, Comments,rf_idDoctor,IsNeedUsl)
select c.id,t1.IDSERV, t1.ID_U, t1.LPU, t1.PROFIL,t1.DATE_IN,t1.DATE_OUT,t1.CODE_USL,t1.KOL_USL,t1.TARIF,t1.SUMV_USL,t1.PRVS,t1.COMENTU
	,CASE WHEN t1.CODE_MD='0' THEN NULL ELSE t1.CODE_MD END, t1.P_OTK
from #t6 t1 inner join @tmpCase c on
			t1.ID_C=c.GUID_Case	
			and t1.IDCASE=c.idRecord		
where t1.ID_U is not null
group by  c.id,t1.IDSERV, t1.ID_U, t1.LPU, t1.PROFIL,t1.DATE_IN,t1.DATE_OUT,t1.CODE_USL,t1.KOL_USL,t1.TARIF,t1.SUMV_USL,t1.PRVS,t1.COMENTU
,CASE WHEN t1.CODE_MD='0' THEN NULL ELSE t1.CODE_MD END, t1.P_OTK
----------------------------------------------------------------------------------------------------------------------
-----изменения от 22.01.2012-------------------------------------------------------------------
insert t_RegisterPatient(rf_idFiles, ID_Patient, Fam, Im, Ot, rf_idV005, BirthDay, BirthPlace, TEL)
	output inserted.id,inserted.ID_Patient into @tableId
select @idFile,t1.ID_PAC,t1.FAM,t1.IM,case when t1.OT='НЕТ' then null else t1.OT end,t1.W,t1.DR,t1.MR,t1.TEL
from #t8 t1 
group by t1.ID_PAC,t1.FAM,t1.IM,case when t1.OT='НЕТ' then null else t1.OT end,t1.W,t1.DR,t1.MR,t1.TEL

insert t_RefRegisterPatientRecordCase(rf_idRecordCase,rf_idRegisterPatient)
select t2.id,t1.id
from  @tableId t1 inner join @tempID t2 on
				t1.ID_PAC=t2.ID_PAC
-----изменения от 22.01.2012-------------------------------------------------------------------

insert t_RegisterPatientDocument(rf_idRegisterPatient, rf_idDocumentType, SeriaDocument, NumberDocument, SNILS, OKATO, OKATO_Place, Comments)
select t2.id,t1.DOCTYPE,t1.DOCSER,t1.DOCNUM,t1.SNILS,t1.OKATOG,t1.OKATOP,t1.COMENTP
from #t8 t1 inner join @tableId t2 on
		t1.ID_PAC=t2.ID_PAC
where (t1.DOCTYPE is not null) or (t1.DOCSER is not null) or (t1.DOCNUM is not null) OR (t1.SNILS IS NOT null) OR (t1.OKATOG IS NOT NULL) OR (t1.OKATOP IS NOT NULL)
group by t2.id,t1.DOCTYPE,t1.DOCSER,t1.DOCNUM,t1.SNILS,t1.OKATOG,t1.OKATOP,t1.COMENTP

insert t_RegisterPatientAttendant(rf_idRegisterPatient, Fam, Im, Ot, rf_idV005, BirthDay)
select t2.id,t1.FAM_P,t1.IM_P,t1.OT_P,t1.W_P,t1.DR_P
from #t8 t1 inner join @tableId t2 on
		upper(t1.ID_PAC)=upper(t2.ID_PAC)
where (t1.FAM_P is not null) or (t1.IM_P is not null) or (t1.W_P is not null) or (t1.DR_P is not null)
group by t2.id,t1.FAM_P,t1.IM_P,t1.OT_P,t1.W_P,t1.DR_P
--------------------------------
INSERT dbo.t_ReliabilityPatient( rf_idRegisterPatient ,TypeReliability ,IsAttendant)
SELECT t2.id, t1.DOST, t1.IsAttendant
FROM #tDOST t1 INNER JOIN  @tableId t2 on
		t1.ID_PAC=t2.ID_PAC
WHERE t1.DOST IS NOT NULL

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
	--ROLLBACK TRANSACTION
	commit transaction
	
Exit1:
drop table #t8
DROP TABLE #t5
DROP TABLE #tPrescription
DROP TABLE #t6
DROP TABLE #tDOST
DROP TABLE #tDS2_N

GO

