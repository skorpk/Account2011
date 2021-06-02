use AccountOMS
go
declare @p1 xml,
		@p2 XML,
		@dateStart DATETIME

SELECT @dateStart=GETDATE()		
SELECT	@p1=HRM.ZL_LIST				
FROM	OPENROWSET(BULK 'd:\Test\HM103001S34007_191000047.xml',SINGLE_BLOB) HRM (ZL_LIST)

SELECT	@p2=LRM.PERS_LIST				
FROM	OPENROWSET(BULK 'd:\Test\LM103001S34007_191000047.xml',SINGLE_BLOB) LRM (PERS_LIST)


DECLARE @doc XML=@p1,
		@patient XML=@p2,
		@file varbinary(max)=null,
		@fileName varchar(26)='HM103001S34007_191000047',
		@fileKey varbinary(max)=null--файл цифровой подписи

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
	ENP VARCHAR(16),--об€зательно к заполнению 
	ST_OKATO VARCHAR(5), 
	SMO nchar(5),
	SMO_OK nchar(5),
	SMO_NAM nvarchar(100),
	NOVOR nchar(9),
	MO_PR nchar(6),
	VNOV_D SMALLINT
)
------------------сведени€ о признании лица инвалидом---------------------
CREATE TABLE #tDisabiliti(N_ZAP int,ID_PAC nvarchar(36), INV TINYINT,DATA_INV DATE, REASON_INV TINYINT, DS_INV VARCHAR(10))

create table #t5(N_ZAP int,
				 ID_PAC nvarchar(36),
				 IDCASE bigint,
				 ID_C uniqueidentifier,
				 USL_OK tinyint,
				 VIDPOM smallint,
				 FOR_POM tinyint,
				 VID_HMP varchar(19),
				 METOD_HMP int,
				 NPR_MO nchar(6),				 
				 EXTR tinyint,
				 LPU nchar(6),
				 LPU_1 nchar(8),
				 PODR INT,
				 PROFIL smallint, 				 
				 DET tinyint,	  				 
				 TAL_D DATE, 
				 TAL_P DATE,	  				 
				 NHISTORY nvarchar(50), 
				 P_PER CHAR(1),
				 DATE_1 date,
				 DATE_2 date,
				 DS0 nchar(10),
				 DS1 nchar(10),
				 DN TINYINT,--18.04.2018
				 CODE_MES1 nchar(20),
				 RSLT smallint,
				 ISHOD smallint,
				 PRVS bigint,
				 OS_SLUCH tinyint,
				 IDSP tinyint,
				 ED_COL numeric(5, 2),
				 TARIF numeric(15, 2),
				 SUMV numeric(15, 2),
				 REFREASON tinyint,
				 SANK_MEK numeric(15, 2),
				 SANK_MEE numeric(15, 2),
				 SANK_EKMP numeric(15, 2),
				 COMENTSL nvarchar(250),
				 F_SP tinyint,
				 IDDOCT VARCHAR(25),				 
				 IT_SL DECIMAL(3,2),
				 AD_CRITERION VARCHAR(20),
				 NEXT_VISIT DATE,
				 NPR_DATE DATE,
				 PROFIL_K smallint,
				 P_CEL NVARCHAR(3),
				 TAL_NUM NVARCHAR(20),
				 DKK2 NVARCHAR(10),
				 DS_ONK TINYINT, 
				 C_ZAB TINYINT,
				 MSE TINYINT,
				 SL_ID UNIQUEIDENTIFIER,
				 VB_P TINYINT,
				 Date_Z_1 DATE, 		
				 Date_Z_2 DATE,
				 KD_Z SMALLINT,
				 SUM_M DECIMAL(15,2),
				 KD SMALLINT
				 )
					 
CREATE TABLE #tDS(IDCASE int,ID_C uniqueidentifier,DS varchar(10), TypeDiagnosis TINYINT, SL_ID UNIQUEIDENTIFIER)

