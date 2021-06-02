USE AccountOMS
GO
DECLARE @doc xml,
		@patient xml,
		@file varbinary(max)=0,
		@dateStart DATETIME,
		@fileName varchar(26),
		@fileKey varbinary(max)=null

SELECT @dateStart=GETDATE()		
SELECT	@doc=HRM.ZL_LIST				
FROM	OPENROWSET(BULK 'f:\test\RA\HM103001T34_180600011.XML',SINGLE_BLOB) HRM (ZL_LIST)

SELECT	@patient=HRM.ZL_LIST				
FROM	OPENROWSET(BULK 'f:\test\RA\LM103001T34_180600011.XML',SINGLE_BLOB) HRM (ZL_LIST)
-----------------------------------------------------------------------------------------------------------

DECLARE @idoc int,
		@ipatient int,
		@id int,
		@idFile int--,

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
	NEXT_VISIT date,
	NPR_DATE DATE,
	PROFIL_K smallint,
	P_CEL NVARCHAR(3),
	TAL_NUM NVARCHAR(20),
	DN TINYINT,
	DKK2 NVARCHAR(10),
	DS_ONK TINYINT, --16.07.208
	--REAB TINYINT, --16.07.208
	C_ZAB TINYINT, --16.07.208
	MSE TINYINT --16.07.208		
)
		
CREATE TABLE #tDS(IDCASE int,ID_C uniqueidentifier,DS varchar(10), TypeDiagnosis tinyint)

