use RegisterCases
go

declare @doc xml,
		@patient xml
SELECT	@doc=HRM.ZL_LIST				
FROM	OPENROWSET(BULK 'c:\Test\HRM121125T34_1409011.XML',SINGLE_BLOB) HRM (ZL_LIST)

SELECT	@patient=LRM.PERS_LIST				
FROM	OPENROWSET(BULK 'c:\Test\LRM121125T34_1409011.XML',SINGLE_BLOB) LRM (PERS_LIST)

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
					SPOLIS nchar(10),NPOLIS nchar(20),SMO nchar(5),SMO_OK nchar(5),SMO_NAM nvarchar(100),NOVOR nchar(9),MO_PR nchar(6),
					VNOV_D smallint					
					)


create table #t5(N_ZAP int,ID_PAC nvarchar(36),IDCASE bigint,ID_C uniqueidentifier,USL_OK tinyint,VIDPOM smallint
				,FOR_POM tinyint,VID_HMP varchar(9),METOD_HMP smallint --13.01.2014
				,NPR_MO nchar(6),EXTR tinyint,LPU nchar(6),PROFIL smallint,
					 DET tinyint,NHISTORY nvarchar(50),DATE_1 date,DATE_2 date,DS0 nchar(10),DS1 nchar(10),CODE_MES1 nchar(20),RSLT smallint,
					 ISHOD smallint,PRVS bigint,OS_SLUCH tinyint,IDSP tinyint,ED_COL numeric(5, 2),TARIF numeric(15, 2),SUMV numeric(15, 2),REFREASON tinyint,
					 SANK_MEK numeric(15, 2),SANK_MEE numeric(15, 2),SANK_EKMP numeric(15, 2),COMENTSL nvarchar(250),F_SP tinyint)
					 
CREATE TABLE #tDS(IDCASE int,ID_C uniqueidentifier,DS varchar(10), TypeDiagnosis tinyint)

CREATE TABLE #tBW(IDCASE int,ID_C uniqueidentifier, BirthWeight smallint)
					 
create table #t6(IDCASE int,ID_C uniqueidentifier,IDSERV nvarchar(36),ID_U uniqueidentifier,LPU nchar(6),PROFIL smallint,
			VID_VME nvarchar(15),DET tinyint,DATE_IN date,DATE_OUT date,
			DS nchar(10),CODE_USL nchar(20),KOL_USL numeric(6, 2),TARIF numeric(15, 2),SUMV_USL numeric(15, 2),
			PRVS bigint,COMENTU nvarchar(250),PODR int
			)
					   
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
--добавил Вес новорожденного 13.01.2014
insert #t3
SELECT N_ZAP,PR_NOV,ID_PAC,VPOLIS,SPOLIS,NPOLIS,SMO,SMO_OK,SMO_NAM,NOVOR,MO_PR,VNOV_D
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
			MO_PR nchar(6),
			VNOV_D smallint 
		)


insert #t5
SELECT N_ZAP,ID_PAC,IDCASE,ID_C,USL_OK,VIDPOM,
		FOR_POM,
		CASE WHEN LEN(VID_HMP)=0 THEN NULL ELSE VID_HMP END,
		CASE WHEN LEN(METOD_HMP)=0 THEN NULL ELSE METOD_HMP END,--13.01.2014					
		NPR_MO,EXTR,LPU,PROFIL,DET,NHISTORY,replace(DATE_1,'-',''),replace(DATE_2,'-',''),DS0,DS1,CODE_MES1,RSLT,ISHOD,
		PRVS,OS_SLUCH,IDSP,ED_COL,TARIF,SUMV,REFREASON,SANK_MEK,SANK_MEE,SANK_EKMP,COMENTSL,F_SP
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/SLUCH',3)
	WITH(
			N_ZAP int '../N_ZAP',
			ID_PAC nvarchar(36) '../PACIENT/ID_PAC',
			IDCASE bigint ,
			ID_C uniqueidentifier,
			USL_OK tinyint ,
			VIDPOM smallint,
			FOR_POM tinyint,
			VID_HMP varchar(9),
			METOD_HMP smallint ,			
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
			CODE_MES1 nchar(20) ,			
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
		
insert #t6
SELECT IDCASE,ID_C,IDSERV,ID_U,LPU,PROFIL,CASE when len(VID_VME)=0 THEN NULL ELSE VID_VME END,
		DET,replace(DATE_IN,'-',''),replace(DATE_OUT,'-',''),DS,CODE_USL,KOL_USL,TARIF,SUMV_USL,PRVS,COMENTU,PODR
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

go