CREATE TABLE #tBW(IDCASE int,ID_C uniqueidentifier, BirthWeight SMALLINT, SL_ID UNIQUEIDENTIFIER)

CREATE TABLE #tCoeff(IDCASE BIGINT,ID_C uniqueidentifier, CODE_SL SMALLINT,VAL_C DECIMAL(3,2), SL_ID UNIQUEIDENTIFIER)
---new tempory table 27.12.2017
CREATE TABLE #tKiro(IDCASE BIGINT,ID_C UNIQUEIDENTIFIER,CODE_KIRO INT, VAL_K DECIMAL(3,2), SL_ID UNIQUEIDENTIFIER)
--20.12.2018
CREATE TABLE #ONK_SL
					(
						IDCASE int,
						ID_C UNIQUEIDENTIFIER,
						DS1_T TINYINT,
						STAD SMALLINT, --об€зательные к заполнению
						ONK_T SMALLINT,--об€зательные к заполнению
						ONK_N SMALLINT,--об€зательные к заполнению
						ONK_M SMALLINT,--об€зательные к заполнению
						MTSTZ TINYINT,
						SOD DECIMAL(5,2),						
						SL_ID UNIQUEIDENTIFIER,
						K_FR TINYINT,
						WEI DECIMAL(5,1),
						HEI TINYINT,
						BSA DECIMAL(3,2)						
						 )
CREATE TABLE #B_DIAG(IDCASE int,ID_C UNIQUEIDENTIFIER,DIAG_TIP TINYINT,DIAG_CODE SMALLINT, DIAG_RSLT SMALLINT, DIAG_DATE date, SL_ID UNIQUEIDENTIFIER, REC_RSLT TINYINT)
CREATE TABLE #B_PROT(IDCASE int,ID_C UNIQUEIDENTIFIER,PROT TINYINT,D_PROT DATE, SL_ID UNIQUEIDENTIFIER)
						
					 
create table #t6(IDCASE int,ID_C uniqueidentifier,IDSERV nvarchar(36),ID_U uniqueidentifier,LPU nchar(6),PROFIL smallint,
			VID_VME nvarchar(15),DET tinyint,DATE_IN date,DATE_OUT date,
			DS nchar(10),CODE_USL nchar(20),KOL_USL numeric(6, 2),TARIF numeric(15, 2),SUMV_USL numeric(15, 2),
			PRVS bigint,COMENTU nvarchar(250),PODR INT,CODE_MD VARCHAR(25),LPU_1 NVARCHAR(6), SL_ID UNIQUEIDENTIFIER
			)

create table #NAPR(IDCASE int,ID_C uniqueidentifier,NAPR_DATE DATE, NAPR_MO VARCHAR(6),NAPR_V TINYINT,MET_ISSL TINYINT,NAPR_USL VARCHAR(15), SL_ID UNIQUEIDENTIFIER)
create table #CONS(IDCASE int,ID_C uniqueidentifier,SL_ID UNIQUEIDENTIFIER,PR_CONS TINYINT, DT_CONS DATE)
--20.12.2018
create table #KSG_KPG(IDCASE int,ID_C uniqueidentifier,SL_ID UNIQUEIDENTIFIER,N_KSG VARCHAR(20),CRIT VARCHAR(10),SL_K TINYINT,IT_SL DECIMAL(3,2))
--20.12.2018
create table #ONK_USL
	(
		id TINYINT IDENTITY(1,1) NOT null,
		IDCASE int,
		ID_C uniqueidentifier,
		SL_ID UNIQUEIDENTIFIER,		
		USL_TIP TINYINT, 
		HIR_TIP TINYINT, 
		LEK_TIP_L TINYINT,
		LEK_TIP_V TINYINT,
		LUCH_TIP TINYINT,
		PPTR TINYINT
   )      

