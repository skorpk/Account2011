use RegisterCases
go
if OBJECT_ID('usp_CheckRegisterCaseDataLPU',N'P') is not null
drop proc usp_CheckRegisterCaseDataLPU
go
create proc usp_CheckRegisterCaseDataLPU
			@doc xml,
			@patient xml
as
DECLARE @idoc int,
		@ipatient int
--DECLARE @Doc xml

--SELECT	 @Doc		= E.Error				
--FROM	OPENROWSET(BULK 'c:\test\HRM.xml',SINGLE_BLOB)E(Error)
---create tempory table----------------------------------------------

declare @t1 as table([VERSION] char(5),DATA date,[FILENAME] varchar(26))

declare @t2 as table(CODE int,CODE_MO int,[YEAR] smallint,[MONTH] tinyint,NSCHET int,DSCHET date,SUMMAV numeric(11, 2),COMENTS nvarchar(250)) 

declare @t3 as table(N_ZAP int,PR_NOV tinyint)

declare @t4 as table(N_ZAP int,ID_PAC nvarchar(36),VPOLIS tinyint,SPOLIS nchar(10),NPOLIS nchar(20),SMO nchar(5),NOVOR nchar(9))

declare @t5 as table(ID_PAC nvarchar(36),IDCASE int,ID_C uniqueidentifier,USL_OK tinyint,VIDPOM smallint,NPR_MO nchar(6),EXTR tinyint,LPU nchar(6),PROFIL smallint,
					 DET tinyint,NHISTORY nvarchar(50),DATE_1 date,DATE_2 date,DS0 nchar(10),DS1 nchar(10),DS2 nchar(10),CODE_MES1 nchar(16),RSLT smallint,
					 ISHOD smallint,PRVS bigint,OS_SLUCH tinyint,IDSP tinyint,ED_COL numeric(5, 2),TARIF numeric(15, 2),SUMV numeric(15, 2),REFREASON tinyint,
					 SANK_MEK numeric(15, 2),SANK_MEE numeric(15, 2),SANK_EKMP numeric(15, 2),COMENTSL nvarchar(250))
					 
declare @t6 as table (ID_C uniqueidentifier,IDSERV int,ID_U uniqueidentifier,LPU nchar(6),PROFIL smallint,DET tinyint,DATE_IN date,DATE_OUT date,
					   DS nchar(10),CODE_USL nchar(16),KOL_USL numeric(6, 2),TARIF numeric(15, 2),SUMV_USL numeric(15, 2),PRVS bigint,COMENTU nvarchar(250))
					   
declare @t7 as table([VERSION] nchar(5),DATA date,[FILENAME] nchar(26),FILENAME1 nchar(26))

declare @t8 as table(ID_PAC nvarchar(36),FAM nvarchar(40),IM nvarchar(40),OT nvarchar(40),W tinyint,DR date,FAM_P nvarchar(40),IM_P nvarchar(40),OT_P nvarchar(40),
					W_P tinyint,DR_P date,MR nvarchar(100),DOCTYPE nchar(2),DOCSER nchar(10),DOCNUM nchar(20),SNILS nchar(14),OKATOG nchar(11),OKATOP nchar(11),
					COMENTP nvarchar(250))
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
SELECT N_ZAP,PR_NOV
FROM OPENXML (@idoc, 'ZL_LIST/ZAP',2)
	WITH(
			N_ZAP int './N_ZAP',
			PR_NOV tinyint './PR_NOV'
		)

insert @t4
SELECT N_ZAP,ID_PAC,VPOLIS,SPOLIS,NPOLIS,SMO,NOVOR
FROM OPENXML (@idoc, 'ZL_LIST/ZAP')
	WITH(
			N_ZAP int './N_ZAP',
			ID_PAC nvarchar(36)'./PACIENT/ID_PAC',
			VPOLIS tinyint './PACIENT/VPOLIS',
			SPOLIS nchar(10) './PACIENT/SPOLIS',
			NPOLIS nchar(20) './PACIENT/NPOLIS',
			SMO nchar(5) './PACIENT/SMO',
			NOVOR nchar(9) './PACIENT/NOVOR'			
		)

