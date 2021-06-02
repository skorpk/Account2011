use RegisterCases
go
declare @doc xml,
		@p2 XML,
		@bfile VARBINARY(max),
		@dateStart DATETIME

SELECT @dateStart=GETDATE()		
SELECT	@doc=HRM.ZL_LIST				
FROM	OPENROWSET(BULK 'd:\Test\HRM104401T34_180400016.XML',SINGLE_BLOB) HRM (ZL_LIST)	--путь на сервере к файлу. Но в процедуре у меня это выступает в качестве параметра и в него я передаю XML

--SELECT	@p2=LRM.PERS_LIST				
--FROM	OPENROWSET(BULK 'c:\Test\LRM125901T34_170300032.XML',SINGLE_BLOB) LRM (PERS_LIST)

--SELECT	@bfile=f.DataFile
--FROM	OPENROWSET(BULK 'c:\Test\HRM125901T34_170300032.zip',SINGLE_BLOB) f (DataFile)

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
					MO_PR nchar(6),
					VNOV_D SMALLINT,
					MSE TINYINT--------------27.12.2017					
				)
------------------сведения о признании лица инвалидом---------------------
CREATE TABLE #tDisabiliti(N_ZAP int,ID_PAC nvarchar(36), INV TINYINT,DATA_INV DATE, REASON_INV TINYINT, DS_INV VARCHAR(10))

---new column in table 27.04.2016
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
				 DS_ONK TINYINT, --16.07.208
				 REAB tinyint --16.07.208
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
						SOD DECIMAL(5,2)						
						 )
CREATE TABLE #B_DIAG(IDCASE int,ID_C UNIQUEIDENTIFIER,DIAG_TIP TINYINT,DIAG_CODE SMALLINT, DIAG_RSLT SMALLINT)
CREATE TABLE #B_PROT(IDCASE int,ID_C UNIQUEIDENTIFIER,PROT TINYINT,D_PROT DATE)
						
					 
create table #t6(IDCASE int,ID_C uniqueidentifier,IDSERV nvarchar(36),ID_U uniqueidentifier,LPU nchar(6),PROFIL smallint,
			VID_VME nvarchar(15),DET tinyint,DATE_IN date,DATE_OUT date,
			DS nchar(10),CODE_USL nchar(20),KOL_USL numeric(6, 2),TARIF numeric(15, 2),SUMV_USL numeric(15, 2),
			PRVS bigint,COMENTU nvarchar(250),PODR INT,CODE_MD VARCHAR(25),LPU_1 NVARCHAR(6)
			)

create table #NAPR(IDCASE int,ID_C uniqueidentifier,ID_U UNIQUEIDENTIFIER,NAPR_DATE DATE,NAPR_V TINYINT,MET_ISSL TINYINT,NAPR_USL VARCHAR(15))
create table #ONK_USL
	(
		IDCASE int,
		ID_C uniqueidentifier,
		ID_U UNIQUEIDENTIFIER,
		PR_CONS TINYINT,
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
insert #t3
SELECT N_ZAP,PR_NOV,ID_PAC,VPOLIS,SPOLIS,NPOLIS,ENP,ST_OKATO,SMO,SMO_OK,SMO_NAM,NOVOR,MO_PR,VNOV_D,MSE
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
			MO_PR nchar(6),
			VNOV_D SMALLINT,
			MSE TINYINT 
		)

--SELECT * FROM #t3

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
--SELECT * FROM #tDisabiliti

insert #t5( N_ZAP ,ID_PAC ,IDCASE ,ID_C ,USL_OK ,VIDPOM ,FOR_POM ,VID_HMP ,METOD_HMP ,NPR_MO ,EXTR ,LPU ,PROFIL ,DET ,TAL_D ,TAL_P ,NHISTORY ,
			P_PER ,DATE_1 ,DATE_2 ,DS0 ,DS1 ,CODE_MES1 ,RSLT ,ISHOD ,PRVS ,OS_SLUCH ,IDSP ,ED_COL ,TARIF ,SUMV ,COMENTSL ,F_SP ,IDDOCT ,IT_SL,PODR,LPU_1
			,AD_CRITERION,NEXT_VISIT,NPR_DATE,PROFIL_K,P_CEL,TAL_NUM,DN,DKK2,DS_ONK,REAB
        )