create table #LEK_PR
	(
		id_ONKUSL INT,
		IDCASE int,
		ID_C uniqueidentifier,
		SL_ID UNIQUEIDENTIFIER,		
		USL_TIP TINYINT, 
		HIR_TIP TINYINT, 
		LEK_TIP_L TINYINT,
		LEK_TIP_V TINYINT,
		LUCH_TIP TINYINT,
		REGNUM NVARCHAR(6),
		CODE_SH NVARCHAR(10),
		DATE_INJ DATE
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
	TEL VARCHAR(10),
	FAM_P nvarchar(40),
	IM_P nvarchar(40),
	OT_P nvarchar(40),
	W_P tinyint,
	DR_P DATE,
	MR nvarchar(100),
	DOCTYPE nchar(2),
	DOCSER nchar(10),
	DOCNUM nchar(20),
	SNILS nchar(14),
	OKATOG nchar(11),
	OKATOP nchar(11),
	COMENTP nvarchar(250)
)

CREATE TABLE #tDost(ID_PAC nvarchar(36),DOST TINYINT, IsAttendant BIT)

declare @tempID as table(id int, ID_PAC nvarchar(36),N_ZAP int)

declare @tableId as table(id int,ID_PAC nvarchar(36))
---------------------------------------------------------------------
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
			,AD_CRITERION,NEXT_VISIT,NPR_DATE,PROFIL_K,P_CEL,TAL_NUM,DN,DKK2,DS_ONK,MSE, C_ZAB ,VB_P,SL_ID,Date_Z_1, Date_Z_2, KD_Z,SUM_M,KD
        )
SELECT N_ZAP,ID_PAC,IDCASE,ID_C,USL_OK,VIDPOM,
		FOR_POM,
		CASE WHEN LEN(VID_HMP)=0 THEN NULL ELSE VID_HMP END,
		CASE WHEN LEN(METOD_HMP)=0 THEN NULL ELSE METOD_HMP END,--13.01.2014					
		NPR_MO, EXTR, LPU, PROFIL, DET, TAL_D,TAL_P, NHISTORY, P_PER, replace(DATE_1,'-',''), replace(DATE_2,'-',''),DS0,DS1,CODE_MES1,RSLT,ISHOD,
		PRVS,OS_SLUCH,IDSP,ED_COL,TARIF,SUMV,COMENTSL,F_SP,IDDOKT,IT_SL,PODR,LPU_1, AD_CRITERION, replace(NEXT_VISIT,'-',''),NPR_DATE,PROFIL_K,P_CEL,TAL_NUM,DN,DKK2
		,DS_ONK,MSE, C_ZAB, VB_P,SL_ID,Date_Z_1, Date_Z_2, KD_Z,SUM_M,KD
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/Z_SL/SL',3)
	WITH(
			N_ZAP int '../../N_ZAP',
			ID_PAC nvarchar(36) '../../PACIENT/ID_PAC',
			IDCASE bigint '../IDCASE',		 --SL
			ID_C UNIQUEIDENTIFIER '../ID_C',	 --SL
			USL_OK tinyint '../USL_OK',
			VIDPOM smallint '../VIDPOM',
			FOR_POM tinyint '../FOR_POM',
			VID_HMP varchar(19),
			METOD_HMP int ,			
			NPR_MO nchar(6) '../NPR_MO',
			EXTR tinyint ,
			LPU nchar(6) '../LPU',
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
			RSLT smallint '../RSLT',
			ISHOD smallint '../ISHOD',
			PRVS bigint ,			
			OS_SLUCH tinyint ,
			IDSP TINYINT '../IDSP',
			ED_COL DECIMAL(5,2) ,
			TARIF DECIMAL(15,2) ,	
			SUMV DECIMAL(15,2) '../SUMV',				
			COMENTSL NVARCHAR(250),
			F_SP TINYINT,
			IDDOKT VARCHAR(25),
			IT_SL DECIMAL(3,2),
			AD_CRITERION NVARCHAR(20),
			NEXT_VISIT NCHAR(10),			
			NPR_DATE DATE '../NPR_DATE',
			PROFIL_K SMALLINT,
			P_CEL NVARCHAR(3),
			TAL_NUM NVARCHAR(20),
			DN TINYINT,
			DKK2 NVARCHAR(10),
			DS_ONK TINYINT,
			MSE TINYINT '../MSE',
			C_ZAB TINYINT,
			SL_ID UNIQUEIDENTIFIER,
			VB_P TINYINT '../VB_P',
			DATE_Z_1 DATE '../DATE_Z_1', 
			DATE_Z_2 DATE '../DATE_Z_2',  
			KD_Z SMALLINT '../KD_Z',
			SUM_M DECIMAL(15,2),
			KD SMALLINT 
		)