insert @t5
SELECT ID_PAC,IDCASE,ID_C,USL_OK,VIDPOM,NPR_MO,EXTR,LPU,PROFIL,DET,NHISTORY,replace(DATE_1,'-',''),replace(DATE_2,'-',''),DS0,DS1,DS2,CODE_MES1,RSLT,ISHOD,
		PRVS,OS_SLUCH,IDSP,ED_COL,TARIF,SUMV,REFREASON,SANK_MEK,SANK_MEE,SANK_EKMP,COMENTSL
FROM OPENXML (@idoc, 'ZL_LIST/ZAP')
	WITH(
			ID_PAC nvarchar(36) './PACIENT/ID_PAC',
			IDCASE int './SLUCH/IDCASE',
			ID_C uniqueidentifier './SLUCH/ID_C',
			USL_OK tinyint './SLUCH/USL_OK',
			VIDPOM smallint './SLUCH/VIDPOM',
			NPR_MO nchar(6) './SLUCH/NPR_MO',
			EXTR tinyint './SLUCH/EXTR',
			LPU nchar(6) './SLUCH/LPU',
			PROFIL smallint './SLUCH/PROFIL',
			DET tinyint './SLUCH/DET',
			NHISTORY nvarchar(50) './SLUCH/NHISTORY',
			DATE_1 nchar(10) './SLUCH/DATE_1',
			DATE_2 nchar(10) './SLUCH/DATE_2',
			DS0 nchar(10) './SLUCH/DS0',
			DS1 nchar(10) './SLUCH/DS1',
			DS2 nchar(10) './SLUCH/DS2',
			CODE_MES1 nchar(16) './SLUCH/CODEMES1',			
			RSLT smallint './SLUCH/RSLT',
			ISHOD smallint './SLUCH/ISHOD',
			PRVS bigint './SLUCH/PRVS',
			OS_SLUCH tinyint './SLUCH/OS_SLUCH',
			IDSP TINYINT './SLUCH/IDSP',
			ED_COL DECIMAL(5,2) './SLUCH/ED_COL',
			TARIF DECIMAL(15,2) './SLUCH/TARIF',	
			SUMV DECIMAL(15,2) './SLUCH/SUMV',	
			REFREASON TINYINT './SLUCH/REFREASON',
			SANK_MEK DECIMAL(15,2) './SLUCH/SANK_MEK',
			SANK_MEE DECIMAL(15,2) './SLUCH/SANK_MEE',
			SANK_EKMP DECIMAL(15,2) './SLUCH/SANK_EKMP',
			COMENTSL NVARCHAR(250) './SLUCH/COMENTSL'
		)

insert @t6
SELECT ID_C,IDSERV,ID_U,LPU,PROFIL,DET,replace(DATE_IN,'-',''),replace(DATE_OUT,'-',''),DS,CODE_USL,KOL_USL,TARIF,SUMV_USL,PRVS,COMENTU
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/SLUCH')
	WITH(
			ID_C uniqueidentifier './ID_C',
			IDSERV INT './USL/IDSERV',
			ID_U uniqueidentifier './USL/ID_U',
			LPU nchar(6) './/USL/LPU',
			PROFIL smallint './USL/PROFIL',
			DET tinyint './USL/DET',
			DATE_IN nchar(10) './USL/DATE_IN',
			DATE_OUT nchar(10) './USL/DATE_OUT',
			DS nchar(10) './USL/DS',
			CODE_USL nchar(16) './USL/CODE_USL',
			KOL_USL DECIMAL(6,2) './USL/KOL_USL',
			TARIF DECIMAL(15,2) './USL/TARIF',	
			SUMV_USL DECIMAL(15,2) './USL/SUMV_USL',	
			PRVS bigint './USL/PRVS',
			COMENTU NVARCHAR(250) './USL/COMENTU'
		)
EXEC sp_xml_removedocument @idoc

---------------Patient----------------------------------
EXEC sp_xml_preparedocument @ipatient OUTPUT, @patient

insert @t7
SELECT [VERSION],DATA,[FILENAME],FILENAME1
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

select * from @t1
select * from @t2
select * from @t3
select * from @t4
select * from @t5
select * from @t6
select * from @t7
select * from @t8
GO