SELECT N_ZAP,ID_PAC,IDCASE,ID_C,USL_OK,VIDPOM,
		FOR_POM,
		CASE WHEN LEN(VID_HMP)=0 THEN NULL ELSE VID_HMP END,
		CASE WHEN LEN(METOD_HMP)=0 THEN NULL ELSE METOD_HMP END,--13.01.2014					
		NPR_MO, EXTR, LPU, PROFIL, DET, TAL_D,TAL_P, NHISTORY, P_PER, replace(DATE_1,'-',''), replace(DATE_2,'-',''),DS0,DS1,CODE_MES1,RSLT,ISHOD,
		PRVS,OS_SLUCH,IDSP,ED_COL,TARIF,SUMV,COMENTSL,F_SP,IDDOKT,IT_SL,PODR,LPU_1, AD_CRITERION, replace(NEXT_VISIT,'-',''),NPR_DATE,PROFIL_K,P_CEL,TAL_NUM,DN,DKK2
		,DS_ONK,Reab
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
			Reab TINYINT--16.07.208
		)

--SELECT * FROM #t5
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
INSERT #ONK_SL(IDCASE, ID_C,DS1_T ,STAD,ONK_T,ONK_N,ONK_M,MTSTZ,SOD)
SELECT IDCASE,ID_C,DS1_T ,STAD,ONK_T,ONK_N,ONK_M,MTSTZ,SOD
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
			SOD DECIMAL(5,2)
	)

INSERT #B_DIAG(IDCASE, ID_C,DIAG_TIP, DIAG_CODE, DIAG_RSLT)
SELECT IDCASE, ID_C,DIAG_TIP, DIAG_CODE, DIAG_RSLT
FROM OPENXML (@idoc, '/ZL_LIST/ZAP/SLUCH/ONK_SL/B_DIAG',3)
WITH(
			IDCASE int '../../IDCASE',
			ID_C uniqueidentifier '../../ID_C',			
			DIAG_TIP TINYINT, 
			DIAG_CODE SMALLINT, 
			DIAG_RSLT SMALLINT
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
INSERT #NAPR(IDCASE ,ID_C ,ID_U ,NAPR_DATE ,NAPR_V ,MET_ISSL ,NAPR_USL )
SELECT IDCASE ,ID_C ,ID_U ,NAPR_DATE ,NAPR_V ,MET_ISSL ,NAPR_USL
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/SLUCH/USL/NAPR',3)
	WITH(
			IDCASE int '../../IDCASE',
			ID_C uniqueidentifier '../../ID_C',		
			ID_U uniqueidentifier '../ID_U',
			NAPR_DATE date,
			NAPR_V TINYINT,
			MET_ISSL TINYINT,
			NAPR_USL NVARCHAR(15)
		)
INSERT #ONK_USL(IDCASE ,ID_C ,ID_U ,PR_CONS ,USL_TIP , HIR_TIP , LEK_TIP_L ,LEK_TIP_V ,LUCH_TIP)
SELECT IDCASE ,ID_C ,ID_U ,PR_CONS ,USL_TIP , HIR_TIP , LEK_TIP_L ,LEK_TIP_V ,LUCH_TIP
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/SLUCH/USL/ONK_USL',3)
	WITH(
			IDCASE int '../../IDCASE',
			ID_C uniqueidentifier '../../ID_C',		
			ID_U uniqueidentifier '../ID_U',
			PR_CONS TINYINT,
			USL_TIP TINYINT, 
			HIR_TIP TINYINT, 
			LEK_TIP_L TINYINT,
			LEK_TIP_V TINYINT,
			LUCH_TIP TINYINT
		)
SELECT * FROM #NAPR
SELECT * FROM #B_PROT
SELECT * FROM #ONK_USL
SELECT * FROM #B_DIAG
SELECT * FROM #ONK_SL

SELECT 1, t1.ID_U ,t1.NAPR_DATE ,t1.NAPR_V ,t1.MET_ISSL ,t1.NAPR_USL
from #t5 c inner join #NAPR t1 on
		c.ID_C=t1.ID_C	
		and c.IDCASE=t1.IDCASE	
WHERE t1.NAPR_DATE IS NOT NULL

EXEC sp_xml_removedocument @idoc
GO
DROP TABLE #t5
DROP TABLE #t6
DROP TABLE #tBW
DROP TABLE #tDS
DROP TABLE #tCoeff
DROP TABLE #t3
DROP TABLE #tDisabiliti
DROP TABLE #ONK_SL
DROP TABLE #tKiro
DROP TABLE #B_DIAG
DROP TABLE #B_PROT
DROP TABLE #NAPR
DROP TABLE #ONK_USL
DROP TABLE #tDost
DROP TABLE #t8