--SELECT * FROM #t5
---множественность диагнозов		

INSERT #tDS (IDCASE,ID_C,DS,TypeDiagnosis,SL_ID) 
SELECT IDCASE,ID_C,DS2,3 , SL_ID
FROM OPENXML (@idoc, '/ZL_LIST/ZAP/Z_SL/SL/DS2',3)
WITH(
			IDCASE int '../../IDCASE',
			ID_C uniqueidentifier '../../ID_C',			
			SL_ID UNIQUEIDENTIFIER '../SL_ID',
			DS2 nchar(10) 'text()'  
	)
	
INSERT #tDS (IDCASE,ID_C,DS,TypeDiagnosis, SL_ID) 
SELECT IDCASE,ID_C,DS3,4 , SL_ID
FROM OPENXML (@idoc, '/ZL_LIST/ZAP/Z_SL/SL/DS3',3)
WITH(
			IDCASE int '../../IDCASE',
			ID_C uniqueidentifier '../../ID_C',			
			SL_ID UNIQUEIDENTIFIER '../SL_ID',			
			DS3 nchar(10) 'text()'  
	)
--SELECT * FROM #tDS

--¬ес новорожденных
INSERT #tBW (IDCASE,ID_C,BirthWeight, SL_ID) 
SELECT IDCASE,ID_C,VNOV_M, SL_ID
FROM OPENXML (@idoc, '/ZL_LIST/ZAP/Z_SL/VNOV_M',3)
WITH(
			IDCASE int '../IDCASE',
			ID_C uniqueidentifier '../ID_C',			
			SL_ID UNIQUEIDENTIFIER '../SL/SL_ID',
			VNOV_M smallint 'text()'  
	)	

--SELECT * FROM #tBW

INSERT #tCoeff( IDCASE, ID_C, CODE_SL, VAL_C, SL_ID )
SELECT IDCASE,ID_C,ID_SL,VAL_C, SL_ID
FROM OPENXML (@idoc, '/ZL_LIST/ZAP/Z_SL/SL/KSG_KPG/SL_KOEF',3)
WITH(
			IDCASE int '../../../IDCASE',
			ID_C uniqueidentifier '../../../ID_C',			
			SL_ID UNIQUEIDENTIFIER '../../SL_ID',
			ID_SL SMALLINT,
			VAL_C DECIMAL(3,2) 
	)
--SELECT * FROM #tCoeff
--20.12.2018
INSERT #KSG_KPG( IDCASE, ID_C, SL_ID,N_KSG,CRIT,SL_K,IT_SL )
SELECT IDCASE, ID_C, SL_ID,N_KSG,NULL AS CRIT,SL_K,IT_SL
FROM OPENXML (@idoc, '/ZL_LIST/ZAP/Z_SL/SL/KSG_KPG',3)
WITH(
			IDCASE int '../../IDCASE',
			ID_C uniqueidentifier '../../ID_C',			
			SL_ID UNIQUEIDENTIFIER '../SL_ID',
			N_KSG NVARCHAR(20) ,			
			SL_K TINYINT ,
			IT_SL DECIMAL(3,2) 
	)