CREATE TABLE #tBW(IDCASE int,ID_C uniqueidentifier, BirthWeight smallint)					 
CREATE TABLE #tCoeff(IDCASE BIGINT,ID_C uniqueidentifier, CODE_SL SMALLINT,VAL_C DECIMAL(3,2))
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
			SD_Z INT './SD_Z'
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
			--Reab TINYINT,--16.07.208
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
INSERT #tCoeff( IDCASE, ID_C, CODE_SL, VAL_C )
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
SELECT IDCASE,ID_C,DS1_T ,STAD,ONK_T,ONK_N,ONK_M,MTSTZ,SOD,PR_CONS, DT_CONS
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
SELECT IDCASE, ID_C,DIAG_TIP, DIAG_CODE, DIAG_RSLT, DIAG_DATE
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
EXEC sp_xml_removedocument @ipatient
--раскладываем данные по таблица в базе счета
begin transaction
	
	------Insert into RegisterCase's tables------------------------------
	DECLARE @countSluch int
	SELECT @countSluch=SD_Z from @t1		

	insert t_File(DateRegistration,FileVersion,DateCreate,FileNameHR,FileNameLR,FileZIP, CountSluch)
	select GETDATE(),[VERSION],DATA,FILENAME1,[FILENAME],@file, @countSluch  from @t7--new 
	select @idFile=SCOPE_IDENTITY()
		
	if @fileKey is not null
	begin
		insert t_FileKey(rf_idFiles,FileNameKey,FileKey) values(@idFile,@fileName,@fileKey)
	end

	insert t_RegistersAccounts(rf_idFiles,idRecord,rf_idMO,ReportYear,ReportMonth,NumberRegister,PrefixNumberRegister,PropertyNumberRegister,
								DateRegister,rf_idSMO,AmountPayment,Comments,Letter)
	select @idFile,CODE,CODE_MO,[YEAR],[MONTH],dbo.fn_NumberRegister(NSCHET),dbo.fn_PrefixNumberRegister(NSCHET),dbo.fn_PropertyNumberRegister(NSCHET),
			DSCHET,PLAT,SUMMAV,COMENTS,dbo.fn_LetterNumberRegister(NSCHET)
	from @t2
	select @id=SCOPE_IDENTITY()
	----------14.01.2014----------
	insert t_RecordCasePatient(rf_idRegistersAccounts,idRecord,IsNew,ID_Patient,rf_idF008,SeriaPolis,NumberPolis,NewBorn,AttachLPU,BirthWeight)
	output inserted.id,inserted.ID_Patient,inserted.idRecord into @tempID select @id,N_ZAP,PR_NOV,ID_PAC,VPOLIS,SPOLIS,NPOLIS,NOVOR,MO_PR ,VNOV_D from #t3
	
	insert t_PatientSMO(rf_idRecordCasePatient,rf_idSMO,OKATO,Name,ENP,ST_OKATO)
	select t2.id,t1.SMO,t1.SMO_OK, t1.SMO_NAM,ENP,ST_OKATO--new
	from #t3 t1 inner join @tempID t2 on
				t1.ID_PAC=t2.ID_PAC
				AND t1.N_ZAP=t2.N_ZAP
	where t1.SMO is not null
	group by t2.id,t1.SMO,t1.SMO_OK, t1.SMO_NAM,ENP,ST_OKATO--new

	----------Disability-----------------------
	INSERT dbo.t_Disability( rf_idRecordCasePatient ,TypeOfGroup ,DateDefine ,rf_idReasonDisability ,Diagnosis)
	SELECT distinct  t2.id, t1.INV, t1.DATA_INV, t1.REASON_INV, t1.DS_INV
	from #tDisabiliti t1 inner join @tempID t2 on
				t1.ID_PAC=t2.ID_PAC and
				t1.N_ZAP=t2.N_ZAP 
	
	declare @tmpCase as table(id int,idRecord BIGINT,GUID_CASE uniqueidentifier)
	----------2012-12-01----------
	insert t_Case(rf_idRecordCasePatient, idRecordCase, GUID_Case, rf_idV006, rf_idV008,
				  rf_idV014,rf_idV018,rf_idV019,
				  rf_idDirectMO, HopitalisationType, rf_idMO, rf_idV002, IsChildTariff, 
				  NumberHistoryCase, DateBegin, DateEnd, rf_idV009, rf_idV012, rf_idV004, 
				  IsSpecialCase, rf_idV010, AmountPayment, Comments,Age,[Emergency],rf_idDoctor,IT_SL, TypeTranslation,rf_idDepartmentMO, rf_idSubMO, MSE, C_ZAB)
	output inserted.id,inserted.idRecordCase,inserted.GUID_Case into @tmpCase
	select t2.id,t1.IDCASE,t1.ID_C, t1.USL_OK,t1.VIDPOM, 
			t1.FOR_POM,t1.VID_HMP,t1.METOD_HMP,
			t1.NPR_MO,t1.EXTR,t1.LPU,t1.PROFIL,t1.DET,t1.NHISTORY,t1.DATE_1,t1.DATE_2,t1.RSLT,t1.ISHOD,
			t1.PRVS,t1.OS_SLUCH,t1.IDSP,t1.SUMV,t1.COMENTSL
			,CASE WHEN t3.DR=t1.DATE_1 THEN 0 ELSE (DATEDIFF(YEAR,t3.DR,t1.DATE_1)-CASE WHEN 100*MONTH(t3.DR)+DAY(t3.DR)>100*MONTH(t1.DATE_1)+DAY(t1.DATE_1)-1 THEN 1 ELSE 0 END) end, F_SP
			,CASE WHEN t1.IDDOCT='0' THEN NULL ELSE t1.IDDOCT END,t1.IT_SL, t1.P_PER, t1.PODR, t1.LPU_1
			,MSE, C_ZAB
	from #t5 t1 inner join @tempID t2 on
			t1.N_ZAP=t2.N_ZAP and
			t1.ID_PAC=t2.ID_PAC
				left join #t8 t3 on
			t1.ID_PAC=t3.ID_PAC
	group by t2.id,t1.IDCASE,t1.ID_C, t1.USL_OK,t1.VIDPOM, 
			t1.FOR_POM,t1.VID_HMP,t1.METOD_HMP,
			t1.NPR_MO,t1.EXTR,t1.LPU,t1.PROFIL,t1.DET,t1.NHISTORY,t1.DATE_1,t1.DATE_2,t1.RSLT,t1.ISHOD,
			t1.PRVS,t1.OS_SLUCH,t1.IDSP,t1.SUMV,t1.COMENTSL
			,CASE WHEN t3.DR=t1.DATE_1 THEN 0 ELSE (DATEDIFF(YEAR,t3.DR,t1.DATE_1)-CASE WHEN 100*MONTH(t3.DR)+DAY(t3.DR)>100*MONTH(t1.DATE_1)+DAY(t1.DATE_1)-1 THEN 1 ELSE 0 END) end, F_SP
			,CASE WHEN t1.IDDOCT='0' THEN NULL ELSE t1.IDDOCT END,t1.IT_SL, t1.P_PER, t1.PODR, t1.LPU_1
			,MSE, C_ZAB
	
	------------------------------------------------------------------------------------------------------------------
	INSERT dbo.t_SlipOfPaper( rf_idCase ,GetDatePaper ,DateHospitalization,NumberTicket)
	SELECT c.id,t1.TAL_P, t1.TAL_D,t1.TAL_NUM
	from @tmpCase c inner join #t5 t1 on
			c.GUID_Case=t1.ID_C
			and c.idRecord=t1.IDCASE
	WHERE t1.TAL_P IS NOT NULL or t1.TAL_D IS NOT NULL OR t1.TAL_NUM IS NOT null
	----------NPR_DATE----------------------
	INSERT dbo.t_DirectionDate( rf_idCase,DirectionDate)
	SELECT c.id,t1.NPR_DATE
	from @tmpCase c inner join #t5 t1 on
			c.GUID_Case=t1.ID_C
			and c.idRecord=t1.IDCASE
	WHERE t1.NPR_DATE IS not NULL
	--16.07.2018
	-------------t_DS_ONK_REAB-----------
	INSERT dbo.t_DS_ONK_REAB( rf_idCase, DS_ONK )
	SELECT c.id,t1.DS_ONK--,t1.REAB
	from @tmpCase c inner join #t5 t1 on
			c.GUID_Case=t1.ID_C
			and c.idRecord=t1.IDCASE
	WHERE t1.DS_ONK IS not NULL --OR t1.REAB IS NOT NULL
	----------PROFIL_K----------------------
	INSERT dbo.t_ProfileOfBed( rf_idCase,rf_idV020)
	SELECT c.id,t1.PROFIL_K
	from @tmpCase c inner join #t5 t1 on
			c.GUID_Case=t1.ID_C
			and c.idRecord=t1.IDCASE
	WHERE t1.PROFIL_K IS not NULL
	----------P_CEL----------------------
	INSERT dbo.t_PurposeOfVisit( rf_idCase, rf_idV025, DN )
	SELECT c.id,t1.P_CEL, t1.DN
	from @tmpCase c inner join #t5 t1 on
			c.GUID_Case=t1.ID_C
			and c.idRecord=t1.IDCASE
	WHERE t1.P_CEL IS not NULL OR t1.DN IS NOT NULL
	----------DKK2----------------------
	INSERT dbo.t_CombinationOfSchema
	        ( rf_idCase, rf_idV024 )
	SELECT c.id,t1.DKK2
	from @tmpCase c inner join #t5 t1 on
			c.GUID_Case=t1.ID_C
			and c.idRecord=t1.IDCASE
	WHERE t1.DKK2 IS not NULL
	--------NAPR------------
	INSERT dbo.t_DirectionMU( rf_idCase ,DirectionDate ,TypeDirection ,MethodStudy ,DirectionMU)
	SELECT c.id, t1.NAPR_DATE ,t1.NAPR_V ,t1.MET_ISSL ,t1.NAPR_USL
	from @tmpCase c inner join #NAPR t1 on
			c.GUID_Case=t1.ID_C	
			and c.idRecord=t1.IDCASE	
	WHERE t1.NAPR_DATE IS NOT NULL

	INSERT dbo.t_AdditionalCriterion( rf_idCase, rf_idAddCretiria )
	SELECT c.id,t1.AD_CRITERION
	from @tmpCase c inner join #t5 t1 on
			c.GUID_Case=t1.ID_C
			and c.idRecord=t1.IDCASE
	WHERE t1.AD_CRITERION IS NOT NULL

	INSERT dbo.t_NextVisitDate( rf_idCase, DateVizit )
	SELECT c.id,t1.NEXT_VISIT
	from @tmpCase c inner join #t5 t1 on
			c.GUID_Case=t1.ID_C
			and c.idRecord=t1.IDCASE
	WHERE t1.NEXT_VISIT IS NOT NULL

	---------------------------------------------------------------------------------------------------------
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
	select DS,c.id,TypeDiagnosis 
	from @tmpCase c inner join #tDS t1 on
			c.GUID_Case=t1.ID_C	
			and c.idRecord=t1.IDCASE	
			
	--insert data into t_BirthWeight		
	insert t_BirthWeight(rf_idCase,BirthWeight)		
	select c.id,BirthWeight
	from @tmpCase c inner join #tBW t1 on
			c.GUID_Case=t1.ID_C	
			and c.idRecord=t1.IDCASE	

	INSERT dbo.t_Coefficient
        ( rf_idCase, Code_SL, Coefficient )
	select c.id,t1.CODE_SL,t1.VAL_C
	from @tmpCase c inner join #tCoeff t1 on
			c.GUID_Case=t1.ID_C	
			and c.idRecord=t1.IDCASE

	INSERT dbo.t_Kiro( rf_idCase, rf_idKiro, ValueKiro )
	select c.id,t1.CODE_KIRO,t1.VAL_K
	from @tmpCase c inner join #tKiro t1 on
			c.GUID_Case=t1.ID_C	
			and c.idRecord=t1.IDCASE	
	WHERE t1.CODE_KIRO IS NOT NULL

	--16.07.2018
	------------ONKOLOGIA----------------------
	DECLARE @tONKID AS TABLE(id INT, rf_idCase bigint)
	INSERT dbo.t_ONK_SL( rf_idCase ,DS1_T ,rf_idN002 ,rf_idN003 ,rf_idN004 ,rf_idN005 ,IsMetastasis ,TotalDose, ConsultationInfo, DateConsultation)
	OUTPUT INSERTED.id, INSERTED.rf_idCase INTO @tONKID
	SELECT c.id, DS1_T TIN,STAD,ONK_T,ONK_N,ONK_M,MTSTZ,SOD,PR_CONS, DT_CONS
	from @tmpCase c inner join #ONK_SL t1 on
			c.GUID_Case=t1.ID_C	
			and c.idRecord=t1.IDCASE	
	WHERE t1.STAD IS NOT null
	
	INSERT dbo.t_DiagnosticBlock( rf_idONK_SL ,TypeDiagnostic ,CodeDiagnostic ,ResultDiagnostic, DateDiagnostic)
	SELECT o.id, DIAG_TIP, DIAG_CODE, DIAG_RSLT,Diag_Date
	from @tmpCase c INNER JOIN @tONKID o ON
			c.id=o.rf_idCase
					inner join #B_DIAG t1 on
			c.GUID_Case=t1.ID_C	
			and c.idRecord=t1.IDCASE	
	WHERE t1.DIAG_TIP IS NOT NULL
	
	INSERT dbo.t_Contraindications( rf_idONK_SL ,Code ,DateContraindications)
	SELECT o.id, PROT, D_PROT
	from @tmpCase c INNER JOIN @tONKID o ON
			c.id=o.rf_idCase
					inner join #B_PROT t1 on
			c.GUID_Case=t1.ID_C	
			and c.idRecord=t1.IDCASE	
	WHERE t1.PROT IS NOT null
	
	INSERT dbo.t_ONK_USL( rf_idCase ,GUID_MU ,rf_idN013 ,TypeSurgery ,TypeDrug ,TypeCycleOfDrug ,TypeRadiationTherapy)
	SELECT c.id,t1.ID_U ,t1.USL_TIP , t1.HIR_TIP , t1.LEK_TIP_L ,t1.LEK_TIP_V ,t1.LUCH_TIP
	from @tmpCase c inner join #ONK_USL t1 on
			c.GUID_Case=t1.ID_C	
			and c.idRecord=t1.IDCASE
	WHERE t1.USL_TIP IS NOT NULL
	--------------------------------------------------------------------------------------------------------------------
	insert t_MES(MES,rf_idCase,TypeMES,Quantity,Tariff)	
	select t1.CODE_MES1,c.id,1,t1.ED_COL,t1.TARIF
	from @tmpCase c inner join #t5 t1 on
			c.GUID_Case=t1.ID_C
			and c.idRecord=t1.IDCASE
	where t1.CODE_MES1 is not null
	group by t1.CODE_MES1,c.id,t1.ED_COL,t1.TARIF
	
	
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
	
	----get data from new tables    
	SELECT * FROM dbo.t_ONK_SL
	SELECT * FROM dbo.t_ONK_USL
	SELECT * FROM t_Contraindications
	SELECT * from t_DiagnosticBlock
	SELECT * FROM t_DirectionMU
	-------------------------------------------------------------------------------------------------------------------------
