USE [AccountOMS]
GO
/****** Object:  StoredProcedure [dbo].[usp_TestAccountDataLPUFileH]    Script Date: 12.09.2018 13:46:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[usp_TestAccountDataLPUFileH]
			@doc xml,
			@patient xml,
			--@file varbinary(max),
			@fileName varchar(26),
			@fileKey varbinary(max)=null--файл цифровой подписи
AS
SET XACT_ABORT ON
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

DECLARE @idoc int,
		@ipatient int,
		@id int,
		@idFile int--,
		--@error tinyint=0

---create tempory table----------------------------------------------

declare @t1 as table([VERSION] char(5),DATA date,[FILENAME] varchar(26),SD_Z INT)--new

declare @t2 as table(
					 CODE bigint,
					 CODE_MO int,
					 [YEAR] smallint,
					 [MONTH] tinyint,
					 NSCHET nvarchar(15),
					 DSCHET date,
					 PLAT nvarchar(5),
					 SUMMAV decimal(15, 2),
					 COMENTS nvarchar(250)
					 ) 

create table #t3 
(
	N_ZAP int,
	PR_NOV tinyint,
	ID_PAC nvarchar(36),
	VPOLIS tinyint,
	SPOLIS nchar(10),
	NPOLIS nchar(20),
	ENP VARCHAR(16),--обязательно к заполнению 
	ST_OKATO VARCHAR(5), 
	SMO nchar(5),
	SMO_OK nchar(5),
	SMO_NAM nvarchar(100),
	NOVOR nchar(9),
	MO_PR nchar(6),
	VNOV_D SMALLINT			
)
------------------сведения о признании лица инвалидом---------------------
CREATE TABLE #tDisabiliti(N_ZAP int,ID_PAC nvarchar(36), INV TINYINT,DATA_INV DATE, REASON_INV TINYINT, DS_INV VARCHAR(10))

create table #t5 
(
	N_ZAP int,
	ID_PAC nvarchar(36),
	IDCASE int,
	ID_C uniqueidentifier,
	USL_OK tinyint,
	VIDPOM smallint,
	FOR_POM tinyint,
	VID_HMP varchar(19),
	METOD_HMP INT,
	NPR_MO nvarchar(6),
	EXTR tinyint,
	LPU nvarchar(6),
	LPU_1 nvarchar(8),
	PODR INT,
	PROFIL smallint,
	DET tinyint,
	TAL_D DATE,--new 
	TAL_P DATE,--new
	NHISTORY nvarchar(50),
	P_PER CHAR(1),--new
	DATE_1 date,
	DATE_2 date,
	DS0 nvarchar(10),
	DS1 nvarchar(10),	
	CODE_MES1 nvarchar(16),
	RSLT smallint,
	ISHOD smallint,
	PRVS bigint,
	OS_SLUCH tinyint,
	IDSP tinyint,
	ED_COL decimal(5, 2),
	TARIF decimal(15, 2),
	SUMV decimal(15, 2),
	--REFREASON tinyint, 
	SANK_MEK decimal(15, 2),
	SANK_MEE decimal(15, 2),
	SANK_EKMP decimal(15, 2),
	COMENTSL nvarchar(250),
	F_SP TINYINT,
	IDDOCT VARCHAR(25),
	IT_SL DECIMAL(3,2),
	AD_CRITERION VARCHAR(20),
	NEXT_VISIT DATE,
	NPR_DATE DATE,
	PROFIL_K smallint,
	P_CEL NVARCHAR(3),
	TAL_NUM NVARCHAR(20),
	DN TINYINT,
	DKK2 NVARCHAR(10),
	DS_ONK TINYINT, --16.07.208
	C_ZAB TINYINT, --16.07.208
	MSE TINYINT --16.07.208		
)
		
CREATE TABLE #tDS(IDCASE int,ID_C uniqueidentifier,DS varchar(10), TypeDiagnosis tinyint)

CREATE TABLE #tBW(IDCASE int,ID_C uniqueidentifier, BirthWeight smallint)
CREATE TABLE #tCoeff_0(IDCASE BIGINT,ID_C uniqueidentifier, CODE_SL SMALLINT,VAL_C DECIMAL(3,2))
---new tempory table 27.12.2017
CREATE TABLE #tKiro(IDCASE BIGINT,ID_C UNIQUEIDENTIFIER,CODE_KIRO INT, VAL_K DECIMAL(3,2))

--16.07.2018
CREATE TABLE #ONK_SL
					(
						IDCASE int,
						ID_C UNIQUEIDENTIFIER,
						DS1_T TINYINT,
						STAD SMALLINT, --обязательные к заполнению
						ONK_T SMALLINT,--обязательные к заполнению
						ONK_N SMALLINT,--обязательные к заполнению
						ONK_M SMALLINT,--обязательные к заполнению
						MTSTZ TINYINT,
						SOD DECIMAL(5,2),
						PR_CONS TINYINT,
						DT_CONS date						
						 )
CREATE TABLE #B_DIAG(IDCASE int,ID_C UNIQUEIDENTIFIER,DIAG_TIP TINYINT,DIAG_CODE SMALLINT, DIAG_RSLT SMALLINT, DIAG_DATE date)
CREATE TABLE #B_PROT(IDCASE int,ID_C UNIQUEIDENTIFIER,PROT TINYINT,D_PROT DATE)
						


create table #t6
(
	IDCASE int,
	ID_C uniqueidentifier,
	IDSERV nvarchar(36),
	ID_U uniqueidentifier,
	LPU nchar(6),
	PROFIL smallint,
	VID_VME nvarchar(15),
	DET tinyint,
	DATE_IN date,
	DATE_OUT date,
	DS nchar(10),
	CODE_USL nchar(20),
	KOL_USL numeric(6, 2),
	TARIF numeric(15, 2),
	SUMV_USL numeric(15, 2),
	PRVS bigint,
	COMENTU nvarchar(250),
	PODR INT,
	CODE_MD VARCHAR(25),
	LPU_1 NVARCHAR(6)
)

--16.07.2018
create table #NAPR(IDCASE int,ID_C uniqueidentifier,NAPR_DATE DATE,NAPR_V TINYINT,MET_ISSL TINYINT,NAPR_USL VARCHAR(15))

create table #ONK_USL
	(
		IDCASE int,
		ID_C uniqueidentifier,
		ID_U UNIQUEIDENTIFIER,		
		USL_TIP TINYINT, 
		HIR_TIP TINYINT, 
		LEK_TIP_L TINYINT,
		LEK_TIP_V TINYINT,
		LUCH_TIP TINYINT
   )      
 					   
declare @t7 as table([VERSION] nchar(5),DATA date,[FILENAME] nchar(26),FILENAME1 nchar(26))

create table #t8
(
	ID_PAC nvarchar(36),
	FAM nvarchar(40),
	IM nvarchar(40),
	OT nvarchar(40),
	W tinyint,
	DR date,
	TEL VARCHAR(10),--new 
	FAM_P nvarchar(40),
	IM_P nvarchar(40),
	OT_P nvarchar(40),
	W_P tinyint,
	DR_P date,
	MR nvarchar(100),
	DOCTYPE nchar(2),
	DOCSER nchar(10),
	DOCNUM nchar(20),
	SNILS nchar(14),
	OKATOG nchar(11),
	OKATOP nchar(11),
	COMENTP nvarchar(250)
)
CREATE TABLE #tDost(ID_PAC nvarchar(36),DOST TINYINT, IsAttendant BIT) --new

declare @tempID as table(id int, ID_PAC nvarchar(36),N_ZAP int)

declare @tableId as table(id int,ID_PAC nvarchar(36))
---------------------------------------------------------------------
EXEC sp_xml_preparedocument @idoc OUTPUT, @doc

insert @t1
SELECT [version],REPLACE(DATA,'-',''),[FILENAME],SD_Z --new
FROM OPENXML (@idoc, 'ZL_LIST/ZGLV',2)
	WITH(
			[VERSION] NCHAR(5) './VERSION',
			[DATA] NCHAR(10) './DATA',
			[FILENAME] NCHAR(26) './FILENAME',
			SD_Z int './SD_Z'
		)
	
insert @t2
select CODE,CODE_MO,[YEAR],[MONTH],NSCHET,replace(DSCHET,'-',''),PLAT,SUMMAV,COMENTS
FROM OPENXML (@idoc, 'ZL_LIST/SCHET',2)
	WITH 
	(	
		CODE bigint './CODE', --new
		CODE_MO int './CODE_MO',
		[YEAR]	smallint './YEAR',
		[MONTH] tinyint './MONTH',
		NSCHET nvarchar(15) './NSCHET',
		DSCHET nchar(10) './DSCHET',
		PLAT nvarchar(5) './PLAT',
		SUMMAV decimal(15,2) './SUMMAV',
		COMENTS nvarchar(250) './COMENTS'		
	)
PRINT '#t3 start'
--добавил Вес новорожденного 13.01.2014

insert #t3
SELECT N_ZAP,PR_NOV,ID_PAC,VPOLIS,SPOLIS,NPOLIS,ENP,ST_OKATO,SMO,SMO_OK,SMO_NAM,NOVOR,MO_PR,VNOV_D
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/PACIENT',2)
	WITH(
			N_ZAP int '../N_ZAP',
			PR_NOV tinyint '../PR_NOV',
			ID_PAC nvarchar(36),
			VPOLIS tinyint ,
			SPOLIS nchar(10),
			NPOLIS nchar(20),
			ENP VARCHAR(16),--new
			ST_OKATO VARCHAR(5),--new
			SMO nchar(5) ,
			SMO_OK nchar(5),
			SMO_NAM nvarchar(100),
			NOVOR nchar(9),
			MO_PR nchar(6),
			VNOV_D SMALLINT
		)		
PRINT '#t3 end'

INSERT #tDisabiliti( N_ZAP ,ID_PAC ,INV ,DATA_INV ,REASON_INV ,DS_INV)
SELECT N_ZAP, ID_PAC, INV,REPLACE(DATA_INV,'-',''),REASON_INV,DS_INV
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/PACIENT/DISABILITY',3)
	WITH(
			N_ZAP int '../../N_ZAP',
			ID_PAC nvarchar(36) '../ID_PAC',
			INV TINYINT,
			DATA_INV nchar(10),
			REASON_INV TINYINT,
			DS_INV VARCHAR(10) 
		)

insert #t5( N_ZAP ,ID_PAC ,IDCASE ,ID_C ,USL_OK ,VIDPOM ,FOR_POM ,VID_HMP ,METOD_HMP ,NPR_MO ,EXTR ,LPU ,PROFIL ,DET ,TAL_D ,TAL_P ,NHISTORY ,
			P_PER ,DATE_1 ,DATE_2 ,DS0 ,DS1 ,CODE_MES1 ,RSLT ,ISHOD ,PRVS ,OS_SLUCH ,IDSP ,ED_COL ,TARIF ,SUMV ,COMENTSL ,F_SP ,IDDOCT ,IT_SL,PODR,LPU_1
			,AD_CRITERION,NEXT_VISIT,NPR_DATE,PROFIL_K,P_CEL,TAL_NUM,DN,DKK2,DS_ONK,MSE, C_ZAB
        )
SELECT N_ZAP,ID_PAC,IDCASE,ID_C,USL_OK,VIDPOM,
		FOR_POM,
		CASE WHEN LEN(VID_HMP)=0 THEN NULL ELSE VID_HMP END,
		CASE WHEN LEN(METOD_HMP)=0 THEN NULL ELSE METOD_HMP END,--13.01.2014					
		NPR_MO, EXTR, LPU, PROFIL, DET, TAL_D,TAL_P, NHISTORY, P_PER, replace(DATE_1,'-',''), replace(DATE_2,'-',''),DS0,DS1,CODE_MES1,RSLT,ISHOD,
		PRVS,OS_SLUCH,IDSP,ED_COL,TARIF,SUMV,COMENTSL,F_SP,IDDOKT,IT_SL,PODR,LPU_1, AD_CRITERION, replace(NEXT_VISIT,'-',''),NPR_DATE,PROFIL_K,P_CEL,TAL_NUM,DN,DKK2
		,DS_ONK,MSE, C_ZAB
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/SLUCH',3)
	WITH(
			N_ZAP int '../N_ZAP',
			ID_PAC nvarchar(36) '../PACIENT/ID_PAC',
			IDCASE bigint ,
			ID_C uniqueidentifier,
			USL_OK tinyint ,
			VIDPOM smallint,
			FOR_POM tinyint,
			VID_HMP varchar(19),
			METOD_HMP int ,			
			NPR_MO nchar(6),
			EXTR tinyint ,
			LPU nchar(6) ,
			LPU_1 NCHAR(8),
			PODR int,
			PROFIL smallint,
			DET tinyint ,
			TAL_D DATE,
			TAL_P DATE,
			NHISTORY nvarchar(50) ,
			P_PER CHAR(1),
			DATE_1 nchar(10) ,
			DATE_2 nchar(10) ,
			DS0 nchar(10) ,
			DS1 nchar(10) ,			
			CODE_MES1 nchar(20) ,			
			RSLT smallint ,
			ISHOD smallint,
			PRVS bigint ,			
			OS_SLUCH tinyint ,
			IDSP TINYINT ,
			ED_COL DECIMAL(5,2) ,
			TARIF DECIMAL(15,2) ,	
			SUMV DECIMAL(15,2) ,				
			COMENTSL NVARCHAR(250),
			F_SP TINYINT,
			IDDOKT VARCHAR(25),
			IT_SL DECIMAL(3,2),
			AD_CRITERION NVARCHAR(20),
			NEXT_VISIT NCHAR(10),
			---18.04.2018
			NPR_DATE DATE,
			PROFIL_K SMALLINT,
			P_CEL NVARCHAR(3),
			TAL_NUM NVARCHAR(20),
			DN TINYINT,
			DKK2 NVARCHAR(10),
			DS_ONK TINYINT,--16.07.208
			MSE TINYINT,--16.07.208
			C_ZAB TINYINT --16.07.208
		)

PRINT '#t5 end'		
---множественность диагнозов		
INSERT #tDS (IDCASE,ID_C,DS,TypeDiagnosis) 
SELECT IDCASE,ID_C,DS2,3
FROM OPENXML (@idoc, '/ZL_LIST/ZAP/SLUCH/DS2',3)
WITH(
			IDCASE int '../IDCASE',
			ID_C uniqueidentifier '../ID_C',			
			DS2 nchar(10) 'text()'  
	)
	
INSERT #tDS (IDCASE,ID_C,DS,TypeDiagnosis) 
SELECT IDCASE,ID_C,DS3,4
FROM OPENXML (@idoc, '/ZL_LIST/ZAP/SLUCH/DS3',3)
WITH(
			IDCASE int '../IDCASE',
			ID_C uniqueidentifier '../ID_C',			
			DS3 nchar(10) 'text()'  
	)
--Вес новорожденных
INSERT #tBW (IDCASE,ID_C,BirthWeight) 
SELECT IDCASE,ID_C,VNOV_M
FROM OPENXML (@idoc, '/ZL_LIST/ZAP/SLUCH/VNOV_M',3)
WITH(
			IDCASE int '../IDCASE',
			ID_C uniqueidentifier '../ID_C',			
			VNOV_M smallint 'text()'  
	)	

--new table
INSERT #tCoeff_0( IDCASE, ID_C, CODE_SL, VAL_C )
SELECT IDCASE,ID_C,CODE_SL,VAL_C
FROM OPENXML (@idoc, '/ZL_LIST/ZAP/SLUCH/SL_KOEFF/COEFF',3)
WITH(
			IDCASE int '../../IDCASE',
			ID_C uniqueidentifier '../../ID_C',			
			CODE_SL SMALLINT,
			VAL_C DECIMAL(3,2) 
	)

--16.07.2018
INSERT #ONK_SL(IDCASE, ID_C,DS1_T ,STAD,ONK_T,ONK_N,ONK_M,MTSTZ,SOD,PR_CONS, DT_CONS)
SELECT IDCASE,ID_C,DS1_T ,STAD,ONK_T,ONK_N,ONK_M,MTSTZ,SOD, PR_CONS, DT_CONS
FROM OPENXML (@idoc, '/ZL_LIST/ZAP/SLUCH/ONK_SL',3)
WITH(
			IDCASE int '../IDCASE',
			ID_C uniqueidentifier '../ID_C',			
			DS1_T TINYINT,
			STAD SMALLINT,
			ONK_T smallint,
			ONK_N smallint,
			ONK_M smallint,
			MTSTZ TINYINT,
			SOD DECIMAL(5,2),
			PR_CONS TINYINT,
			DT_CONS date
	)

INSERT #B_DIAG(IDCASE, ID_C,DIAG_TIP, DIAG_CODE, DIAG_RSLT,DIAG_DATE)
SELECT IDCASE, ID_C,DIAG_TIP, DIAG_CODE, DIAG_RSLT,DIAG_DATE
FROM OPENXML (@idoc, '/ZL_LIST/ZAP/SLUCH/ONK_SL/B_DIAG',3)
WITH(
			IDCASE int '../../IDCASE',
			ID_C uniqueidentifier '../../ID_C',			
			DIAG_TIP TINYINT, 
			DIAG_CODE SMALLINT, 
			DIAG_RSLT SMALLINT,
			DIAG_DATE date
	)

INSERT #B_PROT(IDCASE, ID_C,PROT, D_PROT)
SELECT IDCASE, ID_C,PROT, D_PROT
FROM OPENXML (@idoc, '/ZL_LIST/ZAP/SLUCH/ONK_SL/B_PROT',3)
WITH(
			IDCASE int '../../IDCASE',
			ID_C uniqueidentifier '../../ID_C',			
			PROT TINYINT, 
			D_PROT date
	)

INSERT #tKiro( IDCASE, ID_C, CODE_KIRO, VAL_K )
SELECT IDCASE,ID_C,CODE_KIRO,VAL_K
FROM OPENXML (@idoc, '/ZL_LIST/ZAP/SLUCH/S_KIRO',3)
WITH(
			IDCASE int '../IDCASE',
			ID_C uniqueidentifier '../ID_C',			
			CODE_KIRO SMALLINT,
			VAL_K DECIMAL(3,2) 
	)    
					
insert #t6
SELECT IDCASE,ID_C,IDSERV,ID_U,LPU,PROFIL,CASE when len(VID_VME)=0 THEN NULL ELSE VID_VME END,
		DET,replace(DATE_IN,'-',''),replace(DATE_OUT,'-',''),DS,CODE_USL,KOL_USL,TARIF,SUMV_USL,PRVS,COMENTU,PODR,CODE_MD,LPU_1
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/SLUCH/USL',3)
	WITH(
			IDCASE int '../IDCASE',
			ID_C uniqueidentifier '../ID_C',
			IDSERV nvarchar(36) ,
			ID_U uniqueidentifier ,
			LPU nchar(6) ,
			PROFIL smallint,
			VID_VME nvarchar(15),
			DET tinyint ,
			DATE_IN nchar(10),
			DATE_OUT nchar(10),
			DS nchar(10),
			CODE_USL nchar(20),
			KOL_USL DECIMAL(6,2),
			TARIF DECIMAL(15,2) ,	
			SUMV_USL DECIMAL(15,2),	
			PRVS bigint ,
			COMENTU NVARCHAR(250),
			PODR INT,
			CODE_MD VARCHAR(25),
			LPU_1 NVARCHAR(6) 
		)

--16.07.2018
INSERT #NAPR(IDCASE ,ID_C ,NAPR_DATE ,NAPR_V ,MET_ISSL ,NAPR_USL )
SELECT IDCASE ,ID_C ,NAPR_DATE ,NAPR_V ,MET_ISSL ,NAPR_USL
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/SLUCH/NAPR',3)
	WITH(
			IDCASE int '../IDCASE',
			ID_C uniqueidentifier '../ID_C',					
			NAPR_DATE date,
			NAPR_V TINYINT,
			MET_ISSL TINYINT,
			NAPR_USL NVARCHAR(15)
		)



INSERT #ONK_USL(IDCASE ,ID_C ,ID_U ,USL_TIP , HIR_TIP , LEK_TIP_L ,LEK_TIP_V ,LUCH_TIP)
SELECT IDCASE ,ID_C ,ID_U ,USL_TIP , HIR_TIP , LEK_TIP_L ,LEK_TIP_V ,LUCH_TIP
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/SLUCH/USL/ONK_USL',3)
	WITH(
			IDCASE int '../../IDCASE',
			ID_C uniqueidentifier '../../ID_C',		
			ID_U uniqueidentifier '../ID_U',			
			USL_TIP TINYINT, 
			HIR_TIP TINYINT, 
			LEK_TIP_L TINYINT,
			LEK_TIP_V TINYINT,
			LUCH_TIP TINYINT
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
	

INSERT #t8(ID_PAC, FAM, IM, OT, W, DR, TEL, FAM_P, IM_P, OT_P, W_P, DR_P, MR, DOCTYPE, DOCSER, DOCNUM, SNILS, OKATOG, OKATOP, COMENTP)
SELECT ID_PAC,CASE WHEN LEN(FAM)=0 THEN NULL ELSE FAM END ,CASE WHEN LEN(IM)=0 THEN NULL ELSE IM END ,
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
EXEC sp_xml_removedocument @ipatient
--select * from @t7
--select * from #t8

declare @account varchar(15),
		@codeMO char(6),
		@month tinyint,
		@year smallint
---26.12.2011----------------------------------------------
select @codeMO=(substring(@fileName,(3),(6))) 
declare @et as table(errorId smallint,id tinyint)
----------------------------------------------------------
--DATA
if exists(select * from @t1 where DATA>GETDATE() ) 
begin
	insert @et values(904,1)
end
if NOT EXISTS(select * from @et)
begin
	if exists(select * from @t2 where DSCHET>GETDATE() ) 
	begin
		insert @et values(904,2)
	end
end
--проверка CODE_MO в теге SCHET
declare @mcodeFile char(6),
		@mcodeSPR char(6)

select @mcodeFile=CODE_MO from @t2
	
	select @mcodeSPR=mcod from dbo.vw_sprT001 where CodeM=@codeMO
	
if(@mcodeFile!=@mcodeSPR)
begin
		insert @et values(904,3)
end
----------------
--NSCHET
if NOT EXISTS(select * from @et)
begin
	select @account=NSCHET,@year=[YEAR],@month=[MONTH] from @t2
	--проверяем счет на соответствие ему реестра СП и ТК. добавить проверку счета на уникальность
	
	if NOT EXISTS(select * from dbo.fn_CheckAccountExistSPTK(@account,@codeMO,@month,@year))
	begin	
		insert @et values(585,4)
	end
	if EXISTS(select * from dbo.fn_CheckAccountExistInDB(@account,@codeMO,@month,@year))
	begin	
		insert @et values(586,5)
	end
	
end
--Enable 2013-01-01 
-- check parameter of number account
	declare @letter char(1)
	select @letter=right(NSCHET,1) from @t2
if NOT EXISTS(select * from @et)
begin
	
	if NOT EXISTS(select MU from vw_sprMuWithParamAccount where AccountParam=@Letter UNION ALL select MU from vw_sprCSGWithParamAccount where AccountParam=@Letter)
	begin
		insert @et values(590,21)
	end
end
--compare MU with vw_sprMuWithParamAccount by AccountParam
if NOT EXISTS(select * from @et)
begin	
	if EXISTS(select * 
			  from (select CODE_USL from #t6  WHERE Tarif>0 
					union all 
					select CODE_MES1 from #t5 WHERE Tarif>0) m	 						
						 left join (SELECT MU,AccountParam from vw_sprMuWithParamAccount UNION ALL SELECT MU,AccountParam from vw_sprCSGWithParamAccount) s on			  
						m.CODE_USL=s.MU	and ISNULL(AccountParam,@letter)=@Letter 
					where s.MU is null 
			  )
	begin
		insert @et values(590,21)		
	end
end
	
--DSCHET
if NOT EXISTS(select * from @et)
begin	
	declare @dateAccount date
	declare @dateStart date
	
	--проверка на дату счета и дата окончания случая должна принадлежать отчетному месяцу
	select @dateAccount=DSCHET, @dateStart=CAST([YEAR] as CHAR(4))+right('0'+CAST([month] as varchar(2)),2)+'01' from @t2
	
	if EXISTS(select * from #t5 where DATE_2>@dateAccount and DATE_2<@dateStart)
	begin
		insert @et values(587,7)
	end	
end
--SUMMAV
if NOT EXISTS(select * from @et)
begin
	--производим проверку суммы всех случаев и суммы счета	
	if(select SUM(t.SUMV) from #t5 t)!=(select t.SUMMAV from @t2 t)
	begin
		insert @et values(51,8)
	end
end
--N_ZAP
if NOT EXISTS(select * from @et)
begin
	
	if EXISTS(select * from (select ROW_NUMBER() OVER(order by t.N_ZAP asc) as id,t.N_ZAP from #t3 t) t where id<>N_ZAP)
	begin
		insert @et values(530,9)
	end
end
--PR_NOV
--if NOT EXISTS(select * from @et)
--begin
	
--	if EXISTS(select * from #t3 t where t.PR_NOV<>0)
--	begin
--		insert @et values(531,10)
--	end
--end
--ID_PAC
if NOT EXISTS(select * from @et)
begin
	if EXISTS(select * 
			  from #t3 t left join #t8 p on
					t.ID_PAC=p.ID_PAC
			  where p.ID_PAC is null)
	begin
		insert @et values(532,11)
	end
	
	if EXISTS(select * 
			  from #t3 t right join #t8 p on
					t.ID_PAC=p.ID_PAC
			  where t.ID_PAC is null)
	begin
		insert @et values(532,12)
	end
end
declare @number int,
			@property tinyint,
			@smo char(5)

			
if NOT EXISTS(select * from @et)
begin
	select @number=dbo.fn_NumberRegister(@account),@smo=dbo.fn_PrefixNumberRegister(@account),@property=dbo.fn_PropertyNumberRegister(@account)
end
--Поиск некорректных данных с ошибкой 588 в ZAP
if NOT EXISTS(select * from @et)
begin
	
	declare @zapRC int,
			@zapA int
	
	--изменения от 23.03.2012

	--Изменения от 14.06.2012 новая ошибка номер 17
	-- проверка данных из тэга ZAP
	-----------------2012-12-28
	select @zapA=COUNT(*) from #t3
	
	select @zapRC=COUNT(*)
	from (
			select cast(r1.ID_Patient as nvarchar(36)) as ID_Patient,p.rf_idF008,ISNULL(CAST(p.SeriaPolis AS VARCHAR(10)),'') SeriaPolis
					,p.NumberPolis
					,CASE WHEN p.OKATO<>'18000' THEN '34' ELSE p.rf_idSMO END AS rf_idSMO
					,p.OKATO
					,cast(r1.NewBorn as nvarchar(9)) as NewBorn,
					CASE WHEN att.AttachLPU IS NULL THEN isnull(p.AttachCodeM,'000000') WHEN p.OKATO<>'18000' THEN '000000' ELSE att.AttachLPU end as MO_PR
					,r1.BirthWeight,p.ENP,r1.IsNew
			from RegisterCases.dbo.t_FileBack f inner join RegisterCases.dbo.t_RegisterCaseBack a on 
							f.id=a.rf_idFilesBack
							and f.CodeM=@codeMO
							and a.NumberRegister=@number
							and a.PropertyNumberRegister=@property
							AND a.ReportYear=@year
							AND a.ReportMonth=@month
												inner join RegisterCases.dbo.t_RecordCaseBack r on
							a.id=r.rf_idRegisterCaseBack
												INNER JOIN RegisterCases.dbo.t_CaseBack cp ON
							r.id=cp.rf_idRecordCaseBack					
							and cp.TypePay=1
												inner join RegisterCases.dbo.t_RecordCase r1 on
							r.rf_idRecordCase=r1.id
												inner join RegisterCases.dbo.t_PatientBack p on
							r.id=p.rf_idRecordCaseBack
							--and p.rf_idSMO=@smo
												LEFT JOIN RegisterCases.dbo.t_RefCaseAttachLPUItearion2 att ON
							r.rf_idCase=att.rf_idCase
			GROUP BY cast(r1.ID_Patient as nvarchar(36)),p.rf_idF008,ISNULL(CAST(p.SeriaPolis AS VARCHAR(10)),'')
					,p.NumberPolis
					,CASE WHEN p.OKATO<>'18000' THEN '34' ELSE p.rf_idSMO END 
					,p.OKATO,cast(r1.NewBorn as nvarchar(9)) 
					,CASE WHEN att.AttachLPU IS NULL THEN isnull(p.AttachCodeM,'000000') WHEN p.OKATO<>'18000' THEN '000000' ELSE att.AttachLPU end,r1.BirthWeight,p.ENP
					,r1.IsNew, r1.MSE
		  ) r inner join #t3 t on
					r.ID_Patient=t.ID_PAC
					and r.rf_idF008=t.VPOLIS
					and r.SeriaPolis=COALESCE(t.SPOLIS,'')
					and r.NumberPolis=t.NPOLIS
					and r.rf_idSMO=t.SMO
					and r.OKATO=COALESCE(t.SMO_OK,'18000')
					and r.NewBorn=t.NOVOR
					and isnull(r.MO_PR,'000000')=t.MO_PR
					AND ISNULL(r.BirthWeight,0)=ISNULL(t.VNOV_D,0)
					AND ISNULL(r.ENP,'')=ISNULL(t.ENP,'')
					AND r.IsNew=t.PR_NOV					
	if(@zapRC-@zapA)<>0	
	begin
		insert @et values(588,13)
	end	
end

--Поиск некорректных данных с ошибкой 588 в SLUCH
if NOT EXISTS(select * from @et)
begin
	
	if EXISTS(select * from (select ROW_NUMBER() OVER(order by t.IDCASE asc) as id,t.IDCASE from #t5 t) t where id<>IDCASE)
	begin
		insert @et values(588,14)
	end
end
--проверка на задвоенность ID_C
if NOT EXISTS(select * from @et)
begin  	
	if EXISTS(select ID_C from  #t5 GROUP BY ID_C HAVING COUNT(*)>1)
	begin
		insert @et values(588,30)
	end
end
							   
if NOT EXISTS(select * from @et)
begin
declare @caseRC int,
		@caseA int
	---Изменения от 23.03.2012 заменил функцию на ХП
	---проверяем совпадение по случаям предоставленным МУ и то что должны предоставить
	--считаем количество строк по случаем в файле
select @caseA=count(*)  from #t5 t	
----------2012-12-29
create table #case
(
	ID_Patient varchar(36) NOT NULL,
	id BIGINT,
	GUID_Case uniqueidentifier NOT NULL,
	rf_idV006 tinyint NULL,
	rf_idV008 smallint NULL,
	rf_idV014 TINYINT,
	rf_idV018 VARCHAR(19),
	rf_idV019 int,
	rf_idDirectMO char(6) NULL,
	HopitalisationType tinyint NULL,
	rf_idMO char(6) NOT NULL,
	rf_idV002 smallint NOT NULL,
	IsChildTariff bit NOT NULL,
	NumberHistoryCase nvarchar(50) NOT NULL,
	DateBegin date NOT NULL,
	DateEnd date NOT NULL,
	DS0 char(10) NULL,
	DS1 char(10) NULL,
	DS2 char(10) NULL,
	MES char(16) NULL,
	rf_idV009 smallint NOT NULL,
	rf_idV012 smallint NOT NULL,
	rf_idV004 int NOT NULL,
	IsSpecialCase tinyint NULL,
	rf_idV010 tinyint NOT NULL,
	Quantity decimal(5, 2) NULL,
	Tariff decimal(15, 2) NULL,
	AmountPayment decimal(15, 2) NOT NULL,
	SANK_MEK decimal(15, 2) NULL,
	SANK_MEE decimal(15, 2) NULL,
	SANK_EKMP decimal(15, 2) NULL,
	[Emergency] tinyint NULL,
	Comments VARCHAR(250),
	IT_SL DECIMAL(3,2),
	P_PER TINYINT,
	IDDOCT VARCHAR(25),
	rf_idSubMO VARCHAR(8),
	rf_idDepartmentMO INT,
	DS_ONK	TINYINT,
	MSE TINYINT,
	C_ZAB TINYINT
)

CREATE TABLE #tBirthWeight(	GUID_Case uniqueidentifier,VNOV_M smallint )
CREATE TABLE #tDisgnosis(GUID_Case uniqueidentifier,Code VARCHAR(10),TypeDiagnosis TINYINT )

CREATE TABLE #tCoeff(GUID_Case uniqueidentifier, CODE_SL SMALLINT,VAL_C DECIMAL(3,2))
CREATE TABLE #tTalon(GUID_Case uniqueidentifier, Tal_D DATE, Tal_P DATE,NumberOfTicket VARCHAR(20))
CREATE TABLE #tmpKiro(GUID_Case UNIQUEIDENTIFIER,CODE_KIRO INT, VAL_K DECIMAL(3,2))
CREATE TABLE #tmpAddCriterion(GUID_Case UNIQUEIDENTIFIER,ADD_CRITERION VARCHAR(20))
CREATE TABLE #tmpNEXT(GUID_Case UNIQUEIDENTIFIER,NEXT_VISIT DATE)

-------------------18.04.2018-------------------
CREATE TABLE #tDirectionDate(GUID_Case UNIQUEIDENTIFIER,NPR_Date DATE)
CREATE TABLE #tProfileOfBed(GUID_Case UNIQUEIDENTIFIER,PROFIL_K smallint)
CREATE TABLE #tPurposeOfVisit(GUID_Case UNIQUEIDENTIFIER,P_CEL VARCHAR(3),DN TINYINT)--DN может быть пустой
CREATE TABLE #tCombinationOfSchema(GUID_CASE UNIQUEIDENTIFIER,DKK2 VARCHAR(10))
-------------------20.07.2018------------------
CREATE TABLE #ONK_SL_RC
					(							
						GUID_Case UNIQUEIDENTIFIER,
						DS1_T TINYINT,
						STAD SMALLINT, --обязательные к заполнению
						ONK_T SMALLINT,--обязательные к заполнению
						ONK_N SMALLINT,--обязательные к заполнению
						ONK_M SMALLINT,--обязательные к заполнению
						MTSTZ TINYINT,
						SOD DECIMAL(5,2),
						PR_CONS TINYINT,
						DT_CONS date						
						 )
CREATE TABLE #B_DIAG_RC(GUID_Case UNIQUEIDENTIFIER,DIAG_TIP TINYINT,DIAG_CODE SMALLINT, DIAG_RSLT SMALLINT, DIAG_DATE date)
CREATE TABLE #B_PROT_RC(GUID_Case UNIQUEIDENTIFIER,PROT TINYINT,D_PROT DATE)

--16.07.2018
create table #NAPR_RC(GUID_Case uniqueidentifier,NAPR_DATE DATE,NAPR_V TINYINT,MET_ISSL TINYINT,NAPR_USL VARCHAR(15))

create table #ONK_USL_RC
	(
		GUID_Case uniqueidentifier,
		ID_U UNIQUEIDENTIFIER,		
		USL_TIP TINYINT, 
		HIR_TIP TINYINT, 
		LEK_TIP_L TINYINT,
		LEK_TIP_V TINYINT,
		LUCH_TIP TINYINT
   )      
 					   

if OBJECT_ID('tempDB..#case',N'U') is not null
begin
	exec dbo.usp_GetCaseFromRegisterCaseDBFilesH @account,@codeMO,@month,@year
end

	select @caseRC=COUNT(distinct t.GUID_Case)
	from #case t inner join #t5 t1 on
			ID_PAC=upper(t.ID_Patient) 
			and ID_C=t.GUID_Case
			and USL_OK=t.rf_idV006 
			and VIDPOM=t.rf_idV008
			AND ISNULL(FOR_POM,0)=ISNULL(t.rf_idV014,0)			
			AND ISNULL(VID_HMP,'bla-bla')=ISNULL(t.rf_idV018,'bla-bla')			
			AND ISNULL(METOD_HMP,0)=ISNULL(t.rf_idV019,0)			
			and isnull(NPR_MO,0)=isnull(t.rf_idDirectMO,0)
			and isnull(EXTR,0)=isnull(t.HopitalisationType,0)
			and LPU=t.rf_idMO
			and PROFIL=t.rf_idV002
			and DET =t.IsChildTariff
			and NHISTORY =NumberHistoryCase
			and DATE_1=DateBegin
			and DATE_2=DateEnd
			and isnull(t1.DS0,0)=isnull(t.DS0,0)
			and t1.DS1=t.DS1			
			and isnull(CODE_MES1,0)=isnull(t.MES,0) 
			and RSLT=t.rf_idV009  
			and ISHOD=t.rf_idV012  
			and PRVS=t.rf_idV004  
			and isnull(OS_SLUCH,0)=isnull(t.IsSpecialCase,0)
			and IDSP=t.rf_idV010  
			and isnull(ED_COL,0)=ISNULL(t.Quantity,0) 
			and isnull(TARIF ,0)=ISNULL(t.Tariff,0) 
			and ISNULL(t.[Emergency],0)=ISNULL(t1.F_SP,0)
			AND ISNULL(t.Comments,'bla-bla')=ISNULL(t1.COMENTSL,'bla-bla')
			AND ISNULL(t.IT_SL,9)=ISNULL(t1.IT_SL,9)
			AND ISNULL(t.P_PER,9)=ISNULL(t1.P_PER,9)
			AND ISNULL(t.IDDOCT,0) =t1.IDDOCT
			AND ISNULL(t.rf_idSubMO,'bla-bla')=ISNULL(t1.LPU_1,'bla-bla')
			AND ISNULL(rf_idDepartmentMO,0)=ISNULL(t1.PODR,0)
			AND ISNULL(t.MSE,0)=ISNULL(t1.MSE,0)
			AND ISNULL(t.C_ZAB,0)=ISNULL(t1.C_ZAB,0)
			AND ISNULL(t.DS_ONK,0)=ISNULL(t1.DS_ONK,0)			
			AND t.AmountPayment=t1.SUMV
			
			---сверяем вес новорожденных
			IF EXISTS(SELECT * FROM #tBW b WHERE NOT EXISTS(SELECT * FROM #tBirthWeight WHERE GUID_Case=b.ID_C AND VNOV_M=b.BirthWeight))
			BEGIN 			
				insert @et values(588,15)
			END
			---сверяем КСЛП
			IF EXISTS(SELECT * FROM #tCoeff b WHERE NOT EXISTS(SELECT * FROM #tCoeff_0 WHERE b.GUID_Case=ID_C AND CODE_SL=b.CODE_SL AND VAL_C=b.VAL_C ))
			BEGIN 			
				insert @et values(588,15)
			END
			--проверяем талоны
			IF EXISTS(SELECT * FROM #tTalon b WHERE NOT EXISTS(SELECT * FROM #t5 WHERE VIDPOM=32 and b.GUID_Case=ID_C AND Tal_D=b.Tal_D AND Tal_P=b.Tal_P AND ISNULL(TAL_NUM,'bla-bla')=ISNULL(b.NumberOfTicket,'bla-bla') ))
			BEGIN 			
				insert @et values(588,15)
			END     

			IF EXISTS(SELECT * FROM #tmpKiro k WHERE EXISTS (SELECT * FROM #t5 WHERE ID_C=GUID_Case )
						 AND NOT EXISTS(SELECT * FROM #tKiro t WHERE k.GUID_Case=t.ID_C AND k.CODE_KIRO=t.CODE_KIRO AND k.VAL_K=t.VAL_K))
			BEGIN 					
				insert @et values(588,99)
			END   
			PRINT('test 1')  

			IF EXISTS(SELECT * FROM #tmpAddCriterion k WHERE EXISTS (SELECT * FROM #t5 WHERE ID_C=GUID_Case ) AND NOT EXISTS(SELECT * FROM #t5 t WHERE k.GUID_Case=t.ID_C AND k.ADD_CRITERION=t.AD_CRITERION))
			BEGIN 			
				insert @et values(588,98)
			END     
			IF EXISTS(SELECT * FROM #tmpNEXT k WHERE EXISTS (SELECT * FROM #t5 WHERE ID_C=GUID_Case ) AND NOT EXISTS(SELECT * FROM #t5 t WHERE k.GUID_Case=t.ID_C AND k.NEXT_VISIT=t.NEXT_VISIT))
			BEGIN 			
				insert @et values(588,98)
			END     
			
			IF EXISTS(SELECT * FROM #tKiro t WHERE NOT EXISTS(SELECT * FROM #tmpKiro k WHERE k.GUID_Case=t.ID_C AND k.CODE_KIRO=t.CODE_KIRO AND k.VAL_K=t.VAL_K))
			BEGIN 							
				insert @et values(588,97)
			END     

			IF EXISTS(SELECT * FROM #t5 t WHERE t.AD_CRITERION IS NOT NULL AND  NOT EXISTS(SELECT * FROM #tmpAddCriterion k WHERE k.GUID_Case=t.ID_C AND k.ADD_CRITERION=t.AD_CRITERION))
			BEGIN 			
				insert @et values(588,96)
			END 
			
			IF EXISTS(SELECT * FROM #t5 t WHERE t.NEXT_VISIT IS NOT NULL AND  NOT EXISTS(SELECT * FROM #tmpNEXT k WHERE k.GUID_Case=t.ID_C AND k.NEXT_VISIT=t.NEXT_VISIT))
			BEGIN 			
				insert @et values(588,96)
			END     
			---------------------18.04.2018------------------
			IF EXISTS(SELECT * FROM #t5 t WHERE t.NPR_Date IS NOT NULL AND  NOT EXISTS(SELECT * FROM #tDirectionDate k WHERE k.GUID_Case=t.ID_C AND k.NPR_Date=t.NPR_Date))
			BEGIN 			
				insert @et values(588,100)
			END     
			IF EXISTS(SELECT * FROM #t5 t WHERE t.PROFIL_K IS NOT NULL AND  NOT EXISTS(SELECT * FROM #tProfileOfBed k WHERE k.GUID_Case=t.ID_C AND k.PROFIL_K=t.Profil_K))
			BEGIN 			
				insert @et values(588,101)
			END  
			IF EXISTS(SELECT * FROM #t5 t WHERE (t.P_CEL IS NOT NULL OR t.DN IS NOT NULL) AND  NOT EXISTS(SELECT * FROM #tPurposeOfVisit k 
																										  WHERE k.GUID_Case=t.ID_C AND ISNULL(k.P_CEL,'bla')=ISNULL(t.P_CEL,'bla')  
																												AND ISNULL(k.DN,0)=ISNULL(t.DN,0) )	)
			BEGIN 			
				insert @et values(588,102)
			END     
			IF EXISTS(SELECT * FROM #t5 t WHERE t.DN IS NOT NULL AND  NOT EXISTS(SELECT * FROM #tPurposeOfVisit k WHERE k.GUID_Case=t.ID_C AND k.DN=t.DN))
			BEGIN 			
				insert @et values(588,103)
			END     

			IF EXISTS(SELECT * FROM #tCombinationOfSchema)			 
			begin
				IF EXISTS(SELECT * FROM #t5 t WHERE t.DKK2 IS NOT NULL AND  NOT EXISTS(SELECT * FROM #tCombinationOfSchema k WHERE k.GUID_Case=t.ID_C AND k.DKK2=t.DKK2))
				BEGIN 			
					insert @et values(588,104)
				END  
			end
			-------------------20.07.2018---------------------
			
						
			IF EXISTS(SELECT * FROM #ONK_SL_RC t INNER JOIN #ONK_SL tt ON tt.ID_C=t.GUID_CASE WHERE t.DS1_T IS NOT NULL AND  NOT EXISTS(SELECT * 
																						  FROM #ONK_SL k 
																						  WHERE k.ID_C=t.GUID_CASE AND k.DS1_T=t.DS1_T AND 
																						  t.STAD=k.STAd and k.ONK_T=t.ONK_T AND k.ONK_N=t.ONK_N
																						  AND k.ONK_M=t.ONK_M AND ISNULL(k.MTSTZ,0)=ISNULL(t.MTSTZ,0) 
																						  AND isnull(k.SOD,0)=isnull(t.SOD,0) AND ISNULL(k.PR_CONS,0)=ISNULL(t.PR_CONS,0)
																						  AND ISNULL(k.DT_CONS,'22220101')=ISNULL(t.DT_CONS,'22220101')
																										)
					)
			BEGIN 			
				insert @et values(588,105)
			END  
			IF EXISTS(SELECT * FROM #ONK_SL t WHERE t.DS1_T IS NOT NULL AND  NOT EXISTS(SELECT * 
																						  FROM #ONK_SL_RC k 
																						  WHERE k.GUID_CASE=t.ID_C AND k.DS1_T=t.DS1_T AND 
																						  t.STAD=k.STAd and k.ONK_T=t.ONK_T AND k.ONK_N=t.ONK_N
																						  AND k.ONK_M=t.ONK_M AND ISNULL(k.MTSTZ,0)=ISNULL(t.MTSTZ,0) 
																						  AND isnull(k.SOD,0)=isnull(t.SOD,0) AND ISNULL(k.PR_CONS,0)=ISNULL(t.PR_CONS,0)
																						  AND ISNULL(k.DT_CONS,'22220101')=ISNULL(t.DT_CONS,'22220101')
																										)
					)
			BEGIN 			
				insert @et values(588,106)
			END  

			IF EXISTS(SELECT * FROM #B_DIAG_RC t INNER JOIN #B_DIAG tt ON t.GUID_Case=tt.ID_C  WHERE (t.DIAG_TIP IS NOT NULL OR t.DIAG_CODE IS NOT NULL or t.DIAG_RSLT IS NOT NULL or t.DIAG_DATE IS NOT NULL)
						AND  NOT EXISTS(SELECT * FROM #B_DIAG k WHERE t.GUID_Case=k.ID_C AND ISNULL(k.DIAG_DATE,'22220101')=ISNULL(t.DIAG_DATE,'22220101') 
																		AND ISNULL(k.DIAG_CODE,0)=ISNULL(t.DIAG_CODE,0) 
																		and ISNULL(k.DIAG_RSLT,0)=ISNULL(t.DIAG_RSLT,0) 
																		and isnull(k.DIAG_TIP,0)=isnull(t.DIAG_TIP,0)                                                                                          
																										)
					)
			BEGIN 			
				insert @et values(588,107)
			END  		

			IF EXISTS(SELECT * FROM #B_DIAG t WHERE (t.DIAG_TIP IS NOT NULL OR t.DIAG_CODE IS NOT NULL or t.DIAG_RSLT IS NOT NULL or t.DIAG_DATE IS NOT NULL) 
						AND  NOT EXISTS(SELECT * FROM #B_DIAG_RC k WHERE k.GUID_Case=t.ID_C AND ISNULL(k.DIAG_DATE,'22220101')=ISNULL(t.DIAG_DATE,'22220101') 
																		AND ISNULL(k.DIAG_CODE,0)=ISNULL(t.DIAG_CODE,0) 
																		and ISNULL(k.DIAG_RSLT,0)=ISNULL(t.DIAG_RSLT,0) 
																		and isnull(k.DIAG_TIP,0)=isnull(t.DIAG_TIP,0)                                                                                          
																										)
					)
			BEGIN 			
				insert @et values(588,108)
			END 
		

			IF EXISTS(SELECT * FROM #B_PROT_RC t INNER JOIN #B_PROT tt ON t.GUID_Case=tt.ID_C WHERE t.PROT IS NOT NULL AND  NOT EXISTS(SELECT * FROM #B_PROT k WHERE t.GUID_Case=k.ID_C AND k.PROT=t.PROT AND k.D_PROT=t.D_PROT))
			BEGIN 			
				insert @et values(588,109)
			END  
			IF EXISTS(SELECT * FROM #B_PROT t WHERE t.PROT IS NOT NULL AND  NOT EXISTS(SELECT * FROM #B_PROT_RC k WHERE k.GUID_Case=t.ID_C AND k.PROT=t.PROT AND k.D_PROT=t.D_PROT))
			BEGIN 			
				insert @et values(588,110)
			END  

			IF EXISTS(SELECT * FROM #NAPR_RC t INNER JOIN #NAPR tt ON t.GUID_Case=tt.ID_C WHERE t.NAPR_DATE IS NOT NULL AND  NOT EXISTS(SELECT * FROM #NAPR k WHERE t.GUID_Case=k.ID_C AND k.NAPR_DATE=t.NAPR_DATE AND k.NAPR_V=t.NAPR_V 
																															AND ISNULL(k.MET_ISSL,0)=ISNULL(t.MET_ISSL,0) AND ISNULL(k.NAPR_USL,'bla-bla')=ISNULL(t.NAPR_USL,'bla-bla') )
					)
			BEGIN 			
				insert @et values(588,111)
			END  

			IF EXISTS(SELECT * FROM #NAPR t WHERE t.NAPR_DATE IS NOT NULL AND  NOT EXISTS(SELECT * FROM #NAPR_RC k WHERE k.GUID_Case=t.ID_C AND k.NAPR_DATE=t.NAPR_DATE AND k.NAPR_V=t.NAPR_V 
																															AND ISNULL(k.MET_ISSL,0)=ISNULL(t.MET_ISSL,0) AND ISNULL(k.NAPR_USL,'bla-bla')=ISNULL(t.NAPR_USL,'bla-bla') )
					)
			BEGIN 			
				insert @et values(588,112)
			END  
			
			IF EXISTS(SELECT * FROM #ONK_USL_RC t INNER JOIN #ONK_USL tt ON t.GUID_Case=tt.ID_C AND tt.USL_TIP=t.USL_TIP  WHERE t.USL_TIP IS NOT NULL AND  NOT EXISTS(SELECT * FROM #ONK_USL k WHERE t.GUID_Case=k.ID_C AND k.USL_TIP=t.USL_TIP 
																															AND isnull(k.HIR_TIP,0)=isnull(t.HIR_TIP ,0) 
																															AND isnull(k.LEK_TIP_L,0)=isnull(t.LEK_TIP_L,0) 
																															AND isnull(k.LEK_TIP_V,0)=isnull(t.LEK_TIP_V,0) 
																															AND isnull(k.LUCH_TIP,0)=isnull(t.LUCH_TIP,0) )
					)
			BEGIN 			
				insert @et values(588,113)
			END  

			IF EXISTS(SELECT * FROM #ONK_USL t WHERE t.USL_TIP IS NOT NULL AND  NOT EXISTS(SELECT * FROM #ONK_USL_RC k WHERE k.GUID_Case=t.ID_C AND k.USL_TIP=t.USL_TIP 
																															AND isnull(k.HIR_TIP,0)=isnull(t.HIR_TIP ,0) 
																															AND isnull(k.LEK_TIP_L,0)=isnull(t.LEK_TIP_L,0) 
																															AND isnull(k.LEK_TIP_V,0)=isnull(t.LEK_TIP_V,0) 
																															AND isnull(k.LUCH_TIP,0)=isnull(t.LUCH_TIP,0) )
					)
			BEGIN 			
				insert @et values(588,114)
			END  
			



			-------------проверка случаев в счетах и на то должны ли они быть
			if(isnull(@caseRC,0)-isnull(@caseA,0))<>0
			begin
				insert @et values(588,15)
			end     
end
IF NOT EXISTS(SELECT * FROM @et)
BEGIN
	--Проверка диагнозов DS2 и DS3
--не корректная проверка			
			DECLARE @ds1 INT,
				@ds2 INT			
			SELECT @ds1=COUNT(*)
			FROM #tDisgnosis d1 INNER JOIN #tDS d2 ON
					d2.ID_C=d1.GUID_Case 
					AND ISNULL(d2.TypeDiagnosis,0)=ISNULL(d1.TypeDiagnosis,0) 
					AND ISNULL(d2.DS,0)=ISNULL(d1.Code,0)
			IF(@ds1-@ds2)<>0
			BEGIN
				insert @et values(588,15)
			END
END
--Поиск некорректных данных с ошибкой 588 в USL
--проверка на порядок
if NOT EXISTS(select * from @et)
begin
IF @year<2014
BEGIN	
	if EXISTS(select * from (select ROW_NUMBER() OVER(order by CAST(t.IDSERV AS INT) asc) as id, CAST(t.IDSERV AS INT) AS IDSERV from #t6 t) t where id<>IDSERV)
	begin			
		select * from (select ROW_NUMBER() OVER(order by CAST(t.IDSERV AS INT) asc) as id, CAST(t.IDSERV AS INT) AS IDSERV from #t6 t) t where id<>IDSERV
		insert @et values(588,16)
	END
END	
end
PRINT('test MU')
if NOT EXISTS(select * from @et)
begin
declare @meduslugiRC int,
		@meduslugiA int
--внес изменения т.к при зачистке данных в базе Реестров сведений за Страмным удалил хирургические операции.
	select @meduslugiA=count(DISTINCT ID_U) from #t6 t 
	
	CREATE TABLE #meduslugi 
		(
			GUID_Case uniqueidentifier NOT NULL,
			id int NOT NULL,
			GUID_MU uniqueidentifier NOT NULL,
			rf_idMO char(6) NOT NULL,
			rf_idV002 smallint NULL,
			rf_idV001 VARCHAR(15),
			IsChildTariff bit NOT NULL,
			DateHelpBegin date NOT NULL,
			DateHelpEnd date NOT NULL,
			DiagnosisCode char(10) NOT NULL,
			MUCode varchar(16) NOT NULL,
			Quantity decimal(6, 2) NOT NULL,
			Price decimal(15, 2) NOT NULL,
			TotalPrice decimal(15, 2) NOT NULL,
			rf_idV004 int NOT NULL,
			Comments VARCHAR(250),
			rf_idDoctor VARCHAR(25),
			P_OTK TINYINT ,
			rf_idDepartmentMO int,
			rf_idSubMO varchar(6)
		)		
	EXEC usp_GetMeduslugiFromRegisterCaseDB @account--,@codeMO,@month,@year						
	
	
	select @meduslugiRC=COUNT(distinct t0.GUID_MU)
	from #meduslugi t0 inner join #t6 t on
			ID_C=t0.GUID_Case
			and ID_U= GUID_MU
			and LPU=rf_idMO
			and PROFIL=rf_idV002
			AND ISNULL(VID_VME,'bla-bla')=ISNULL(rf_idV001,'bla-bla')
			and DET =IsChildTariff
			and DATE_IN =DateHelpBegin
			and DATE_OUT =DateHelpEnd
			and rtrim(DS) =rtrim(DiagnosisCode)
			and rtrim(CODE_USL)=rtrim(MUCode)
			and KOL_USL= Quantity
			and TARIF=Price
			and SUMV_USL =TotalPrice
			and PRVS=rf_idV004
			AND ISNULL(t0.Comments,'bla-bla')=ISNULL(t.COMENTU,'bla-bla')
			AND ISNULL(rf_idDoctor,'0')=ISNULL(t.CODE_MD,'0')
			AND ISNULL(rf_idDepartmentMO,0)=ISNULL(t.PODR,0)
			AND ISNULL(rf_idSubMO,'bla-bla')=ISNULL(t.LPU_1,'bla-bla')					
	
	if(isnull(@meduslugiRC,0)-isnull(@meduslugiA,0))<>0
	begin
		insert @et values(588,17)
	end
end

--проверка на кооректное выставление мед.услуг в случае
if NOT EXISTS(select * from @et)
begin
	if EXISTS(	
				select c.ID_C,c.SUMV
				from #t5 c inner join #t6 m on 
						c.ID_C=m.ID_C
						and c.IDCASE=m.IDCASE
				where c.CODE_MES1 is null
				group by c.ID_C,c.SUMV
				having c.SUMV<>cast(SUM(m.KOL_USL*m.TARIF) as decimal(15,2))
			  )	
	begin
			insert @et values(588,18)
	end
end

if NOT EXISTS(select * from @et)
begin
---------поиск случаев без медуслуг
	if EXISTS(	
				select c.* 
				from #t5 c left join #t6 m on 
						c.ID_C=m.ID_C
						and c.IDCASE=m.IDCASE
				where c.CODE_MES1 is null and m.ID_U is null
			  )	
	begin
		insert @et values(588,19)
	end
END
----------01.04.2013
if NOT EXISTS(select * from @et)
begin
---------поиск случаев без медуслуг для ЗС с кодом 2.78.*; 70.*.*;72.*.*
	if EXISTS(	
				select c.* 
				from #t5 c INNER JOIN (SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=2 AND MUUnGroupCode=78
										UNION ALL
										SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=70
										UNION ALL
										SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=72
										) mc ON
						c.CODE_MES1=mc.MU
							left join #t6 m on 
						c.ID_C=m.ID_C
						and c.IDCASE=m.IDCASE
				where c.CODE_MES1 IS NOT NULL and m.ID_U is null
			  )	
	begin
		insert @et values(588,19)
	end
END
PRINT('test H end')
---------------------------------Проверка данных из файла L----------------------------------------------------------------------
if NOT EXISTS(select * from @et)
begin
	declare @persA int,
			@persRC int,	
			@idf int
--------не верна работала выборка файла. не был учтен отчетный год			
	select top 1 @idf=f.rf_idFiles
	from RegisterCases.dbo.t_FileBack f inner join RegisterCases.dbo.t_RegisterCaseBack a on 
				f.id=a.rf_idFilesBack
				and f.CodeM=@codeMO
				and a.NumberRegister=@number
				and a.PropertyNumberRegister=@property
				AND a.ReportYear=@year
				
	select @persRC=COUNT(*) 
	from(
			select distinct r1.ID_Patient,rp.Fam,rp.Im,rp.Ot,rp.rf_idV005 as W,rp.BirthDay as DR,ra.Fam as Fam_P, ra.Im as IM_P, ra.Ot as Ot_P,ra.rf_idV005 as W_P,
				  ra.BirthDay as DR_P, rp.BirthPlace as MR, doc.rf_idDocumentType as DOCTYPE, doc.SeriaDocument as DOCSER, doc.NumberDocument as DOCNUM, 
				  doc.SNILS, doc.OKATO as OKATOG, doc.OKATO_Place as OKATOP, rp.TEL
			from RegisterCases.dbo.t_FileBack f inner join RegisterCases.dbo.t_RegisterCaseBack a on 
				f.id=a.rf_idFilesBack
				and f.rf_idFiles=@idF			
									inner join RegisterCases.dbo.t_RecordCaseBack r on
				a.id=r.rf_idRegisterCaseBack
									INNER JOIN RegisterCases.dbo.t_CaseBack cp ON
				r.id=cp.rf_idRecordCaseBack					
				and cp.TypePay=1
									inner join RegisterCases.dbo.t_RecordCase r1 on
				r.rf_idRecordCase=r1.id
									inner join RegisterCases.dbo.t_PatientBack p on
				r.id=p.rf_idRecordCaseBack
				and p.rf_idSMO=@smo
									inner join RegisterCases.dbo.t_RefRegisterPatientRecordCase rf on				
				r1.id=rf.rf_idRecordCase
									inner join RegisterCases.dbo.t_RegisterPatient rp on
				rf.rf_idRegisterPatient=rp.id
				and rp.rf_idFiles=@idF
									left join RegisterCases.dbo.t_RegisterPatientAttendant ra on
				rp.id=ra.rf_idRegisterPatient
									left join RegisterCases.dbo.t_RegisterPatientDocument doc on
				rp.id=doc.rf_idRegisterPatient
		) t inner join #t8 t1 on
			t.ID_Patient=t1.ID_PAC
			and ISNULL(t.FAM,'НЕТ') =ISNULL(t1.FAM,'НЕТ') 
			and ISNULL(t.IM,'НЕТ') =ISNULL(t1.IM,'НЕТ') 
			and ISNULL(t.OT,'НЕТ')=ISNULL(t1.OT,'НЕТ')
			and t.W =t1.W 
			and t.DR =t1.DR 
			and isnull(t.FAM_P,'')=isnull(t1.FAM_P,'')
			and isnull(t.IM_P,'')=isnull(t1.IM_p,'')
			and isnull(t.OT_P,'') =isnull(t1.OT_P,'') 
			--and isnull(t.W_P,'') =isnull(t1.W_P,'') 
			and isnull(t.DR_P,'') =isnull(t1.DR_P,'') 
			and isnull(t.MR,'') =isnull(t1.MR,'') 
			and isnull(t.DOCTYPE,'')=isnull(t1.DOCTYPE,'')
			and isnull(t.DOCSER,'') =isnull(t1.DOCSER,'') 
			and isnull(t.DOCNUM,'') =isnull(t1.DOCNUM,'') 
			and isnull(t.SNILS,'') =isnull(t1.SNILS,'') 
			and isnull(t.OKATOG,'') =isnull(t1.OKATOG,'') 
			and isnull(t.OKATOP,'') =isnull(t1.OKATOP,'') 
			AND ISNULL(t.TEL,'bla-bla')=ISNULL(t1.TEL,'bla-bla')

	select @persA=COUNT(*) from #t8

	if(@persA-@persRC)<>0	
	begin
		insert @et values(588,20)
	end	
end
-------------------------------------------------------------------------------------------------------

--возвращаем @idFile и 0 или 1 отличное от нуля(0- ошибок нету,  1-ошибки есть)
IF EXISTS (select * from @et)
begin
	insert t_FileError([FileName]) values(@fileName)
	
	set @idFile=SCOPE_IDENTITY()
	
	insert t_Errors(rf_idFileError,ErrorNumber,rf_sprErrorAccount) select distinct @idFile,errorId,id from @et	
	
	select @idFile,1
END

--------------------------------------------
drop table #t3
drop table #t5
drop table #t6
drop table #t8
if OBJECT_ID('tempDB..#case',N'U') is not null
	DROP TABLE #case
if OBJECT_ID('tempDB..#meduslugi',N'U') is not null
	DROP TABLE #meduslugi
if OBJECT_ID('tempDB..#tTalon',N'U') is not null
	DROP TABLE #tTalon
if OBJECT_ID('tempDB..#tCoeff',N'U') is not null
	DROP TABLE #tCoeff
if OBJECT_ID('tempDB..#tBW',N'U') is not null
	DROP TABLE #tBW
if OBJECT_ID('tempDB..#tmpKiro',N'U') is not null
	DROP TABLE #tmpKiro
if OBJECT_ID('tempDB..#tmpAddCriterion',N'U') is not null
	DROP TABLE #tmpAddCriterion