UNION 
SELECT IDCASE, ID_C, SL_ID,N_KSG,CRIT,SL_K,IT_SL
FROM OPENXML (@idoc, '/ZL_LIST/ZAP/Z_SL/SL/KSG_KPG/CRIT',3)
WITH(
			IDCASE int '../../../IDCASE',
			ID_C uniqueidentifier '../../../ID_C',			
			SL_ID UNIQUEIDENTIFIER '../../SL_ID',
			N_KSG NVARCHAR(20) '../N_KSG',
			CRIT NVARCHAR(10) 'text()',--20.12.2018
			SL_K TINYINT '../SL_K',
			IT_SL DECIMAL(3,2) '../IT_SL'
	)
--SELECT * FROM #KSG_KPG 
INSERT #tKiro( IDCASE, ID_C, CODE_KIRO, VAL_K, SL_ID )
SELECT IDCASE,ID_C,CODE_KIRO,VAL_K, SL_ID
FROM OPENXML (@idoc, '/ZL_LIST/ZAP/Z_SL/SL/KSG_KPG/S_KIRO',3)
WITH(
			IDCASE int '../../../IDCASE',
			ID_C uniqueidentifier '../../../ID_C',	
			SL_ID UNIQUEIDENTIFIER '../../SL_ID',		
			CODE_KIRO SMALLINT,
			VAL_K DECIMAL(3,2) 
	)
--SELECT * FROM #tKiro
INSERT #NAPR(IDCASE ,ID_C ,NAPR_DATE, NAPR_MO ,NAPR_V ,MET_ISSL ,NAPR_USL,SL_ID )
SELECT IDCASE ,ID_C ,NAPR_DATE, NAPR_MO ,NAPR_V ,MET_ISSL ,NAPR_USL,SL_ID
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/Z_SL/SL/NAPR',3)
	WITH(
			IDCASE int '../../IDCASE',
			ID_C uniqueidentifier '../../ID_C',					
			SL_ID UNIQUEIDENTIFIER '../SL_ID',
			NAPR_DATE date,
			NAPR_MO nvarchar(6),
			NAPR_V TINYINT,
			MET_ISSL TINYINT,
			NAPR_USL NVARCHAR(15)
		)
--SELECT * FROM #NAPR

INSERT #CONS(IDCASE ,ID_C ,SL_ID, PR_CONS, DT_CONS )
SELECT IDCASE ,ID_C ,SL_ID, PR_CONS, DT_CONS
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/Z_SL/SL/CONS',3)
	WITH(
			IDCASE int '../../IDCASE',
			ID_C uniqueidentifier '../../ID_C',					
			SL_ID UNIQUEIDENTIFIER '../SL_ID',
			PR_CONS tinyint,
			DT_CONS date
		)
--SELECT * FROM #cons
--20.12.2018
INSERT #ONK_SL(IDCASE, ID_C,DS1_T ,STAD,ONK_T,ONK_N,ONK_M,MTSTZ,SOD, SL_ID,K_FR,WEI,HEI,BSA)
SELECT IDCASE,ID_C,DS1_T ,STAD,ONK_T,ONK_N,ONK_M,MTSTZ,SOD, SL_ID,K_FR,WEI,HEI,BSA
FROM OPENXML (@idoc, '/ZL_LIST/ZAP/Z_SL/SL/ONK_SL',3)
WITH(
			IDCASE int '../../IDCASE',
			ID_C uniqueidentifier '../../ID_C',		
			SL_ID UNIQUEIDENTIFIER '../SL_ID' ,
			DS1_T TINYINT,
			STAD SMALLINT,
			ONK_T smallint,
			ONK_N smallint,
			ONK_M smallint,
			MTSTZ TINYINT,
			SOD DECIMAL(5,2),
			K_FR TINYINT,
			WEI DECIMAL(5,1),
			HEI TINYINT,
			BSA DECIMAL(3,2)
	)