--добавить обработку хирургических операций с помощью конструкции if exists
	
	insert t_Meduslugi(rf_idCase,id,GUID_MU,rf_idMO, rf_idV002,MUSurgery, IsChildTariff, DateHelpBegin, DateHelpEnd, DiagnosisCode,MUGroupCode,MUUnGroupCode
						,MUCode, Quantity, Price, TotalPrice, rf_idV004, Comments,rf_idDepartmentMO,rf_idDoctor,rf_idSubMO)
	select c.id,t1.IDSERV, t1.ID_U, t1.LPU, t1.PROFIL,t1.VID_VME, t1.DET,t1.DATE_IN,t1.DATE_OUT,t1.DS,mu.MUGroupCode,mu.MUUnGroupCode,mu.MUCode			
			,t1.KOL_USL,t1.TARIF,t1.SUMV_USL,t1.PRVS,t1.COMENTU, PODR
			,CASE WHEN t1.CODE_MD='0' THEN NULL ELSE t1.CODE_MD END, t1.LPU_1
	from #t6 t1 inner join @tmpCase c on
				t1.ID_C=c.GUID_Case
				and t1.IDCASE=c.idRecord	
					inner join (SELECT MU ,MUGroupCode,MUUnGroupCode,MUCode FROM vw_sprMU  
								UNION ALL SELECT IDRB,0,0,0 FROM dbo.vw_V001 
								UNION SELECT d.code ,0,0,0 FROM OMS_NSI.dbo.sprDentalMU d) mu on
			t1.CODE_USL=mu.MU
	where t1.ID_U is not null
	group by c.id,t1.IDSERV, t1.ID_U, t1.LPU, t1.PROFIL,t1.VID_VME, t1.DET,t1.DATE_IN,t1.DATE_OUT,t1.DS,mu.MUGroupCode,mu.MUUnGroupCode,mu.MUCode
			,t1.KOL_USL,t1.TARIF,t1.SUMV_USL,t1.PRVS,t1.COMENTU,PODR,CASE WHEN t1.CODE_MD='0' THEN NULL ELSE t1.CODE_MD END, t1.LPU_1
	--вставка хирургического вмешательства
	
	----------------------------------------------------------------------------------------------------------------------

	insert t_RegisterPatient(rf_idFiles, ID_Patient, Fam, Im, Ot, rf_idV005, BirthDay, BirthPlace,rf_idRecordCase,TEL)
		output inserted.id,inserted.ID_Patient into @tableId
	select @idFile,t1.ID_PAC,t1.FAM,t1.IM,case when t1.OT='НЕТ' then null else t1.OT end,t1.W,t1.DR,t1.MR,t2.id,t1.TEL
	from #t8 t1 left join @tempID t2 on
					t1.ID_PAC=t2.ID_PAC
	group by t1.ID_PAC,t1.FAM,t1.IM,case when t1.OT='НЕТ' then null else t1.OT end,t1.W,t1.DR,t1.MR,t2.id,t1.TEL

	insert t_RegisterPatientDocument(rf_idRegisterPatient, rf_idDocumentType, SeriaDocument, NumberDocument, SNILS, OKATO, OKATO_Place, Comments)
	select t2.id,t1.DOCTYPE,t1.DOCSER,t1.DOCNUM,t1.SNILS,t1.OKATOG,t1.OKATOP,t1.COMENTP
	from #t8 t1 inner join @tableId t2 on
			t1.ID_PAC=t2.ID_PAC
	where (t1.DOCTYPE is not null) or (t1.DOCSER is not null) or (t1.DOCNUM is not null)

	insert t_RegisterPatientAttendant(rf_idRegisterPatient, Fam, Im, Ot, rf_idV005, BirthDay)
	select t2.id,t1.FAM_P,t1.IM_P,t1.OT_P,t1.W_P,t1.DR_P
	from #t8 t1 inner join @tableId t2 on
			t1.ID_PAC=t2.ID_PAC
	where (t1.FAM_P is not null) or (t1.IM_P is not null) or (t1.W_P is not null) or (t1.DR_P is not null)
	------------------------------------------------------------------
	INSERT dbo.t_ReliabilityPatient( rf_idRegisterPatient ,TypeReliability ,IsAttendant)
	SELECT DISTINCT t2.id, t1.DOST, t1.IsAttendant
	FROM #tDOST t1 INNER JOIN  @tableId t2 on
			t1.ID_PAC=t2.ID_PAC
	WHERE t1.DOST IS NOT NULL	
ROLLBACK	
	

select @idFile,0
--------------------------------------------
GO
drop table #t3
go
drop table #t5
go
drop table #t6
go
DROP TABLE #tBW
go
DROP TABLE #tDS
go
DROP TABLE #tDOST
go
drop table #t8
go
drop table #ONK_USL
go
drop table #NAPR
go
DROP TABLE #ONK_SL
go
DROP TABLE #tDisabiliti
go
DROP TABLE #tCoeff
go
DROP TABLE #tKiro
go
DROP TABLE #B_DIAG
GO
DROP TABLE #B_PROT
GO