--SELECT * FROM #ONK_SL

INSERT #B_DIAG(IDCASE, ID_C,DIAG_TIP, DIAG_CODE, DIAG_RSLT,DIAG_DATE, SL_ID,REC_RSLT)
SELECT IDCASE, ID_C,DIAG_TIP, DIAG_CODE, DIAG_RSLT, DIAG_DATE, SL_ID ,REC_RSLT
FROM OPENXML (@idoc, '/ZL_LIST/ZAP/Z_SL/SL/ONK_SL/B_DIAG',3)
WITH(
			IDCASE int '../../../IDCASE',
			ID_C uniqueidentifier '../../../ID_C',			
			SL_ID UNIQUEIDENTIFIER '../../SL_ID' ,
			DIAG_DATE DATE,
			DIAG_TIP TINYINT, 
			DIAG_CODE SMALLINT, 
			DIAG_RSLT SMALLINT,
			REC_RSLT TINYINT			
	)
--SELECT * FROM #B_DIAG

INSERT #B_PROT(IDCASE, ID_C,PROT, D_PROT, SL_ID)
SELECT IDCASE, ID_C,PROT, D_PROT, SL_ID
FROM OPENXML (@idoc, '/ZL_LIST/ZAP/Z_SL/SL/ONK_SL/B_PROT',3)
WITH(
			IDCASE int '../../../IDCASE',
			ID_C uniqueidentifier '../../../ID_C',			
			SL_ID UNIQUEIDENTIFIER '../../SL_ID' ,
			PROT TINYINT, 
			D_PROT date
	)
--SELECT * FROM #B_PROT
--20.12.2018
INSERT #ONK_USL(IDCASE ,ID_C ,SL_ID ,USL_TIP , HIR_TIP , LEK_TIP_L ,LEK_TIP_V ,LUCH_TIP,PPTR)
SELECT IDCASE ,ID_C ,SL_ID ,USL_TIP , HIR_TIP , LEK_TIP_L ,LEK_TIP_V ,LUCH_TIP,PPTR
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/Z_SL/SL/ONK_SL/ONK_USL',3)
	WITH(
			IDCASE int '../../../IDCASE',
			ID_C uniqueidentifier '../../../ID_C',			
			SL_ID UNIQUEIDENTIFIER '../../SL_ID' ,			
			USL_TIP TINYINT, 
			HIR_TIP TINYINT, 
			LEK_TIP_L TINYINT,
			LEK_TIP_V TINYINT,
			LUCH_TIP TINYINT ,
			PPTR TINYINT
		)
--SELECT * FROM #ONK_USL
--нова€ таблица
INSERT #LEK_PR(IDCASE ,ID_C ,SL_ID ,USL_TIP ,HIR_TIP , LEK_TIP_L ,LEK_TIP_V ,LUCH_TIP, REGNUM, DATE_INJ,CODE_SH)
SELECT IDCASE ,ID_C ,SL_ID ,USL_TIP , HIR_TIP , LEK_TIP_L ,LEK_TIP_V ,LUCH_TIP , REGNUM, DATE_INJ,CODE_SH
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/Z_SL/SL/ONK_SL/ONK_USL/LEK_PR/DATE_INJ',3)
	WITH(
			IDCASE int '../../../../../IDCASE',
			ID_C uniqueidentifier '../../../../../ID_C',			
			SL_ID UNIQUEIDENTIFIER '../../../../SL_ID' ,			
			USL_TIP TINYINT '../../USL_TIP', 
			HIR_TIP TINYINT '../../HIR_TIP', 
			LEK_TIP_L TINYINT '../../LEK_TIP_L',
			LEK_TIP_V TINYINT '../../LEK_TIP_V',
			LUCH_TIP TINYINT '../../LUCH_TIP',
			REGNUM NVARCHAR(6) '../REGNUM', 
			CODE_SH NVARCHAR(10) '../CODE_SH', 
			DATE_INJ DATE 'text()'
		) 
--SELECT * FROM #LEK_PR

--UPDATE l SET l.id_ONKUSL=u.id
SELECT *
FROM #LEK_PR l INNER JOIN #ONK_USL u ON
		l.SL_ID=u.SL_ID
		AND u.IDCASE = l.IDCASE
		AND u.USL_TIP = l.USL_TIP
		AND isnull(u.HIR_TIP,0) =  ISNULL(l.HIR_TIP,0)
		AND isnull(u.LEK_TIP_L,0) = isnull(l.LEK_TIP_L,0)
		AND isnull(u.LEK_TIP_V,0) = isnull(l.LEK_TIP_V,0)
		AND isnull(u.LUCH_TIP ,0)=  isnull(l.LUCH_TIP,0)

insert #t6
SELECT IDCASE,ID_C,IDSERV,ID_U,LPU,PROFIL,CASE when len(VID_VME)=0 THEN NULL ELSE VID_VME END,
		DET,replace(DATE_IN,'-',''),replace(DATE_OUT,'-',''),DS,CODE_USL,KOL_USL,TARIF,SUMV_USL,PRVS,COMENTU,PODR,CODE_MD,LPU_1, SL_ID
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/Z_SL/SL/USL',3)
	WITH(
			IDCASE int '../../IDCASE',
			ID_C uniqueidentifier '../../ID_C',
			SL_ID uniqueidentifier '../SL_ID',
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

--1-  од надежности относитс€ к пациента
--2  од надежности сопровождающего
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

go
--------------------------------------------
if OBJECT_ID('tempDB..#t5',N'U') is not NULL
	 DROP TABLE #t5
if OBJECT_ID('tempDB..#t8',N'U') is not NULL
	drop table #t8
if OBJECT_ID('tempDB..#t3',N'U') is not NULL
	drop table #t3
if OBJECT_ID('tempDB..#iTableMes',N'U') is not NULL
	DROP TABLE #iTableMes
if OBJECT_ID('tempDB..#CONS',N'U') is not NULL
	DROP TABLE #CONS
if OBJECT_ID('tempDB..#LEK_PR',N'U') is not NULL
DROP TABLE #LEK_PR
if OBJECT_ID('tempDB..#t6',N'U') is not NULL
	DROP TABLE #t6
if OBJECT_ID('tempDB..#tBW',N'U') is not NULL
	DROP TABLE #tBW
if OBJECT_ID('tempDB..#tDS',N'U') is not NULL
	DROP TABLE #tDS
if OBJECT_ID('tempDB..#tCoeff',N'U') is not NULL
	DROP TABLE #tCoeff
if OBJECT_ID('tempDB..#tKiro',N'U') is not NULL
	DROP TABLE #tKiro
if OBJECT_ID('tempDB..#B_DIAG',N'U') is not NULL
	DROP TABLE #B_DIAG
if OBJECT_ID('tempDB..#B_PROT',N'U') is not NULL
	DROP TABLE #B_PROT
if OBJECT_ID('tempDB..#NAPR',N'U') is not NULL
	DROP TABLE #NAPR
if OBJECT_ID('tempDB..#ONK_USL',N'U') is not NULL
	DROP TABLE #ONK_USL
if OBJECT_ID('tempDB..#tDost',N'U') is not NULL
	DROP TABLE #tDost
if OBJECT_ID('tempDB..#tDisabiliti',N'U') is not NULL
	DROP TABLE #tDisabiliti
if OBJECT_ID('tempDB..#ONK_SL',N'U') is not NULL
	DROP TABLE #ONK_SL
if OBJECT_ID('tempDB..#KSG_KPG',N'U') is not NULL
	DROP TABLE #KSG_KPG

