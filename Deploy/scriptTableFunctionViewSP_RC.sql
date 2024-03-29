USE [RegisterCases]
GO
/****** Object:  Table [dbo].[t_RefCasePatientDefine]    Script Date: 12/01/2011 07:38:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_RefCasePatientDefine](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[rf_idCase] [bigint] NOT NULL,
	[rf_idRegisterPatient] [int] NOT NULL,
	[IsUnloadIntoSP_TK] [bit] NULL,
	[rf_idFiles] [int] NULL,
 CONSTRAINT [PK_ZP1_RecordCase] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedTableType [dbo].[TVP_Error]    Script Date: 12/01/2011 07:38:43 ******/
CREATE TYPE [dbo].[TVP_Error] AS TABLE(
	[ErrorNumber] [int] NOT NULL,
	[ErrorTag] [varchar](50) NULL,
	[ErrorValue] [varchar](40) NULL,
	[ErrorFile] [varchar](26) NULL,
	[ErrorParentTag] [varchar](50) NULL
)
GO
/****** Object:  UserDefinedTableType [dbo].[TVP_CasePatient]    Script Date: 12/01/2011 07:38:43 ******/
CREATE TYPE [dbo].[TVP_CasePatient] AS TABLE(
	[rf_idCase] [bigint] NOT NULL,
	[ID_Patient] [int] NULL
)
GO
/****** Object:  Table [dbo].[tmp_RecordCaseNext]    Script Date: 12/01/2011 07:38:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tmp_RecordCaseNext](
	[rf_idCase] [bigint] NOT NULL,
	[ID_Patient] [int] NULL,
	[FileName] [varchar](26) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[t_XmlElement]    Script Date: 12/01/2011 07:38:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[t_XmlElement](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[NameElement] [varchar](40) NOT NULL,
	[Parent_id] [int] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[t_PlanOrders2011]    Script Date: 12/01/2011 07:38:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[t_PlanOrders2011](
	[CodeLPU] [char](6) NULL,
	[MonthRate] [tinyint] NULL,
	[YearRate] [smallint] NULL,
	[unitCode] [tinyint] NULL,
	[Rate] [int] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[t_FileTested]    Script Date: 12/01/2011 07:38:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[t_FileTested](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[DateRegistration] [datetime] NOT NULL,
	[FileName] [varchar](50) NOT NULL,
	[UserName] [varchar](30) NOT NULL,
	[ErrorDescription] [nvarchar](250) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[t_ErrorProcessControl]    Script Date: 12/01/2011 07:38:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_ErrorProcessControl](
	[DateRegistration] [datetime] NOT NULL,
	[ErrorNumber] [smallint] NOT NULL,
	[rf_idFile] [int] NOT NULL,
	[rf_idCase] [bigint] NOT NULL,
	[GUID_MU] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_FullYear]    Script Date: 12/01/2011 07:38:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[fn_FullYear] (@DateBeg date,@DateEnd date)
RETURNS int
as
begin
	declare @FullYear int
	select @FullYear=DATEDIFF(YEAR,@DateBeg,@DateEnd)-CASE WHEN 100*MONTH(@DateBeg)+DAY(@DateBeg)>100*MONTH(@DateEnd)+DAY(@DateEnd) THEN 1 ELSE 0 END;
	return (@FullYear)
end
GO
/****** Object:  Table [dbo].[t_FileBack]    Script Date: 12/01/2011 07:38:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[t_FileBack](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[rf_idFiles] [int] NOT NULL,
	[DateCreate] [datetime] NOT NULL,
	[FileVersion] [char](5) NOT NULL,
	[FileNameHRBack] [varchar](26) NOT NULL,
	[UserName] [varchar](30) NOT NULL,
	[IsUnload] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[sprIteration]    Script Date: 12/01/2011 07:38:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[sprIteration](
	[id] [tinyint] NOT NULL,
	[NAME] [varchar](70) NULL,
	[IsRegional] [bit] NULL,
	[IsDateEnd] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[POLIS]    Script Date: 12/01/2011 07:38:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[POLIS](
	[ID] [int] NOT NULL,
	[PID] [int] NULL,
	[DBEG] [datetime2](3) NULL,
	[DEND] [datetime2](3) NOT NULL,
	[Q] [varchar](5) NULL,
	[SPOL] [varchar](20) NULL,
	[NPOL] [varchar](20) NULL,
	[POLTP] [int] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PEOPLE]    Script Date: 12/01/2011 07:38:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PEOPLE](
	[ID] [int] NOT NULL,
	[ENP] [varchar](16) NULL,
	[RN] [varchar](11) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  UserDefinedFunction [dbo].[inlist]    Script Date: 12/01/2011 07:38:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[inlist]
(@c varchar(100), @s varchar(4096))
returns int
as
begin
   if @s is null or charindex(','+@C+',',','+@S+',')>0 
      return 1
   return 0
end
GO
/****** Object:  Table [dbo].[t_CaseDefineZP1Found]    Script Date: 12/01/2011 07:38:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[t_CaseDefineZP1Found](
	[rf_idRefCaseIteration] [bigint] NOT NULL,
	[rf_idZP1] [int] NOT NULL,
	[OKATO] [varchar](5) NULL,
	[UniqueNumberPolicy] [varchar](20) NULL,
	[TypePolicy] [char](1) NULL,
	[OGRN_SMO] [varchar](15) NULL,
	[SPolicy] [varchar](20) NULL,
	[NPolcy] [varchar](20) NULL,
	[DateDefine] [datetime] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[t_CaseDefineZP1]    Script Date: 12/01/2011 07:38:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_CaseDefineZP1](
	[rf_idRefCaseIteration] [bigint] NOT NULL,
	[rf_idZP1] [int] NOT NULL,
	[DateOperationt] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[t_CaseDefine]    Script Date: 12/01/2011 07:38:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[t_CaseDefine](
	[rf_idRefCaseIteration] [bigint] NOT NULL,
	[DateDefine] [datetime] NOT NULL,
	[PID] [int] NULL,
	[UniqueNumberPolicy] [varchar](20) NULL,
	[IsDefined] [bit] NOT NULL,
	[SMO] [varchar](5) NOT NULL,
	[SPolicy] [varchar](20) NULL,
	[NPolcy] [varchar](20) NULL,
	[RN] [varchar](11) NULL,
	[rf_idF008] [tinyint] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  UserDefinedFunction [dbo].[getPID]    Script Date: 12/01/2011 07:38:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[getPID]
(@KEYS varchar(255),@ENP varchar(16),@FAM varchar(30),@IM varchar(20),@OT varchar(20),@DR datetime,@MR varchar(100),
                       @SS varchar(16),@DOCS  varchar(20),@DOCN varchar(20),@OKATO varchar(11))
returns int
as
begin
/*  матрица сочетаний ключей поиска -----------
       fam   im    ot    dr    ss    dn
01   |  +  |  +  | +  |  +  |     |     |
02   |  +  |  +  | +  |     |  +  |     |
03   |  +  |  +  | +  |     |     |  +  |
04   |  +  |  +  |    |  +  |  +  |     |
05   |  +  |  +  |    |  +  |     |  +  |
06   |  +  |  +  |    |     |  +  |  +  |
07   |  +  |     | +  |  +  |  +  |     |
08   |  +  |     | +  |  +  |     |  +  |
09   |  +  |     | +  |     |  +  |  +  |
10   |  +  |     |    |  +  |  +  |  +  |
11   |     |  +  | +  |  +  |  +  |     |
12   |     |  +  | +  |  +  |     |  +  |
13   |     |  +  | +  |     |  +  |  +  |
14   |     |  +  |    |  +  |  +  |  +  |
15   |     |     | +  |  +  |  +  |  +  |
-------------------------------------------*/

  declare @PID int
  declare @bSS bit
  declare @bDC bit
  declare @bMR bit
  declare @DID int
  declare @FINDENP bit
  set @PID=null
  set @DID=null
  if @keys is null set @keys='1,2,3,4,5,6,7,8,9,10,11,12,13,14,15'
  
  set @OT  =isnull(@OT,'')       -- отчество
  
  select @DID=ID from [srvsql1-st2].PolicyRegister.dbo.FULLDUP where FAM=@FAM and IM=@IM and isnull(OT,'')=isnull(@OT,'') and DR=@DR

    if isnull(@ENP,'')<>'' select @PID=ID from [srvsql1-st2].PolicyRegister.dbo.People where ENP=@ENP  -- основная проверка по ЕНП!!!   -- H00
    if @PID is null and @DID is null and dbo.inlist('1' ,@keys)=1 select @PID=ID from [srvsql1-st2].PolicyRegister.dbo.People where FAM=@FAM and IM=@IM and isnull(OT,'')=@OT and DR=@DR  -- H01
    if @PID is null and dbo.inlist('2' ,@keys)=1 select @PID=ID from [srvsql1-st2].PolicyRegister.dbo.People where FAM=@FAM and IM=@IM and isnull(OT,'')=@OT and SS=@SS           -- H02
    if @PID is null and dbo.inlist('3' ,@keys)=1 select @PID=ID from [srvsql1-st2].PolicyRegister.dbo.People where FAM=@FAM and IM=@IM and isnull(OT,'')=@OT and DOCN=@DOCN           -- H03
    if @PID is null and dbo.inlist('4' ,@keys)=1 select @PID=ID from [srvsql1-st2].PolicyRegister.dbo.People where FAM=@FAM and IM=@IM and DR=@DR and SS=@SS           -- H04
    if @PID is null and dbo.inlist('5' ,@keys)=1 select @PID=ID from [srvsql1-st2].PolicyRegister.dbo.People where FAM=@FAM and IM=@IM and DR=@DR and DOCN=@DOCN           -- H05

    if @PID is null and dbo.inlist('6' ,@keys)=1 select @PID=ID from [srvsql1-st2].PolicyRegister.dbo.People where FAM=@FAM and IM=@IM and SS=@SS and DOCN=@DOCN           -- H06
    if @PID is null and dbo.inlist('7' ,@keys)=1 select @PID=ID from [srvsql1-st2].PolicyRegister.dbo.People where FAM=@FAM and isnull(OT,'')=@OT and DR=@DR and SS=@SS           -- H07
    if @PID is null and dbo.inlist('8' ,@keys)=1 select @PID=ID from [srvsql1-st2].PolicyRegister.dbo.People where FAM=@FAM and isnull(OT,'')=@OT and DR=@DR and DOCN=@DOCN           -- H08
    if @PID is null and dbo.inlist('9' ,@keys)=1 select @PID=ID from [srvsql1-st2].PolicyRegister.dbo.People where FAM=@FAM and isnull(OT,'')=@OT and SS=@SS and DOCN=@DOCN           -- H09
    if @PID is null and dbo.inlist('10',@keys)=1 select @PID=ID from [srvsql1-st2].PolicyRegister.dbo.People where FAM=@FAM and DR=@DR and SS=@SS and DOCN=@DOCN           -- H10

    if @PID is null and dbo.inlist('11',@keys)=1 select @PID=ID from [srvsql1-st2].PolicyRegister.dbo.People where IM=@IM and isnull(OT,'')=@OT and DR=@DR and SS=@SS           -- H11
    if @PID is null and dbo.inlist('12',@keys)=1 select @PID=ID from [srvsql1-st2].PolicyRegister.dbo.People where IM=@IM and isnull(OT,'')=@OT and DR=@DR and DOCN=@DOCN           -- H12
    if @PID is null and dbo.inlist('13',@keys)=1 select @PID=ID from [srvsql1-st2].PolicyRegister.dbo.People where IM=@IM and isnull(OT,'')=@OT and SS=@SS and DOCN=@DOCN           -- H13
    if @PID is null and dbo.inlist('14',@keys)=1 select @PID=ID from [srvsql1-st2].PolicyRegister.dbo.People where IM=@IM and DR=@DR and SS=@SS and DOCN=@DOCN           -- H14
    if @PID is null and dbo.inlist('15',@keys)=1 select @PID=ID from [srvsql1-st2].PolicyRegister.dbo.People where isnull(OT,'')=@OT and DR=@DR and SS=@SS and DOCN=@DOCN           -- H15

 return @PID
end
GO
/****** Object:  Table [dbo].[t_File]    Script Date: 12/01/2011 07:38:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[t_File](
	[GUID] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[id] [int] IDENTITY(1,1) NOT NULL,
	[DateRegistration] [datetime] NOT NULL,
	[FileVersion] [char](5) NOT NULL,
	[DateCreate] [date] NOT NULL,
	[FileNameHR] [varchar](26) NOT NULL,
	[FileNameLR] [varchar](26) NOT NULL,
	[FileZIP] [varbinary](max) FILESTREAM  NULL,
	[rf_idFileTested] [int] NOT NULL,
	[CountSluch] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY] FILESTREAM_ON [FileStreamGroup],
UNIQUE NONCLUSTERED 
(
	[GUID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] FILESTREAM_ON [FileStreamGroup]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[t_CasePatientDefineIteration]    Script Date: 12/01/2011 07:38:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_CasePatientDefineIteration](
	[rf_idRefCaseIteration] [bigint] NOT NULL,
	[rf_idIteration] [tinyint] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[t_FileError]    Script Date: 12/01/2011 07:38:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[t_FileError](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[rf_idFileTested] [int] NOT NULL,
	[FileNameP] [varchar](26) NOT NULL,
	[DateCreate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  View [dbo].[vw_sprF012]    Script Date: 12/01/2011 07:38:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_sprF012]
as
	select * from oms_nsi.dbo.sprF012
GO
/****** Object:  View [dbo].[vw_Polis]    Script Date: 12/01/2011 07:38:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_Polis]
as
select PID,DBEG,DEND,Q,SPOL,NPOL,POLTP			
from dbo.POLIS--[srvsql1-st2].PolicyRegister.dbo.POLIS
GO
/****** Object:  View [dbo].[vw_People]    Script Date: 12/01/2011 07:38:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_People]
as
select ID, ENP, RN from dbo.PEOPLE--[srvsql1-st2].PolicyRegister.dbo.PEOPLE
GO
/****** Object:  StoredProcedure [dbo].[usp_GetsprT001]    Script Date: 12/01/2011 07:38:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usp_GetsprT001]
				@CodeM varchar(6)
as 
select COUNT(*)
from oms_nsi.dbo.vw_sprT001
where CodeM=@CodeM
GO
/****** Object:  Table [dbo].[t_RegisterCaseBack]    Script Date: 12/01/2011 07:38:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[t_RegisterCaseBack](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[rf_idFilesBack] [int] NOT NULL,
	[ref_idF003] [char](6) NOT NULL,
	[ReportYear] [smallint] NOT NULL,
	[ReportMonth] [tinyint] NOT NULL,
	[DateCreate] [date] NOT NULL,
	[NumberRegister] [int] NOT NULL,
	[PropertyNumberRegister] [tinyint] NOT NULL,
	[Comments] [varchar](250) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  View [dbo].[vw_XmlTag]    Script Date: 12/01/2011 07:38:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_XmlTag]
as
select el1.id,el1.NameElement,el2.NameElement as ParentElementName
from t_XmlElement el1 inner join t_XmlElement el2 on
			el1.Parent_id=el2.id
GO
/****** Object:  View [dbo].[vw_sprT001]    Script Date: 12/01/2011 07:38:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_sprT001]
as
select * from oms_nsi.dbo.vw_sprT001
GO
/****** Object:  View [dbo].[vw_sprSMOGlobal]    Script Date: 12/01/2011 07:38:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_sprSMOGlobal]
as
select TF_OKATO as OKATO,SMOKOD,NAM_SMOK as SMO, OGRN
from oms_nsi.dbo.sprSMO
GO
/****** Object:  View [dbo].[vw_sprSMO]    Script Date: 12/01/2011 07:38:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_sprSMO]
as
select smocod,sNameF,sNameS
from oms_nsi.dbo.tSMO where smocod is not null
GO
/****** Object:  View [dbo].[vw_sprMUCompletedCase]    Script Date: 12/01/2011 07:38:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_sprMUCompletedCase]
as
select cast(MUGroupCode as varchar(2))+'.'+cast(MUUnGroupCode as varchar(2))+'.'+cast(MUCode as varchar(3)) as MU,AdultUET,ChildUET,unitCode,unitName,
		Profile,AgeGroupShortName,cast(MUGroupCodeP as varchar(2))+'.'+cast(MUUnGroupCodeP as varchar(2))+'.'+cast(MUCodeP as varchar(3)) as MU_P
from oms_NSI.dbo.vw_sprMUAll
where MUGroupCodeP is not null
GO
/****** Object:  View [dbo].[vw_sprMUAll]    Script Date: 12/01/2011 07:38:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_sprMUAll]
as
select cast(MUGroupCode as varchar(2))+'.'+cast(MUUnGroupCode as varchar(2))+'.'+cast(MUCode as varchar(3)) as MU,AdultUET,ChildUET,unitCode,unitName,
		Profile,AgeGroupShortName,cast(MUGroupCodeP as varchar(2))+'.'+cast(MUUnGroupCodeP as varchar(2))+'.'+cast(MUCodeP as varchar(3)) as MU_P
from oms_NSI.dbo.vw_sprMUAll
GO
/****** Object:  View [dbo].[vw_sprMU]    Script Date: 12/01/2011 07:38:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_sprMU]
as
select cast(MUGroupCode as varchar(2))+'.'+cast(MUUnGroupCode as varchar(2))+'.'+cast(MUCode as varchar(3)) as MU,AdultUET,ChildUET,unitCode,unitName
from oms_NSI.dbo.vw_sprMUAll
where MUGroupCodeP is null
GO
/****** Object:  StoredProcedure [dbo].[usp_IsFileNameExists]    Script Date: 12/01/2011 07:38:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usp_IsFileNameExists]
				@fileName varchar(26)
as 

select COUNT(*) from t_File where upper(FileNameHR)= UPPER(rtrim(ltrim(@fileName)))
GO
/****** Object:  Table [dbo].[t_RegisterPatient]    Script Date: 12/01/2011 07:38:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[t_RegisterPatient](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[rf_idFiles] [int] NOT NULL,
	[Fam] [nvarchar](40) NOT NULL,
	[Im] [nvarchar](40) NOT NULL,
	[Ot] [nvarchar](40) NULL,
	[rf_idV005] [tinyint] NOT NULL,
	[BirthDay] [date] NOT NULL,
	[BirthPlace] [nvarchar](100) NULL,
	[rf_idRecordCase] [int] NULL,
	[ID_Patient] [varchar](36) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  View [dbo].[vw_CaseNotDefineYeat]    Script Date: 12/01/2011 07:38:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_CaseNotDefineYeat]
as
select czp1.rf_idRefCaseIteration,czp1.rf_idZP1
from t_RefCasePatientDefine rf inner join t_CaseDefineZP1 czp1 on
					rf.id=czp1.rf_idRefCaseIteration
							left join t_CasePatientDefineIteration i on
					rf.id=i.rf_idRefCaseIteration
where i.rf_idRefCaseIteration is null
group by czp1.rf_idRefCaseIteration,czp1.rf_idZP1
GO
/****** Object:  Table [dbo].[t_RegistersCase]    Script Date: 12/01/2011 07:38:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[t_RegistersCase](
	[rf_idFiles] [int] NOT NULL,
	[id] [int] IDENTITY(1,1) NOT NULL,
	[rf_idMO] [char](6) NOT NULL,
	[ReportYear] [smallint] NOT NULL,
	[ReportMonth] [tinyint] NOT NULL,
	[NumberRegister] [int] NOT NULL,
	[DateRegister] [date] NOT NULL,
	[rf_idSMO] [char](5) NULL,
	[AmountPayment] [decimal](15, 2) NOT NULL,
	[Comments] [varchar](250) NULL,
	[AmountPaymentAccept] [decimal](11, 2) NULL,
	[AmountMEK] [decimal](15, 2) NULL,
	[AmountMEE] [decimal](15, 2) NULL,
	[AmountEKMP] [decimal](15, 2) NULL,
	[idRecord] [int] NOT NULL,
 CONSTRAINT [PK_RegisterCases_idFiles_idRegisterCases] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[t_FileNameError]    Script Date: 12/01/2011 07:38:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[t_FileNameError](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[rf_idFileError] [int] NOT NULL,
	[FileName] [varchar](26) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[t_Error]    Script Date: 12/01/2011 07:38:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[t_Error](
	[rf_idFileNameError] [int] NOT NULL,
	[rf_idF012] [smallint] NOT NULL,
	[rf_idXMLElement] [int] NULL,
	[rf_idGuidFieldError] [varchar](40) NULL,
	[ErrorTagAlter] [varchar](40) NULL,
	[ErrorParentTagAlter] [varchar](40) NULL,
	[Comments] [nvarchar](250) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[t_RecordCase]    Script Date: 12/01/2011 07:38:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[t_RecordCase](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[rf_idRegistersCase] [int] NOT NULL,
	[idRecord] [smallint] NOT NULL,
	[IsNew] [bit] NULL,
	[ID_Patient] [varchar](36) NOT NULL,
	[rf_idF008] [tinyint] NOT NULL,
	[SeriaPolis] [varchar](10) NULL,
	[NumberPolis] [varchar](20) NOT NULL,
	[NewBorn] [char](9) NOT NULL,
 CONSTRAINT [PK_RecordCase_idFiles_idRecordCase] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[t_RegisterPatientDocument]    Script Date: 12/01/2011 07:38:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[t_RegisterPatientDocument](
	[rf_idRegisterPatient] [int] NULL,
	[rf_idDocumentType] [char](2) NULL,
	[SeriaDocument] [varchar](10) NULL,
	[NumberDocument] [varchar](20) NULL,
	[SNILS] [char](14) NULL,
	[OKATO] [char](11) NULL,
	[OKATO_Place] [char](11) NULL,
	[Comments] [nvarchar](250) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[t_RegisterPatientAttendant]    Script Date: 12/01/2011 07:38:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_RegisterPatientAttendant](
	[rf_idRegisterPatient] [int] NULL,
	[Fam] [nvarchar](40) NOT NULL,
	[Im] [nvarchar](40) NOT NULL,
	[Ot] [nvarchar](40) NOT NULL,
	[rf_idV005] [tinyint] NOT NULL,
	[BirthDay] [date] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[t_RecordCaseBack]    Script Date: 12/01/2011 07:38:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_RecordCaseBack](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[rf_idRegisterCaseBack] [int] NOT NULL,
	[rf_idRecordCase] [int] NOT NULL,
	[rf_idCase] [bigint] NOT NULL,
 CONSTRAINT [PK_RecordCaseBack] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[t_PatientSMO]    Script Date: 12/01/2011 07:38:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[t_PatientSMO](
	[ref_idRecordCase] [int] NOT NULL,
	[rf_idSMO] [char](5) NULL,
	[OGRN] [char](15) NULL,
	[OKATO] [char](5) NULL,
	[Name] [nvarchar](100) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[t_Case]    Script Date: 12/01/2011 07:38:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[t_Case](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[rf_idRecordCase] [int] NOT NULL,
	[idRecordCase] [int] NOT NULL,
	[GUID_Case] [uniqueidentifier] NOT NULL,
	[rf_idV006] [tinyint] NULL,
	[rf_idV008] [smallint] NULL,
	[rf_idDirectMO] [char](6) NULL,
	[HopitalisationType] [tinyint] NULL,
	[rf_idMO] [char](6) NOT NULL,
	[rf_idSubMO] [char](6) NULL,
	[rf_idDepartmentMO] [int] NULL,
	[rf_idV002] [smallint] NOT NULL,
	[IsChildTariff] [bit] NOT NULL,
	[NumberHistoryCase] [nvarchar](50) NOT NULL,
	[DateBegin] [date] NOT NULL,
	[DateEnd] [date] NOT NULL,
	[rf_idV009] [smallint] NOT NULL,
	[rf_idV012] [smallint] NOT NULL,
	[rf_idV004] [int] NOT NULL,
	[rf_idDoctor] [char](16) NULL,
	[IsSpecialCase] [tinyint] NULL,
	[rf_idV010] [tinyint] NOT NULL,
	[AmountPayment] [decimal](15, 2) NOT NULL,
	[TypePay] [tinyint] NULL,
	[AmountPaymentAccept] [decimal](15, 2) NULL,
	[Comments] [nvarchar](250) NULL,
	[Age] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  View [dbo].[vw_GlobalError]    Script Date: 12/01/2011 07:38:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_GlobalError]
as
select f.id,fn.id as id1,f.FileNameP, fn.[FileName],e.rf_idF012 as ErrorID, e.Comments as Error
from t_FileError f inner join t_FileTested ft on
			f.rf_idFileTested=ft.id
					inner join t_FileNameError fn on
			f.id=fn.rf_idFileError
					left join t_Error e on
			fn.id=e.rf_idFileNameError
GO
/****** Object:  View [dbo].[vw_ErrorXSD]    Script Date: 12/01/2011 07:38:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_ErrorXSD]
as
select fe.rf_idFileError,e.rf_idFileNameError,e.rf_idF012,case when vw_xml.NameElement is null then e.ErrorTagAlter else vw_xml.NameElement end as NameElement,
		case when vw_xml.ParentElementName is null then e.ErrorParentTagAlter else vw_xml.ParentElementName  end as ParentElementName,
		case when e.rf_idGuidFieldError='' then null else e.rf_idGuidFieldError end as rf_idGuidFieldError,
		vw_error.AdditionalInfo
from t_FileNameError fe inner join t_Error e on
		fe.id=e.rf_idFileNameError
					left join vw_XmlTag vw_xml on
		e.rf_idXMLElement=vw_xml.id
					inner join vw_sprF012 vw_error on
		e.rf_idF012=vw_error.id
GO
/****** Object:  StoredProcedure [dbo].[usp_SetGlobalXSDError]    Script Date: 12/01/2011 07:38:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[usp_SetGlobalXSDError]
			@errorTable as TVP_Error READONLY,
			@file varchar(26),
			@fileID int=0
as
begin transaction

begin try
declare @idFileTest int
	
	if @fileID=0
	begin
		insert t_FileTested(DateRegistration,[FileName],UserName) 
		select GETDATE(),@file,ORIGINAL_LOGIN()
		
		select @idFileTest=SCOPE_IDENTITY()
	end
	else 
	begin
		select @idFileTest=rf_idFileTested from t_File where id=@fileID
	end
	
	insert t_FileError(rf_idFileTested,DateCreate,[FileNameP]) 
	values(@idFileTest,GETDATE(),'P'+@file)
	
	select @idFileTest=SCOPE_IDENTITY()
	
	declare @t as table(id int,NameFile varchar(26))
	
	insert t_FileNameError(rf_idFileError,[FileName]) 
	output inserted.id,inserted.FileName into @t
	values(@idFileTest,@file),(@idFileTest,'L'+RIGHT(@file,LEN(@file)-1))
	
	insert t_Error(rf_idFileNameError,rf_idF012,rf_idXMLElement,rf_idGuidFieldError,ErrorTagAlter,ErrorParentTagAlter)
	select t1.id,e.ErrorNumber,el.id,e.ErrorValue,e.ErrorTag,e.ErrorParentTag
	from @errorTable e left join vw_XmlTag el on
				LTRIM(rtrim(e.ErrorTag))=ltrim(rtrim(el.NameElement)) and
				LTRIM(rtrim(e.ErrorParentTag))=ltrim(rtrim(el.ParentElementName))				
						inner join @t t1 on
				LTRIM(rtrim(e.ErrorFile))=t1.NameFile
	group by t1.id,e.ErrorNumber,el.id,e.ErrorValue,e.ErrorTag,e.ErrorParentTag
	-------------------------------------------------------------
	select FileNameP 'FNAME',[FileName] 'FNAME_I',
	(	select rf_idF012 'OSHIB', 
			NameElement 'IM_POL', 
			ParentElementName 'BAS_EL', 
			rf_idGuidFieldError 'ID_BAS',
			AdditionalInfo 'COMMENT'
		from vw_ErrorXSD e where e.rf_idFileNameError=fe.id FOR XML PATH('PR'),TYPE
	)
	from t_FileError f inner join t_FileNameError fe on
				f.id=fe.rf_idFileError
						inner join (select MIN(t.id) as id from @t t) t on
				fe.id=t.id
	FOR XML PATH(''),TYPE,ROOT('FLK_P')
	----------------------------------------------------------------
	select FileNameP 'FNAME',[FileName] 'FNAME_I',
	(	select rf_idF012 'OSHIB', 
			NameElement 'IM_POL', 
			ParentElementName 'BAS_EL', 
			rf_idGuidFieldError 'ID_BAS',
			AdditionalInfo 'COMMENT'
		from vw_ErrorXSD e where e.rf_idFileNameError=fe.id FOR XML PATH('PR'),TYPE
	)
	from t_FileError f inner join t_FileNameError fe on
				f.id=fe.rf_idFileError
					   inner join (select MAX(t.id) as id from @t t) t on
				fe.id=t.id
	FOR XML PATH(''),TYPE,ROOT('FLK_P')
	
end try
begin catch
if @@TRANCOUNT>0
    select ERROR_MESSAGE()
	rollback transaction
end catch
if @@TRANCOUNT>0
	commit transaction
GO
/****** Object:  StoredProcedure [dbo].[usp_SetGlobalError]    Script Date: 12/01/2011 07:38:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[usp_SetGlobalError]
			@fileName varchar(26),
			@errorId int=0
as
/*Данная процедура вызывается для фиксации глобальных ошибок в бд. Это ошибки с номером <900.*/
begin transaction

begin try
declare @idFileTest int
	
	insert t_FileTested(DateRegistration,[FileName],UserName) values(GETDATE(),@fileName,ORIGINAL_LOGIN())
	
	select @idFileTest=SCOPE_IDENTITY()
	
	insert t_FileError(rf_idFileTested,DateCreate,[FileNameP]) values(@idFileTest,GETDATE(),'P'+@fileName)
	select @idFileTest=SCOPE_IDENTITY()
	
	declare @t as table(id int,NameFile varchar(26))
		
	declare @t1 int, @t2 int
	
	insert t_FileNameError(rf_idFileError,[FileName]) 
	values(@idFileTest,@fileName)
	select @t1=SCOPE_IDENTITY()
	
	insert t_FileNameError(rf_idFileError,[FileName]) 
	values(@idFileTest,'L'+RIGHT(@fileName,LEN(@fileName)-1))
	select @t2=SCOPE_IDENTITY()	
	
	if @errorId>0
	begin
		insert t_Error(rf_idFileNameError,rf_idF012,Comments) 
		select @t1,@errorId, AdditionalInfo 
		from dbo.vw_sprF012 
		where id=@errorId
	end
	
	select FileNameP 'FNAME', [FileName] 'FNAME_I', ErrorID 'PR/OSHIB', ERROR 'PR/COMMENT' 		
	from vw_GlobalError
	where id=@idFileTest and id1=@t1	
	FOR XML PATH(''),TYPE,ROOT('FLK_P')
	
	select FileNameP 'FNAME', [FileName] 'FNAME_I', ErrorID 'PR/OSHIB', ERROR 'PR/COMMENT' 		
	from vw_GlobalError
	where id=@idFileTest and id1=@t2	
	FOR XML PATH(''),TYPE,ROOT('FLK_P')
		
end try
begin catch
if @@TRANCOUNT>0
	select ERROR_MESSAGE()
	rollback transaction
end catch
if @@TRANCOUNT>0
	commit transaction
GO
/****** Object:  StoredProcedure [dbo].[usp_DefineSMOIteration2_4]    Script Date: 12/01/2011 07:38:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[usp_DefineSMOIteration2_4]
			@idRecordCase TVP_CasePatient READONLY,
			@iteration tinyint,
			@file varchar(26)
			
as
SET REMOTE_PROC_TRANSACTIONS OFF;
SET xact_abort ON;

-- id вставленных записях в таблицу t_RefCaseIteration
declare @idTable as table(id bigint,rf_idCase bigint,rf_idRegisterPatient int) 

--id вставленной записи в таблицу ZP1LOG
declare @ZID int 
--begin try
--дабовляю в таблицу t_RefCaseIteration сведения с итерацией №2 или №4
/*
insert t_RefCasePatientDefine(rf_idCase,rf_idRegisterPatient)
	output inserted.id,inserted.rf_idCase, inserted.rf_idRegisterPatient into @idTable
select c.rf_idCase as rf_idCase,c.ID_Patient as rf_idPatient
from @idRecordCase c 
*/
insert @idTable
select rf.id, t.rf_idCase,t.ID_Patient
from @idRecordCase t inner join t_RefCasePatientDefine rf on
		t.rf_idCase=rf.rf_idCase and
		t.ID_Patient=rf.rf_idRegisterPatient

--В таблицу ZP1LOG добовляю записи о файле. В качестве имени файла @iteration+@file
declare @count int,
		@fileName varchar(27)=CAST(@iteration as CHAR(1))+@file
				
select @count=COUNT(t.rf_idCase) from @idRecordCase t


--объявляю переменную для того что бы передать ее в удаленную процедуру
declare @xml nvarchar(max)
-- добавляю данные в таблицу PolicyRegister.dbo.ZP1
if @iteration=2
begin

set @xml=( select t.id as RECID,
				   rtrim(p.Fam) as FAM,
				   rtrim(p.Im) as IM,
				   rtrim(p.Ot) as OT,
				   p.BirthDay as DR,
				   p.rf_idV005 as W,
				   rc.rf_idF008 as OPDOC,
				   rtrim(rc.SeriaPolis) as SPOL,
				   rtrim(rc.NumberPolis) as NPOL,
				   c.DateEnd as DOUT,
				   pd.rf_idDocumentType as DOCTP ,
				   rtrim(pd.SeriaDocument) as DOCS,
				   rtrim(pd.NumberDocument) as DOCN,
				   pd.SNILS as SS
			from @idTable t inner join t_Case c on
					t.rf_idCase=c.id 
							inner join t_RegisterPatient p on
					t.rf_idRegisterPatient=p.id
							inner join t_RecordCase rc on
					p.rf_idRecordCase=rc.id
							left join t_RegisterPatientDocument pd on
					p.id=pd.rf_idRegisterPatient
			FOR XML PATH('CASE'),ROOT('PATIENT')
		 )

end	
if @iteration=4
begin
set @xml=(  select t.id as RECID,
				   rtrim(p.Fam) as FAM,
				   rtrim(p.Im) as IM,
				   rtrim(p.Ot) as OT,
				   p.BirthDay as DR,
				   p.rf_idV005 as W,
				   rc.rf_idF008 as OPDOC,
				   rtrim(rc.SeriaPolis) as SPOL,
				   rtrim(rc.NumberPolis) as NPOL,
				   null as DOUT,
				   pd.rf_idDocumentType as DOCTP ,
				   rtrim(pd.SeriaDocument) as DOCS,
				   rtrim(pd.NumberDocument) as DOCN,
				   pd.SNILS as SS
			from @idTable t inner join t_Case c on
					t.rf_idCase=c.id 
							inner join t_RegisterPatient p on
					t.rf_idRegisterPatient=p.id
							inner join t_RecordCase rc on
					p.rf_idRecordCase=rc.id
							left join t_RegisterPatientDocument pd on
					p.id=pd.rf_idRegisterPatient
			FOR XML PATH('CASE'),ROOT('PATIENT')
		)
end
--перед развертыванием не обходимо изменить PolicyRegisterTest на PolicyRegister
insert t_CaseDefineZP1(rf_idRefCaseIteration,rf_idZP1) exec [srvsql1-st2].PolicyRegisterTest.dbo.usp_InsertFilesZP1LPOG @fileName,@count,@xml

--выполняем процедуру usp_InsertZP1, а результат записываем в таблицу для дальнейшей обработки
--insert t_CaseDefineZP1(rf_idRefCaseIteration,rf_idZP1) 
--exec [srvsql1-st2].PolicyRegisterTest.dbo.usp_InsertFilesZP1LPOG @fileName,@count,@xml
--exec [srvsql1-st2].PolicyRegisterTest.dbo.usp_InsertZP1 @xml,@ZID
--end try
--begin catch
--	select ERROR_MESSAGE()
--end catch
GO
/****** Object:  StoredProcedure [dbo].[usp_DefineSMOIteration1_3]    Script Date: 12/01/2011 07:38:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[usp_DefineSMOIteration1_3]
			@idRecordCase TVP_CasePatient READONLY,
			@iteration tinyint,
			@id int=null
as
declare @idTable as table(id bigint,rf_idCase bigint,rf_idRegisterPatient int)

begin transaction
begin try
--дабовляю в таблицу t_RefCaseIteration сведения с итерацией №1 
if @iteration=1
begin
	insert t_RefCasePatientDefine(rf_idCase,rf_idRegisterPatient,rf_idFiles)
		output inserted.id,inserted.rf_idCase, inserted.rf_idRegisterPatient into @idTable
	select c.rf_idCase as rf_idCase,c.ID_Patient as rf_idPatient,@id
	from @idRecordCase c 
end	
--при итерации №3 добавлять данные в таблицу t_RefCasePatientDefine не нужно т.к. они там уже лежать. 
--мы просто получаем необходимые данные
else 
begin
	insert @idTable
	select cd.id,t.rf_idCase,t.ID_Patient
	from @idRecordCase t inner join t_RefCasePatientDefine cd on
				t.rf_idCase=cd.rf_idCase
				and t.ID_Patient=cd.rf_idRegisterPatient
end

-- сначала определяю PID из РС ЕРЗ
declare @tPeople as table
(
	rf_idRefCaseIteration bigint,
	PID int,
    DateEnd date
)
insert @tPeople
select t.id,dbo.getPID(null,case when rc.rf_idF008=3 then rc.SeriaPolis else null end,p.Fam,p.Im,p.Ot,p.BirthDay,p.BirthPlace,pd.SNILS,null,pd.NumberDocument,null),
		c.DateEnd
from @idTable t inner join t_Case c on
		t.rf_idCase=c.id 
				inner join t_RegisterPatient p on
		t.rf_idRegisterPatient=p.id
				inner join t_RecordCase rc on
		p.rf_idRecordCase=rc.id
				left join t_RegisterPatientDocument pd on
		p.id=pd.rf_idRegisterPatient

--таблица с id случаями по которым определена страховая принадлежность
declare @tableCaseDefine as table (rf_idRefCaseIteration bigint) 

if @iteration=1
begin

	-- заношу данные после первой итерации, для того что бы мог добавить данные во вторую итерацию
	insert t_CaseDefine(rf_idRefCaseIteration,DateDefine,PID,UniqueNumberPolicy,IsDefined, SMO,SPolicy,NPolcy,RN,rf_idF008)
		output inserted.rf_idRefCaseIteration into @tableCaseDefine
	select TOP 1 WITH TIES t.rf_idRefCaseIteration, GETDATE(), t.PID,p.ENP,1,pol.Q,pol.SPOL,pol.NPOL,p.RN,pol.POLTP
	from vw_People p inner join @tPeople t on
							p.ID=t.pid
							inner join vw_Polis pol on
							p.ID=pol.PID
	where t.pid is not null and t.DateEnd>=pol.DBEG and t.DateEnd<=pol.DEND and pol.Q is not null--т.к. в базе есть люди у которых не определена СМО, хотя ОГРН СМО есть.
	ORDER BY ROW_NUMBER() OVER(PARTITION BY t.rf_idRefCaseIteration,pol.PID ORDER BY pol.DBEG desc)		
	
end
if @iteration=3
begin
	-- заношу данные после первой итерации, для того что бы мог добавить данные во вторую итерацию
	insert t_CaseDefine(rf_idRefCaseIteration,DateDefine,PID,UniqueNumberPolicy,IsDefined, SMO,SPolicy,NPolcy,RN,rf_idF008)
		output inserted.rf_idRefCaseIteration into @tableCaseDefine
	select t.rf_idRefCaseIteration, GETDATE(), t.PID,p.ENP,1,pol.Q,pol.SPOL,pol.NPOL,p.RN,pol.POLTP
	from vw_People p inner join @tPeople t on
							p.ID=t.pid
							inner join (
										SELECT TOP 1 WITH TIES *
										from vw_Polis t
										ORDER BY ROW_NUMBER() OVER(PARTITION BY t.PID ORDER BY t.DBeg desc)
										)pol on
							p.ID=pol.PID
	where t.pid is not null 
end
--сохраняю сведения с id случаем и номером итерации на котором данный случай был определен
insert t_CasePatientDefineIteration(rf_idRefCaseIteration,rf_idIteration)
select rf_idRefCaseIteration,@iteration from @tableCaseDefine
--


end try
begin catch
if @@TRANCOUNT>0
	select ERROR_MESSAGE()
	rollback transaction
end catch
if @@TRANCOUNT>0
	commit transaction
	
--записи по тем пациентам по которым не определан страховая принадлежность, передаем в процедуру usp_DefineSMOIteration2_4
--для определения страховой принадлежности в ЦС ЕРЗ
/*
select rfc.rf_idCase, rfc.rf_idRegisterPatient
from t_RefCasePatientDefine rfc inner join @idRecordCase c on
			rfc.rf_idCase=c.rf_idCase and 
			rfc.rf_idRegisterPatient=c.ID_Patient
				left join t_CaseDefine cd on
			rfc.id=cd.rf_idRefCaseIteration						
where cd.rf_idRefCaseIteration is null
*/
select c.rf_idCase, c.ID_Patient
from t_RefCasePatientDefine rfc inner join t_CaseDefine cd on
			rfc.id=cd.rf_idRefCaseIteration
			right join @idRecordCase c on
			rfc.rf_idCase=c.rf_idCase and 
			rfc.rf_idRegisterPatient=c.ID_Patient						
where rfc.id is null
GO
/****** Object:  StoredProcedure [dbo].[usp_RegistrationRegisterCaseReport]    Script Date: 12/01/2011 07:38:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usp_RegistrationRegisterCaseReport]
				@idFile int
as
declare @countIdCase int,
		@countIdCasePR int,
		@countIdCaseNoE int,
		@FileNameBack varchar(26),
		@NumberSPTK varchar(15),
		@DateRegisterBack char(10)

select @countIdCase=COUNT(Distinct c.id),@countIdCasePR=COUNT(cd.rf_idRefCaseIteration)--,@countIdCasePRG=COUNT(zp1.rf_idRefCaseIteration)
from t_File f inner join t_RegistersCase r on
			f.id=r.rf_idFiles
				  inner join t_RecordCase rc on
			r.id=rc.rf_idRegistersCase
				  inner join t_Case c on
			rc.id=c.rf_idRecordCase
				  left join t_RefCasePatientDefine rf on
			c.id=rf.rf_idCase
				  left join t_CaseDefine cd on
			rf.id=cd.rf_idRefCaseIteration
			--		left join t_CaseDefineZP1 zp1 on
			--rf.id=zp1.rf_idRefCaseIteration						
where f.id=@idFile	

--------------------------------------------------------------------------------------------------------------------------------------------
select @FileNameBack=FileNameHRBack,@DateRegisterBack=CONVERT(char(10),r.DateCreate,104),
		@NumberSPTK=CAST(NumberRegister as varchar(8))+'-'+CAST(PropertyNumberRegister as varchar(3))
from t_FileBack fb inner join t_RegisterCaseBack r on
		fb.id=r.rf_idFilesBack
where rf_idFiles=@idFile
----------------------------------------------------------------------------------------------------------------------------------------------
select @countIdCaseNoE=COUNT(c.id)
from t_File f inner join t_RegistersCase r on
			f.id=r.rf_idFiles and f.id=@idFile			
				  inner join t_RecordCase rc on
			r.id=rc.rf_idRegistersCase
				  inner join t_Case c on
			rc.id=c.rf_idRecordCase
					inner join t_RefCasePatientDefine rf on
			c.id=rf.rf_idCase
				  inner join t_CaseDefine cd on
			rf.id=cd.rf_idRefCaseIteration
				  left join t_ErrorProcessControl e on
			c.id=e.rf_idCase and
			f.id=e.rf_idFile			
where e.rf_idCase is null
--------------------------------------------------------------------------------------------------------------------------------------------
select rtrim(f.FileNameHR)+'.zip' as FileZIP,t001.NameS,r.ReportMonth,r.ReportYear,
		convert(CHAR(10),f.DateRegistration,104)+' '+cast(cast(f.DateRegistration as time(7)) as varchar(8)) as DateRegistration,
		f.CountSluch,(f.CountSluch-@countIdCase) as ErrorFLK,@countIdCase as CountIdCase,r.NumberRegister,CONVERT(char(10),r.DateRegister,104) as DateRegister,		
		fe.FileNameP,@countIdCasePR as countIdCasePR,@countIdCaseNoE as countIdCaseNoE,@FileNameBack as FileNameBack,@NumberSPTK as NumberSPTK,
		@DateRegisterBack as DateRegisterBack		
from t_File f inner join t_RegistersCase r on
		f.id=r.rf_idFiles
			  inner join vw_sprT001 t001 on
		r.rf_idMO=t001.mcod
				inner join t_FileTested ft on
		f.rf_idFileTested=ft.id
				inner join t_FileError fe on
		ft.id=fe.rf_idFileTested
where f.id=@idFile
GO
/****** Object:  Table [dbo].[t_CaseBack]    Script Date: 12/01/2011 07:38:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_CaseBack](
	[rf_idRecordCaseBack] [int] NOT NULL,
	[TypePay] [tinyint] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[t_Diagnosis]    Script Date: 12/01/2011 07:38:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[t_Diagnosis](
	[DiagnosisCode] [char](10) NULL,
	[rf_idCase] [bigint] NOT NULL,
	[TypeDiagnosis] [tinyint] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[t_Meduslugi]    Script Date: 12/01/2011 07:38:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[t_Meduslugi](
	[rf_idCase] [bigint] NOT NULL,
	[id] [int] NOT NULL,
	[GUID_MU] [uniqueidentifier] NOT NULL,
	[rf_idMO] [char](6) NOT NULL,
	[rf_idSubMO] [char](6) NULL,
	[rf_idDepartmentMO] [int] NULL,
	[rf_idV002] [smallint] NOT NULL,
	[IsChildTariff] [bit] NOT NULL,
	[DateHelpBegin] [date] NOT NULL,
	[DateHelpEnd] [date] NOT NULL,
	[DiagnosisCode] [char](10) NOT NULL,
	[MUCode] [varchar](16) NOT NULL,
	[Quantity] [decimal](6, 2) NOT NULL,
	[Price] [decimal](15, 2) NOT NULL,
	[TotalPrice] [decimal](15, 2) NOT NULL,
	[rf_idV004] [int] NOT NULL,
	[rf_idDoctor] [char](16) NULL,
	[Comments] [nvarchar](250) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[t_FinancialSanctions]    Script Date: 12/01/2011 07:38:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_FinancialSanctions](
	[rf_idCase] [bigint] NOT NULL,
	[Amount] [decimal](15, 2) NOT NULL,
	[TypeSanction] [tinyint] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[t_ReasonPaymentCancelled]    Script Date: 12/01/2011 07:38:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_ReasonPaymentCancelled](
	[rf_idCase] [bigint] NOT NULL,
	[rf_idPaymentAccountCanseled] [tinyint] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[t_PatientBack]    Script Date: 12/01/2011 07:38:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[t_PatientBack](
	[rf_idRecordCaseBack] [int] NOT NULL,
	[rf_idF008] [tinyint] NOT NULL,
	[SeriaPolis] [varchar](10) NULL,
	[NumberPolis] [varchar](20) NOT NULL,
	[rf_idSMO] [char](5) NOT NULL,
	[OKATO] [char](5) NULL
) ON [RegisterCases]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[t_MES]    Script Date: 12/01/2011 07:38:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[t_MES](
	[MES] [char](16) NULL,
	[rf_idCase] [bigint] NOT NULL,
	[TypeMES] [tinyint] NOT NULL,
	[Quantity] [decimal](5, 2) NULL,
	[Tariff] [decimal](15, 2) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  UserDefinedFunction [dbo].[fn_PlanOrders]    Script Date: 12/01/2011 07:38:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_PlanOrders](@codeLPU varchar(6),@month tinyint,@year smallint)
RETURNS @plan TABLE
					(
						CodeLPU varchar(6),
						UnitCode int,
						Vm int,
						Vdm int,
						Spred int
					)
AS
begin
declare @plan1 TABLE(
						CodeLPU varchar(6),
						UnitCode int,
						Vm int,
						Vdm int,
						Spred int
					)
-------------------------------------------------------------------------------------
declare @t as table(MonthID tinyint,QuarterID tinyint,partitionQuarterID tinyint)
insert @t values(1,1,1),(2,1,2),(3,1,3),
				(4,2,1),(5,2,2),(6,2,3),
				(7,3,1),(8,3,2),(9,3,3),
				(10,4,1),(11,4,2),(12,4,3)
--first query:расчет V суммарный объем планов-заказов, соответствующий всем предшествующим календарным кварталам за текущий год
--second query:расчет N*Int(Vt/3) объема плана-заказа делится на 3 и умножается на порядковый номер отчетного месяца в квартале и остаток от деления Vt-Int(Vt/3)
--third query: расчет Vkm сумарного объема всех изменений планов заказов из tPlanCorrection без МЕК
--third query: расчет Vdm сумарного объема всех изменений планов заказов из tPlanCorrection только МЕК
insert @plan1(CodeLPU,UnitCode,Vm,Vdm)
 select left(t1.tfomsCode,6),t1.unitCode,t1.V+isnull(t2.Vt,0)+isnull(t2.O,0)+isnull(t3.Vkm,0),isnull(t3.Vdm,0)--,t1.V,t2.Vt,t2.O,t3.Vkm
	from (
		select mo.tfomsCode,SUM(pl.rate) as V,pu.unitCode
		from oms_NSI.dbo.tPlanYear py inner join oms_NSI.dbo.tMO mo on
					py.rf_MOId=mo.MOId and
					py.[year]=@year
						inner join oms_NSI.dbo.tPlan pl on
					py.PlanYearId=pl.rf_PlanYearId and pl.flag='A'
						inner join oms_NSI.dbo.tPlanUnit pu on
					pl.rf_PlanUnitId=pu.PlanUnitId
						inner join @t t on
					pl.rf_QuarterId<t.QuarterID				
		where left(mo.tfomsCode,6)=@codeLPU and t.MonthID=@month
		group by mo.tfomsCode,pu.unitCode
		) t1 left join (
							select mo.tfomsCode,pu.unitCode,(t.partitionQuarterID*(cast(SUM(pl.rate)/3 as int))) as Vt,SUM(pl.rate)-3*cast(SUM(pl.rate)/3 as int) as O
							from oms_NSI.dbo.tPlanYear py inner join oms_NSI.dbo.tMO mo on
										py.rf_MOId=mo.MOId and
										py.[year]=@year
											inner join oms_NSI.dbo.tPlan pl on
										py.PlanYearId=pl.rf_PlanYearId and 
										pl.flag='A'
											inner join oms_NSI.dbo.tPlanUnit pu on
										pl.rf_PlanUnitId=pu.PlanUnitId				
											inner join @t t on
										pl.rf_QuarterId=t.QuarterID
							where left(mo.tfomsCode,6)=@codeLPU and t.MonthID=@month
							group by mo.tfomsCode,pu.unitCode,t.partitionQuarterID
							) t2 on
		t1.tfomsCode=t2.tfomsCode and
		t1.unitCode=t2.unitCode
			left join (
						select mo.tfomsCode,pu.unitCode,sum(case when pc.mec=0 then ISNULL(pc.correctionRate,0) else 0 end) as Vkm,
								sum(case when pc.mec=1 then ISNULL(pc.correctionRate,0) else 0 end) as Vdm
						from oms_NSI.dbo.tPlanYear py inner join oms_NSI.dbo.tMO mo on
									py.rf_MOId=mo.MOId and
									py.[year]=@year
										inner join oms_NSI.dbo.tPlan pl on
									py.PlanYearId=pl.rf_PlanYearId and 
									pl.flag='A'
										inner join oms_NSI.dbo.tPlanUnit pu on
									pl.rf_PlanUnitId=pu.PlanUnitId
										left join oms_NSI.dbo.tPlanCorrection pc on
									pl.PlanId=pc.rf_PlanId and pc.rf_MonthId<=@month
						where left(mo.tfomsCode,6)=@codeLPU 
						group by mo.tfomsCode,pu.unitCode
						) t3 on
		t1.tfomsCode=t3.tfomsCode and
		t1.unitCode=t3.unitCode
---------------расчет Sпред--------------------------------------------
declare @tS as table(CodeLPU char(6),unitCode tinyint,Rate int)
--берутся все случаи представленные в реестрах СП и ТК с типом оплаты 1 и если данный случай не является иногородним
insert @tS
select c.rf_idMO
		,t1.unitCode
		,SUM(m.Quantity) as Quantity
from t_Case c inner join t_Meduslugi m on
		c.id=m.rf_idCase and c.rf_idMO=@codeLPU
				inner join dbo.vw_sprMU t1 on
		m.MUCode=t1.MU
				inner join t_RecordCase rc on
		c.rf_idRecordCase=rc.id
				inner join t_RegistersCase r on
		rc.rf_idRegistersCase=r.id and
		r.ReportMonth=@month and
		r.ReportYear=@year
				inner join t_RecordCaseBack cb on
		c.id=cb.rf_idCase
				inner join t_PatientBack p on
		cb.id=p.rf_idRecordCaseBack
				inner join vw_sprSMO s on
			p.rf_idSMO=s.smocod
				inner join t_CaseBack ct on
		cb.id=ct.rf_idRecordCaseBack and ct.TypePay=1				
group by c.rf_idMO,t1.unitCode			
			
--insert @tS select CodeLPU,unitCode,RATE from t_PlanOrders2011 where CodeLPU=@codeLPU 
insert @tS
select CodeLPU,unitCode,SUM(Rate)
from t_PlanOrders2011 
where CodeLPU=@codeLPU and MonthRate<=@month
group by CodeLPU,unitCode
--------------------------------------------------------------------------------------
insert @plan1(CodeLPU,UnitCode,Vm,Vdm,Spred)
select t.CodeLPU,t.unitCode,0,0,t.Rate
from @tS t
	
insert @plan(CodeLPU,UnitCode,Vm,Vdm,Spred)
select CodeLPU,UnitCode,sum(Vm),sum(Vdm),isnull(sum(Spred),0)
from @plan1 
group by CodeLPU,UnitCode
		
	RETURN
end;
GO
/****** Object:  StoredProcedure [dbo].[usp_RegisterSP_TK]    Script Date: 12/01/2011 07:38:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[usp_RegisterSP_TK]
			@idFileBack int
as

update t_FileBack set IsUnload=1 where id=@idFileBack

select FileVersion as [VERSION],cast(DateCreate as date) as DATA,FileNameHRBack as [FILENAME]
from t_FileBack
where id=@idFileBack

select id as CODE, ref_idF003 as CODE_MO,cast(ReportYear as int) as [YEAR],cast(ReportMonth as int) as [MONTH],
		CAST(NumberRegister as varchar(8))+'-'+CAST(PropertyNumberRegister as char(1)) as NSCHET,
		DateCreate as DSCHET
from t_RegisterCaseBack
where rf_idFilesBack=@idFileBack
	
select rc.idRecord as N_ZAP
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id
where rf_idFilesBack=@idFileBack
order by N_ZAP

select rc.ID_Patient as ID_PAC,p.rf_idF008 as VPOLIS,p.SeriaPolis as SPOLIS,p.NumberPolis as NPOLIS,
		p.rf_idSMO as SMO,p.OKATO as SMO_OK,rc.idRecord as N_ZAP
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
			rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
			recb.rf_idRecordCase=rc.id
							inner join t_PatientBack p on
			recb.id=p.rf_idRecordCaseBack
where rf_idFilesBack=@idFileBack
order by N_ZAP

select c.idRecordCase as IDCASE,c.GUID_Case as ID_C ,cd.TypePay as OPLATA,rc.idRecord as N_ZAP,null as COMENTSL
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
				rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
				recb.rf_idRecordCase=rc.id
							inner join t_Case c on
				recb.rf_idCase=c.id
							inner join t_CaseBack cd on
				recb.id=cd.rf_idRecordCaseBack
where rf_idFilesBack=@idFileBack
order by N_ZAP

select c.GUID_Case as ID_C,cast(e.ErrorNumber as int) as REFREASON
from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
				rcb.id=recb.rf_idRegisterCaseBack
							inner join t_RecordCase rc on
				recb.rf_idRecordCase=rc.id
							inner join t_Case c on
				recb.rf_idCase=c.id
							inner join t_CaseBack cd on
				recb.id=cd.rf_idRecordCaseBack
							inner join t_ErrorProcessControl e on
				recb.rf_idCase=e.rf_idCase
where rf_idFilesBack=@idFileBack
group by c.GUID_Case,e.ErrorNumber
GO
/****** Object:  StoredProcedure [dbo].[usp_FillBackTables]    Script Date: 12/01/2011 07:38:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[usp_FillBackTables]
			@CaseDefined TVP_CasePatient READONLY,		
			@idFile int,
			@property tinyint	
as
declare @fileName varchar(29),
		@idFileBack int,
		@idRegisterCaseBack int
declare @idRecordCaseBack as table(rf_idRecordCaseBack int,rf_idCase bigint)

--по поводу имени решить 
select @fileName=left(FileNameHR,2)+'T34_M'+REPLACE(SUBSTRING(FileNameHR,4,LEN(FileNameHR)),'T34_','') from t_File where id=@idFile

begin transaction
begin try
	--помечаем случаи из таблицы итерации, которые были отданы в Реестре СП и ТК
	update t_RefCasePatientDefine
	set IsUnloadIntoSP_TK=1
	from t_RefCasePatientDefine rf inner join @CaseDefined cd on
				rf.rf_idCase=cd.rf_idCase and
				rf.rf_idRegisterPatient=cd.ID_Patient


 insert t_FileBack(rf_idFiles,FileNameHRBack) values(@idFile,@fileName)
 select @idFileBack=SCOPE_IDENTITY()
 
 insert t_RegisterCaseBack(rf_idFilesBack,ref_idF003,ReportYear,ReportMonth,DateCreate,NumberRegister,PropertyNumberRegister)
 select @idFileBack,c.rf_idMO,c.ReportYear,c.ReportMonth,GETDATE(),NumberRegister,@property
 from t_RegistersCase c
 where c.rf_idFiles=@idFile
 select @idRegisterCaseBack=SCOPE_IDENTITY()
 
 
 insert t_RecordCaseBack(rf_idRecordCase,rf_idRegisterCaseBack,rf_idCase)
	output inserted.id,inserted.rf_idCase into @idRecordCaseBack
 select c.rf_idRecordCase,@idRegisterCaseBack,c.id
 from @CaseDefined cd inner join t_Case c on
		cd.rf_idCase=c.id
		
 insert t_PatientBack(rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,rf_idSMO,OKATO)
 select rcb.rf_idRecordCaseBack,c.rf_idF008,c.SPolicy,c.NPolcy,c.SMO,18000
 from @CaseDefined cd inner join t_RefCasePatientDefine rf on
			cd.rf_idCase=rf.rf_idCase
					  inner join t_CaseDefine c on
			rf.id=c.rf_idRefCaseIteration
						inner join @idRecordCaseBack rcb on
			cd.rf_idCase=rcb.rf_idCase
			
 insert t_CaseBack(rf_idRecordCaseBack,TypePay)		
 select rcb.rf_idRecordCaseBack,(case when e.ErrorNumber is null then 1 else 2 end) as TypePay
 from @CaseDefined cd inner join @idRecordCaseBack rcb on
			cd.rf_idCase=rcb.rf_idCase
					  left join t_ErrorProcessControl e on
			cd.rf_idCase=e.rf_idCase and
			e.rf_idFile=@idFile
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
GO
/****** Object:  StoredProcedure [dbo].[usp_GetProcessingZP1Data]    Script Date: 12/01/2011 07:38:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--процедура по обработке данных которые прешли из ЦС ЕРЗ
--решил избавиться от обработки данных в виде xml
create proc [dbo].[usp_GetProcessingZP1Data]
as
--для тестирования
--declare @t as table
--					(
--						rf_idCaseIteration bigint identity(1235,1),
--						rf_idZP1 int
--					)
--insert @t(rf_idZP1)
--select id
--from [srvsql1-st2].PolicyRegister.dbo.ZP1
--where ZID=30

declare @tFound as table(
							rf_idRefCaseIteration bigint,
							rf_idZP1 int,
							OKATO varchar(5),
							UniqueNumberPolicy varchar(20),
							OGRN_SMO varchar(15),
							TypePolicy char(1),
							SPolicy varchar(20),
							NPolicy varchar(20),
							DBEG date,
							DEND date,
							ERP varchar(50),
							Iteration tinyint,
							[FileName] varchar(30)
				   		 )
--для тестирования
--insert @tFound
--select t.rf_idCaseIteration,zp1.id,ROKATO,RENP,RQOGRN,ROPDOC,RSPOL,RNPOL,RDBEG,RDEND,EERP,case when DOUT is not null then 2 else 4 end Iteration,
--		RIGHT(rtrim(l.FILENAME),LEN(l.FILENAME)-1) as FileName
--from @t t inner join [srvsql1-st2].PolicyRegister.dbo.ZP1 zp1 on
--			t.rf_idZP1=zp1.ID
--		  inner join [srvsql1-st2].PolicyRegister.dbo.ZP1LOG l on
--			zp1.ZID=l.ID

insert @tFound
select t.rf_idRefCaseIteration,zp1.id,ROKATO,RENP,RQOGRN,ROPDOC,RSPOL,RNPOL,RDBEG,RDEND,EERP,
		case when DOUT is not null then 2 else 4 end Iteration,
		RIGHT(rtrim(l.FILENAME),LEN(l.FILENAME)-1) as FileName
from vw_CaseNotDefineYeat t inner join [srvsql1-st2].PolicyRegister.dbo.ZP1 zp1 on
			t.rf_idZP1=zp1.ID
		  inner join [srvsql1-st2].PolicyRegister.dbo.ZP1LOG l on
			zp1.ZID=l.ID
			and zp1.REPL is not null

--раскладываем данные если определена страховая принадлежность
insert t_CasePatientDefineIteration(rf_idRefCaseIteration,rf_idIteration)
select rf_idRefCaseIteration,Iteration 
from @tFound 
where (DBEG is not null)
group by rf_idRefCaseIteration,Iteration

--вставляем данные если они были определены на 2 итерации
insert t_CaseDefineZP1Found(rf_idRefCaseIteration,rf_idZP1,OKATO,UniqueNumberPolicy,TypePolicy,OGRN_SMO,SPolicy,NPolcy,DateDefine)
select rf_idRefCaseIteration,rf_idZP1,OKATO,UniqueNumberPolicy,OGRN_SMO,TypePolicy,SPolicy,NPolicy,GETDATE()
from @tFound where DBEG is not null and Iteration=2

--вставляем данные если они были определены на 4 итерации
insert t_CaseDefineZP1Found(rf_idRefCaseIteration,rf_idZP1,OKATO,UniqueNumberPolicy,TypePolicy,OGRN_SMO,SPolicy,NPolcy,DateDefine)
select rf_idRefCaseIteration,rf_idZP1,OKATO,UniqueNumberPolicy,OGRN_SMO,TypePolicy,SPolicy,NPolicy,GETDATE()
from @tFound where Iteration=4 and DBEG is not null

--вставляем данные если они не были определены на 4 итерации
insert t_CaseDefineZP1Found(rf_idRefCaseIteration,rf_idZP1)
select rf_idRefCaseIteration,rf_idZP1 from @tFound where Iteration=4 and DBEG is null

--использую курсор т.к. может быть несколько файлов  которые были отправлены на определение страховой принадлежности.
declare cIteration cursor for
	select FileName
	from @tFound t inner join t_RefCasePatientDefine rf on
				t.rf_idRefCaseIteration=rf.id
	where DBEG is null
	group by FileName
	declare @fileName varchar(30)
open cIteration
fetch next from cIteration into @fileName
while @@FETCH_STATUS = 0
begin		
	
	-------------------------------------------------------
	declare @RecordCase as TVP_CasePatient,--для записей который пойдут на 3-ю итерацию
		@idRecordCaseNext as TVP_CasePatient, -- для записей которые пойдут на 4-ю итерацию
		@iteration tinyint

	select @iteration=(Iteration)+1 
	from @tFound 
	where (DBEG is not null) and Iteration=2 
	group by Iteration

	--данные разложили
	if @iteration=3
	begin
		insert @RecordCase
		select rf.rf_idCase,rf.rf_idRegisterPatient
		from @tFound t inner join t_RefCasePatientDefine rf on
					t.rf_idRefCaseIteration=rf.id
		where DBEG is null and FileName=@fileName
		
		insert @idRecordCaseNext exec usp_DefineSMOIteration1_3 @RecordCase,@iteration

		if(select COUNT(*) from @idRecordCaseNext)>0
		begin
				exec usp_DefineSMOIteration2_4 @idRecordCaseNext,2,@fileName
		end	
	end
	-------------------------------------------------------
	fetch next from cIteration into @fileName
end
close cIteration
deallocate cIteration
GO
/****** Object:  StoredProcedure [dbo].[usp_RunProcessControl]    Script Date: 12/01/2011 07:38:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[usp_RunProcessControl]
			@CaseDefined TVP_CasePatient READONLY,		
			@idFile int
	
as
declare @tError as table(rf_idCase bigint,ErrorNumber smallint)
declare @month tinyint,
		@year smallint,
		@codeLPU char(6)
		
select @CodeLPU=CodeM,@month=ReportMonth,@year=ReportYear
	from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			rc.rf_idMO=v.mcod		
	where f.id=@idFile
	
	
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))	

--Проверка 1: на даты окончания лечений
insert @tError
select c1.rf_idCase,55
from (
	  select c1.rf_idCase 
	  from @CaseDefined  c1 left join @tError e on
					c1.rf_idCase=e.rf_idCase
	  where e.rf_idCase is null
     ) c1 inner join t_Case c2 on
		c1.rf_idCase=c2.id
where c2.DateEnd<@dateStart and c2.DateEnd>=@dateEnd
     
--Проверка 2: на даты оказания услуг
insert @tError
select c1.rf_idCase,55
from (
	  select c1.rf_idCase 
	  from @CaseDefined  c1 left join @tError e on
					c1.rf_idCase=e.rf_idCase
	  where e.rf_idCase is null
     ) c1 inner join (
						select c.id
						from @CaseDefined cd inner join t_Case c on
								cd.rf_idCase=c.id
										inner join t_Meduslugi m on
								c.id=m.rf_idCase 
						where c.DateBegin>m.DateHelpBegin and m.DateHelpBegin>m.DateHelpEnd and m.DateHelpEnd>c.DateEnd
						group by c.id
						) c2 on
		c1.rf_idCase=c2.id
where c2.id is null


--Проверка 3: проверка кодов из медуслуг и кодов МЕС на справочник Мед.услуг
insert @tError
select rf_idCase,64
from vw_sprMU vwC right join (
								select c1.rf_idCase,m.MUCode
								from (
									  select c1.rf_idCase 
									  from @CaseDefined  c1 left join @tError e on
												c1.rf_idCase=e.rf_idCase
									  where e.rf_idCase is null
									 ) c1 inner join t_Meduslugi m on
										c1.rf_idCase=m.rf_idCase																		
								) t on vwc.MU=t.MUCode
where vwC.MU is null
--------------------------------------------------
insert @tError
select rf_idCase,64
from vw_sprMUAll vwC right join (
									select c1.rf_idCase,mes.MES as MUCode
									from (
										  select c1.rf_idCase 
										  from @CaseDefined  c1 left join @tError e on
														c1.rf_idCase=e.rf_idCase
										  where e.rf_idCase is null
										 ) c1 inner join t_MES mes on
									c1.rf_idCase=mes.rf_idCase
								) t on vwc.MU=t.MUCode
where vwC.MU is null

--Проверка 4: проверка того что в таблице МЕС лежат только коды законченных случаев
insert @tError
select rf_idCase,53
from (
		select mes.rf_idCase,mes.MES as MUCode
		from (
			  select c1.rf_idCase 
			  from @CaseDefined  c1 left join @tError e on
							c1.rf_idCase=e.rf_idCase
			  where e.rf_idCase is null
		     ) c1
					inner join t_MES mes on
			c1.rf_idCase=mes.rf_idCase							
	  ) t left join dbo.vw_sprMUCompletedCase t1 on
			t.MUCode=t1.MU
where t1.MU is null

--Проверка 5: что в таблице медуслуг нету кодов законченых случаев
insert @tError
select rf_idCase,53
from (
		select m.rf_idCase,m.MUCode
		from (
			  select c1.rf_idCase 
			  from @CaseDefined  c1 left join @tError e on
							c1.rf_idCase=e.rf_idCase
			  where e.rf_idCase is null
		     ) c1
					inner join t_Meduslugi m on
			c1.rf_idCase=m.rf_idCase							
	  ) t inner join dbo.vw_sprMUCompletedCase t1 on
			t.MUCode=t1.MU
			
--Проверка 8: один случай - одна единица учета
insert @tError
select rf_idCase,53
from (
		select m.rf_idCase,t1.unitCode
		from (
			  select c1.rf_idCase 
			  from @CaseDefined  c1 left join @tError e on
						c1.rf_idCase=e.rf_idCase
			  where e.rf_idCase is null
			 ) c1
						inner join t_Meduslugi m on
				c1.rf_idCase=m.rf_idCase							
						inner join dbo.vw_sprMUCompletedCase t1 on
				m.MUCode=t1.MU	
		group by m.rf_idCase,t1.unitCode
	) t
 group by rf_idCase
 having COUNT(*)>1
		
		

--Проверка 6: проверка плана-заказа
declare @t1 as table(rf_idCase bigint,Quantity bigint,unitCode int,TotalRest int)

insert @t1(rf_idCase,Quantity,unitCode)
select rf_idCase,SUM(Quantity),unitCode
from (
		select top 1000000 m.rf_idCase,m.id,m.Quantity,t1.unitCode
		from (
			  select c1.rf_idCase 
			  from @CaseDefined  c1 left join @tError e on
							c1.rf_idCase=e.rf_idCase
			  where e.rf_idCase is null
		     ) c1
					inner join t_Meduslugi m on
			c1.rf_idCase=m.rf_idCase							
					inner join dbo.vw_sprMU t1 on
					m.MUCode=t1.MU	
		order by m.id	
		) t
group by rf_idCase,unitCode
--использую курсор т.к. на данный момент это проще всего, но его потом следует заменить
declare cPlan cursor for
	select f.UnitCode,f.Vdm,f.Vm,f.Spred
	from dbo.fn_PlanOrders(@codeLPU,@month,@year) f
	declare @unit int,@vdm int, @vm int, @spred int
open cPlan
fetch next from cPlan into @unit,@vdm,@vm,@spred
while @@FETCH_STATUS = 0
begin		
	--select @unit,@vdm,@vm
	--update @t1 set @vm= Totalrest=@vm+@vdm-@spred-ISNULL(Quantity, 0) where unitCode=@unit
	declare cCase cursor for
		select t.rf_idCase,t.Quantity from @t1 t where unitCode=@unit
		declare @idCase bigint, @Quantity int
	open cCase
	fetch next from cCase into @idCase,@Quantity
	while @@FETCH_STATUS=0
	begin	
		
		--select @idCase,@vm+@vdm-@Quantity-@spred
		update @t1 set TotalRest=@vm+@vdm-@Quantity-@spred where rf_idCase=@idCase
		set @spred=@spred+@Quantity
		
		fetch next from cCase into @idCase,@Quantity
	end
	close cCase
	deallocate cCase
	fetch next from cPlan into @unit,@vdm,@vm,@spred
end
close cPlan
deallocate cPlan

insert @tError
select rf_idCase,62 from @t1 where TotalRest<0

		

--Проверка 7: количество законченных случаев должно быть равно 1
insert @tError
select mes.rf_idCase,53
from (
	  select c1.rf_idCase 
	  from @CaseDefined  c1 left join @tError e on
					c1.rf_idCase=e.rf_idCase
	  where e.rf_idCase is null
	 ) c1 inner join t_MES mes on
		c1.rf_idCase=mes.rf_idCase
where mes.Quantity<>1

begin transaction
begin try
	insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
	select ErrorNumber,@idFile,rf_idCase from @tError
end try
begin catch
if @@TRANCOUNT>0
	select ERROR_MESSAGE()
	rollback transaction
end catch
if @@TRANCOUNT>0
	commit transaction
GO
/****** Object:  StoredProcedure [dbo].[usp_InsertRegisterCaseDataLPU]    Script Date: 12/01/2011 07:38:40 ******/
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

---create tempory table----------------------------------------------

declare @t1 as table([VERSION] char(5),DATA date,[FILENAME] varchar(26))

declare @t2 as table(CODE int,CODE_MO int,[YEAR] smallint,[MONTH] tinyint,NSCHET int,DSCHET date,SUMMAV numeric(11, 2),COMENTS nvarchar(250)) 

declare @t3 as table(N_ZAP int,PR_NOV tinyint,ID_PAC nvarchar(36),VPOLIS tinyint,SPOLIS nchar(10),NPOLIS nchar(20),SMO nchar(5),NOVOR nchar(9))


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

declare @tempID as table(id int, ID_PAC nvarchar(36))

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
FROM OPENXML (@idoc, 'ZL_LIST/ZAP',2)
	WITH(
			N_ZAP int './N_ZAP',
			PR_NOV tinyint './PR_NOV',
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
FROM OPENXML (@idoc, 'ZL_LIST/ZAP/SLUCH',3)
	WITH(
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
/*
select * into t1 from @t1
select * into t2 from @t2
select * into t3 from @t3
select * into t5 from @t5
select * into t6 from @t6
select * into t7 from @t7
select * into t8 from @t8
*/

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
output inserted.id,inserted.ID_Patient into @tempID
select @id,N_ZAP,PR_NOV,ID_PAC,VPOLIS,SPOLIS,NPOLIS,NOVOR from @t3

insert t_PatientSMO(ref_idRecordCase,rf_idSMO)
select t2.id,t1.SMO
from @t3 t1 inner join @tempID t2 on
			t1.ID_PAC=t2.ID_PAC
where t1.SMO is not null

insert t_Case(rf_idRecordCase, idRecordCase, GUID_Case, rf_idV006, rf_idV008, rf_idDirectMO, HopitalisationType, rf_idMO, rf_idV002, IsChildTariff, 
				NumberHistoryCase, DateBegin, DateEnd, rf_idV009, rf_idV012, rf_idV004, IsSpecialCase, rf_idV010, AmountPayment, Comments,Age)
select t2.id,t1.IDCASE,t1.ID_C, t1.USL_OK,t1.VIDPOM, t1.NPR_MO,t1.EXTR,t1.LPU,t1.PROFIL,t1.DET,t1.NHISTORY,t1.DATE_1,t1.DATE_2,t1.RSLT,t1.ISHOD,
		t1.PRVS,t1.OS_SLUCH,t1.IDSP,t1.SUMV,t1.COMENTSL,dbo.fn_FullYear(t3.DR,t1.DATE_1)		
from @t5 t1 inner join @tempID t2 on
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
----------------------------------------------------------------------------------------------------------------------

insert t_RegisterPatient(rf_idFiles, ID_Patient, Fam, Im, Ot, rf_idV005, BirthDay, BirthPlace,rf_idRecordCase)
	output inserted.id,inserted.ID_Patient into @tableId
select @idFile,t1.ID_PAC,t1.FAM,t1.IM,case when t1.OT='НЕТ' then null else t1.OT end,t1.W,t1.DR,t1.MR,t2.id
from @t8 t1 left join @tempID t2 on
				t1.ID_PAC=t2.ID_PAC


insert t_RegisterPatientDocument(rf_idRegisterPatient, rf_idDocumentType, SeriaDocument, NumberDocument, SNILS, OKATO, OKATO_Place, Comments)
select t2.id,t1.DOCTYPE,t1.DOCSER,t1.DOCNUM,t1.SNILS,t1.OKATOG,t1.OKATOP,t1.COMENTP
from @t8 t1 inner join @tableId t2 on
		t1.ID_PAC=t2.ID_PAC
where (t1.DOCTYPE is not null) or (t1.DOCSER is not null) or (t1.DOCNUM is not null)

insert t_RegisterPatientAttendant(rf_idRegisterPatient, Fam, Im, Ot, rf_idV005, BirthDay)
select t2.id,t1.FAM_P,t1.IM_P,t1.OT_P,t1.W_P,t1.DR_P
from @t8 t1 inner join @tableId t2 on
		t1.ID_PAC=t2.ID_PAC
where (t1.FAM_P is not null) and (t1.IM_P is not null) and (t1.W_P is not null) and (t1.DR_P is not null)
end try
begin catch
if @@TRANCOUNT>0
	select ERROR_MESSAGE()
	rollback transaction
end catch
if @@TRANCOUNT>0
	commit transaction
------------------------------------------Определение страховой принадлежности на наш регистр---------------------
begin try
	declare @RecordCase as TVP_CasePatient,
			@idRecordCaseNext as TVP_CasePatient,
			@CaseDefined as TVP_CasePatient,
			@fileL varchar(26)=(select t.FILENAME1 from @t7 t)--имя файла для добавлениея в таблицу PolicyRegister.dbo.ZP1LOG
			
	
	insert @RecordCase	
	select c.id as rf_idCase,p.id as rf_idPatient 
	from @tempID rc inner join t_Case c on
			rc.id=c.rf_idRecordCase
					  inner join t_RegisterPatient p on
			rc.id=p.rf_idRecordCase and
			rc.ID_PAC=p.ID_Patient
	
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
		
	--помечаем случаи  по которым
	
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
	
		select @idFile
		
		declare @fileName varchar(26)
		select @fileName=[FILENAME] from @t1
	
--определение страховой принадлежности на 2 и 4 итерации.Пока отключил ее для тестирования

--select *,@fileName as [FileName] into tmp_RecordCaseNext from @idRecordCaseNext
--испытания проводяться на PolicyRegister
	if(select COUNT(*) from @idRecordCaseNext)>0
	begin
		exec usp_DefineSMOIteration2_4 @idRecordCaseNext,2,@fileName
	end
	
end try
begin catch
select ERROR_MESSAGE()
end catch
GO
/****** Object:  StoredProcedure [dbo].[usp_FillBackTablesAfterAllIteration]    Script Date: 12/01/2011 07:38:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--подаем id файла реестра сведений по котором закончена определения страховой принадлежности
--запуск производится только в том случае если по всем случаям присутствет запись в t_CasePatientDefineIteration
create proc [dbo].[usp_FillBackTablesAfterAllIteration]
			--@CaseDefined TVP_CasePatient READONLY,		
			@idFile int
			--@property tinyint	
as
declare @property tinyint=2

declare @fileName varchar(29),
		@idFileBack int,
		@idRegisterCaseBack int
declare @idRecordCaseBack as table(rf_idRecordCaseBack int,rf_idCase bigint)

--по поводу имени решить 
select @fileName=left(FileNameHR,2)+'T34_M'+REPLACE(SUBSTRING(FileNameHR,4,LEN(FileNameHR)),'T34_','') from t_File where id=@idFile

declare @CaseDefined TVP_CasePatient

insert @CaseDefined(rf_idCase,ID_Patient)
select rf_idCase,rf_idRegisterPatient
from t_RefCasePatientDefine
where rf_idFiles=@idFile and (IsUnloadIntoSP_TK is null)

--производим технологический контроль
exec usp_RunProcessControl @CaseDefined,@idFile

begin transaction
begin try
	--помечаем случаи из таблицы итерации, которые были отданы в Реестре СП и ТК
	update t_RefCasePatientDefine
	set IsUnloadIntoSP_TK=1
	from t_RefCasePatientDefine rf inner join @CaseDefined cd on
				rf.rf_idCase=cd.rf_idCase and
				rf.rf_idRegisterPatient=cd.ID_Patient



 insert t_FileBack(rf_idFiles,FileNameHRBack) values(@idFile,@fileName)
 select @idFileBack=SCOPE_IDENTITY()
 
 insert t_RegisterCaseBack(rf_idFilesBack,ref_idF003,ReportYear,ReportMonth,DateCreate,NumberRegister,PropertyNumberRegister)
 select @idFileBack,c.rf_idMO,c.ReportYear,c.ReportMonth,GETDATE(),NumberRegister,@property
 from t_RegistersCase c
 where c.rf_idFiles=@idFile
 select @idRegisterCaseBack=SCOPE_IDENTITY()
 
 
 insert t_RecordCaseBack(rf_idRecordCase,rf_idRegisterCaseBack,rf_idCase)
	output inserted.id,inserted.rf_idCase into @idRecordCaseBack
 select c.rf_idRecordCase,@idRegisterCaseBack,c.id
 from @CaseDefined cd inner join t_Case c on
		cd.rf_idCase=c.id
		
--т.к. определение страховой может быть как в таблице t_CaseDefine или t_CaseDefineZP1Found		
insert t_PatientBack(rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,rf_idSMO,OKATO)
select rcb.rf_idRecordCaseBack,c.rf_idF008,c.SPolicy,c.NPolcy,c.SMO,18000
from @CaseDefined cd inner join t_RefCasePatientDefine rf on
			cd.rf_idCase=rf.rf_idCase
					  inner join t_CaseDefine c on
			rf.id=c.rf_idRefCaseIteration
					  inner join t_CasePatientDefineIteration i on
			rf.id=i.rf_idRefCaseIteration
			and i.rf_idIteration=3
						inner join @idRecordCaseBack rcb on
			cd.rf_idCase=rcb.rf_idCase
			
--вставляем записи по которым определена страховая принадлежность на 2 и 4 шаге.
--если человек иногородний то заменяем на значение по умолчанию			
insert t_PatientBack(rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,rf_idSMO,OKATO)
select rcb.rf_idRecordCaseBack,cast(c.TypePolicy as tinyint),c.SPolicy,c.NPolcy,
		case when c.OKATO='18000' then s.SMOKOD else '34' end,
		case when c.OKATO='18000' then c.OKATO else '00000' end
from @CaseDefined cd inner join t_RefCasePatientDefine rf on
			cd.rf_idCase=rf.rf_idCase
					  inner join t_CaseDefineZP1Found c on
			rf.id=c.rf_idRefCaseIteration
					  inner join t_CasePatientDefineIteration i on
			rf.id=i.rf_idRefCaseIteration
			and i.rf_idIteration in (2,4)
						inner join @idRecordCaseBack rcb on
			cd.rf_idCase=rcb.rf_idCase
						inner join dbo.vw_sprSMOGlobal s on
			c.OGRN_SMO=s.OGRN
			and c.OKATO=s.OKATO
where (OGRN_SMO is not null) and (NPolcy is not null)

--записи по каторым не была определена страховая принадлежность
insert t_PatientBack(rf_idRecordCaseBack,rf_idF008,SeriaPolis,NumberPolis,rf_idSMO,OKATO)
select rcb.rf_idRecordCaseBack,rc.rf_idF008,rc.SeriaPolis,rc.NumberPolis,reg.rf_idSMO,'00000'
from @CaseDefined cd inner join t_RefCasePatientDefine rf on
			cd.rf_idCase=rf.rf_idCase
					  inner join t_CaseDefineZP1Found c on
			rf.id=c.rf_idRefCaseIteration
					  inner join t_CasePatientDefineIteration i on
			rf.id=i.rf_idRefCaseIteration
			and i.rf_idIteration in (2,4)
						inner join @idRecordCaseBack rcb on
			cd.rf_idCase=rcb.rf_idCase	
						inner join t_Case c1 on
			cd.rf_idCase=c1.id
						inner join t_RecordCase rc on
			c1.rf_idRecordCase=rc.id
						inner join t_RegistersCase reg on
			rc.rf_idRegistersCase=reg.id					
where (OGRN_SMO is null) and (NPolcy is null)			
			
			
 insert t_CaseBack(rf_idRecordCaseBack,TypePay)		
 select rcb.rf_idRecordCaseBack,(case when e.ErrorNumber is null then 1 else 2 end) as TypePay
 from @CaseDefined cd inner join @idRecordCaseBack rcb on
			cd.rf_idCase=rcb.rf_idCase
					  left join t_ErrorProcessControl e on
			cd.rf_idCase=e.rf_idCase and
			e.rf_idFile=@idFile
end try
begin catch
if @@TRANCOUNT>0
	select ERROR_MESSAGE()
	rollback transaction
end catch
if @@TRANCOUNT>0
	commit transaction
GO
/****** Object:  StoredProcedure [dbo].[usp_RunFillBackTablesAfterAllIteration]    Script Date: 12/01/2011 07:38:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--данная процедура находит id файлов реестров по которым определена страховая принадлежность(и не были отданы в реестре СП и ТК) 
--и передает их в процедуру usp_FillBackTablesAfterAllIteration с помощью курсора.
create proc [dbo].[usp_RunFillBackTablesAfterAllIteration]
as
declare @t as table (rf_idFile int)

--получаю записи которые не ушли в реестре СП и ТК(точнее id файлы сведений) после 1-го шага
--и смотрю а по всем ли записям из файла была определена страховая принадлежность
--если да то подаю id фалйа сведений в процедуру usp_FillBackTablesAfterAllIteration
insert @t
select t1.rf_idFiles
from(
		select COUNT(*) as TotalRow,rf_idFiles
		from t_RefCasePatientDefine 		
		where IsUnloadIntoSP_TK is null
		group by rf_idFiles
	) t1 inner join (
						select COUNT(*) as DefineRow,rf_idFiles
						from t_RefCasePatientDefine r inner join t_CasePatientDefineIteration i on
								r.id=i.rf_idRefCaseIteration
						where IsUnloadIntoSP_TK is not null
						group by rf_idFiles	
					) t2 on 
			t1.rf_idFiles=t2.rf_idFiles
			and t1.TotalRow=t2.DefineRow
			
			
--использую курсор 
declare cRunProcedure cursor for
	select rf_idFile from @t
	declare @id int
open cRunProcedure
fetch next from cRunProcedure into @id
while @@FETCH_STATUS = 0
begin		
	-------------------------------------------------------
	exec usp_FillBackTablesAfterAllIteration @id	
	-------------------------------------------------------
	fetch next from cRunProcedure into @id
end
close cRunProcedure
deallocate cRunProcedure
GO
/****** Object:  Default [DF__t_ErrorPr__DateR__2A01329B]    Script Date: 12/01/2011 07:38:35 ******/
ALTER TABLE [dbo].[t_ErrorProcessControl] ADD  DEFAULT (getdate()) FOR [DateRegistration]
GO
/****** Object:  Default [DF_GUID_File]    Script Date: 12/01/2011 07:38:35 ******/
ALTER TABLE [dbo].[t_File] ADD  CONSTRAINT [DF_GUID_File]  DEFAULT (newsequentialid()) FOR [GUID]
GO
/****** Object:  Default [DF_DateRegistration]    Script Date: 12/01/2011 07:38:35 ******/
ALTER TABLE [dbo].[t_File] ADD  CONSTRAINT [DF_DateRegistration]  DEFAULT (getdate()) FOR [DateRegistration]
GO
/****** Object:  Default [DF_DateCreateFileBack]    Script Date: 12/01/2011 07:38:35 ******/
ALTER TABLE [dbo].[t_FileBack] ADD  CONSTRAINT [DF_DateCreateFileBack]  DEFAULT (getdate()) FOR [DateCreate]
GO
/****** Object:  Default [DF__t_FileBac__FileV__59063A47]    Script Date: 12/01/2011 07:38:35 ******/
ALTER TABLE [dbo].[t_FileBack] ADD  DEFAULT ('1.1') FOR [FileVersion]
GO
/****** Object:  Default [DF_UserNameFileBack]    Script Date: 12/01/2011 07:38:35 ******/
ALTER TABLE [dbo].[t_FileBack] ADD  CONSTRAINT [DF_UserNameFileBack]  DEFAULT (original_login()) FOR [UserName]
GO
/****** Object:  Default [DF__t_FileBac__IsUnl__4FBCC72F]    Script Date: 12/01/2011 07:38:35 ******/
ALTER TABLE [dbo].[t_FileBack] ADD  DEFAULT ((0)) FOR [IsUnload]
GO
/****** Object:  Default [DF_DateCreate]    Script Date: 12/01/2011 07:38:35 ******/
ALTER TABLE [dbo].[t_FileError] ADD  CONSTRAINT [DF_DateCreate]  DEFAULT (getdate()) FOR [DateCreate]
GO
/****** Object:  Default [DF_DateRegistrationFileTested]    Script Date: 12/01/2011 07:38:35 ******/
ALTER TABLE [dbo].[t_FileTested] ADD  CONSTRAINT [DF_DateRegistrationFileTested]  DEFAULT (getdate()) FOR [DateRegistration]
GO
/****** Object:  Default [DF_UserName]    Script Date: 12/01/2011 07:38:35 ******/
ALTER TABLE [dbo].[t_FileTested] ADD  CONSTRAINT [DF_UserName]  DEFAULT (original_login()) FOR [UserName]
GO
/****** Object:  Check [CH_More_Equal_Zero]    Script Date: 12/01/2011 07:38:35 ******/
ALTER TABLE [dbo].[t_Case]  WITH CHECK ADD  CONSTRAINT [CH_More_Equal_Zero] CHECK  (([AmountPayment]>=(0)))
GO
ALTER TABLE [dbo].[t_Case] CHECK CONSTRAINT [CH_More_Equal_Zero]
GO
/****** Object:  Check [CheckMonth]    Script Date: 12/01/2011 07:38:36 ******/
ALTER TABLE [dbo].[t_RegistersCase]  WITH CHECK ADD  CONSTRAINT [CheckMonth] CHECK  (([ReportMonth]>(0) AND [ReportMonth]<(13)))
GO
ALTER TABLE [dbo].[t_RegistersCase] CHECK CONSTRAINT [CheckMonth]
GO
/****** Object:  Check [CheckNumber]    Script Date: 12/01/2011 07:38:36 ******/
ALTER TABLE [dbo].[t_RegistersCase]  WITH CHECK ADD  CONSTRAINT [CheckNumber] CHECK  (([NumberRegister]>(0)))
GO
ALTER TABLE [dbo].[t_RegistersCase] CHECK CONSTRAINT [CheckNumber]
GO
/****** Object:  Check [CheckRegisterDate]    Script Date: 12/01/2011 07:38:36 ******/
ALTER TABLE [dbo].[t_RegistersCase]  WITH CHECK ADD  CONSTRAINT [CheckRegisterDate] CHECK  (([DateRegister]<=getdate()))
GO
ALTER TABLE [dbo].[t_RegistersCase] CHECK CONSTRAINT [CheckRegisterDate]
GO
/****** Object:  Check [CheckYear]    Script Date: 12/01/2011 07:38:36 ******/
ALTER TABLE [dbo].[t_RegistersCase]  WITH CHECK ADD  CONSTRAINT [CheckYear] CHECK  (([ReportYear]>(datepart(year,getdate())-(1)) AND [ReportYear]<=datepart(year,getdate())))
GO
ALTER TABLE [dbo].[t_RegistersCase] CHECK CONSTRAINT [CheckYear]
GO
/****** Object:  ForeignKey [FK_Cases_Files]    Script Date: 12/01/2011 07:38:35 ******/
ALTER TABLE [dbo].[t_Case]  WITH CHECK ADD  CONSTRAINT [FK_Cases_Files] FOREIGN KEY([rf_idRecordCase])
REFERENCES [dbo].[t_RecordCase] ([id])
GO
ALTER TABLE [dbo].[t_Case] CHECK CONSTRAINT [FK_Cases_Files]
GO
/****** Object:  ForeignKey [FK_CaseBack_RecordCaseBack]    Script Date: 12/01/2011 07:38:35 ******/
ALTER TABLE [dbo].[t_CaseBack]  WITH CHECK ADD  CONSTRAINT [FK_CaseBack_RecordCaseBack] FOREIGN KEY([rf_idRecordCaseBack])
REFERENCES [dbo].[t_RecordCaseBack] ([id])
GO
ALTER TABLE [dbo].[t_CaseBack] CHECK CONSTRAINT [FK_CaseBack_RecordCaseBack]
GO
/****** Object:  ForeignKey [FK_CaseDefine_RefCaseIteration]    Script Date: 12/01/2011 07:38:35 ******/
ALTER TABLE [dbo].[t_CaseDefine]  WITH CHECK ADD  CONSTRAINT [FK_CaseDefine_RefCaseIteration] FOREIGN KEY([rf_idRefCaseIteration])
REFERENCES [dbo].[t_RefCasePatientDefine] ([id])
GO
ALTER TABLE [dbo].[t_CaseDefine] CHECK CONSTRAINT [FK_CaseDefine_RefCaseIteration]
GO
/****** Object:  ForeignKey [FK_CaseIterationZP1_RefCaseIteration]    Script Date: 12/01/2011 07:38:35 ******/
ALTER TABLE [dbo].[t_CaseDefineZP1]  WITH CHECK ADD  CONSTRAINT [FK_CaseIterationZP1_RefCaseIteration] FOREIGN KEY([rf_idRefCaseIteration])
REFERENCES [dbo].[t_RefCasePatientDefine] ([id])
GO
ALTER TABLE [dbo].[t_CaseDefineZP1] CHECK CONSTRAINT [FK_CaseIterationZP1_RefCaseIteration]
GO
/****** Object:  ForeignKey [FK_RefCasePatientIterationDefine]    Script Date: 12/01/2011 07:38:35 ******/
ALTER TABLE [dbo].[t_CasePatientDefineIteration]  WITH CHECK ADD  CONSTRAINT [FK_RefCasePatientIterationDefine] FOREIGN KEY([rf_idRefCaseIteration])
REFERENCES [dbo].[t_RefCasePatientDefine] ([id])
GO
ALTER TABLE [dbo].[t_CasePatientDefineIteration] CHECK CONSTRAINT [FK_RefCasePatientIterationDefine]
GO
/****** Object:  ForeignKey [FK_sprIteration]    Script Date: 12/01/2011 07:38:35 ******/
ALTER TABLE [dbo].[t_CasePatientDefineIteration]  WITH CHECK ADD  CONSTRAINT [FK_sprIteration] FOREIGN KEY([rf_idIteration])
REFERENCES [dbo].[sprIteration] ([id])
GO
ALTER TABLE [dbo].[t_CasePatientDefineIteration] CHECK CONSTRAINT [FK_sprIteration]
GO
/****** Object:  ForeignKey [FK_Diagnosis_Cases]    Script Date: 12/01/2011 07:38:35 ******/
ALTER TABLE [dbo].[t_Diagnosis]  WITH CHECK ADD  CONSTRAINT [FK_Diagnosis_Cases] FOREIGN KEY([rf_idCase])
REFERENCES [dbo].[t_Case] ([id])
GO
ALTER TABLE [dbo].[t_Diagnosis] CHECK CONSTRAINT [FK_Diagnosis_Cases]
GO
/****** Object:  ForeignKey [FK_Error_FileNameError]    Script Date: 12/01/2011 07:38:35 ******/
ALTER TABLE [dbo].[t_Error]  WITH CHECK ADD  CONSTRAINT [FK_Error_FileNameError] FOREIGN KEY([rf_idFileNameError])
REFERENCES [dbo].[t_FileNameError] ([id])
GO
ALTER TABLE [dbo].[t_Error] CHECK CONSTRAINT [FK_Error_FileNameError]
GO
/****** Object:  ForeignKey [FK_File_FileTested]    Script Date: 12/01/2011 07:38:35 ******/
ALTER TABLE [dbo].[t_File]  WITH CHECK ADD  CONSTRAINT [FK_File_FileTested] FOREIGN KEY([rf_idFileTested])
REFERENCES [dbo].[t_FileTested] ([id])
GO
ALTER TABLE [dbo].[t_File] CHECK CONSTRAINT [FK_File_FileTested]
GO
/****** Object:  ForeignKey [FK_FileError_Files]    Script Date: 12/01/2011 07:38:35 ******/
ALTER TABLE [dbo].[t_FileError]  WITH CHECK ADD  CONSTRAINT [FK_FileError_Files] FOREIGN KEY([rf_idFileTested])
REFERENCES [dbo].[t_FileTested] ([id])
GO
ALTER TABLE [dbo].[t_FileError] CHECK CONSTRAINT [FK_FileError_Files]
GO
/****** Object:  ForeignKey [FK_FileName_FileError]    Script Date: 12/01/2011 07:38:35 ******/
ALTER TABLE [dbo].[t_FileNameError]  WITH CHECK ADD  CONSTRAINT [FK_FileName_FileError] FOREIGN KEY([rf_idFileError])
REFERENCES [dbo].[t_FileError] ([id])
GO
ALTER TABLE [dbo].[t_FileNameError] CHECK CONSTRAINT [FK_FileName_FileError]
GO
/****** Object:  ForeignKey [FK_FinancialSanctions_Cases]    Script Date: 12/01/2011 07:38:35 ******/
ALTER TABLE [dbo].[t_FinancialSanctions]  WITH CHECK ADD  CONSTRAINT [FK_FinancialSanctions_Cases] FOREIGN KEY([rf_idCase])
REFERENCES [dbo].[t_Case] ([id])
GO
ALTER TABLE [dbo].[t_FinancialSanctions] CHECK CONSTRAINT [FK_FinancialSanctions_Cases]
GO
/****** Object:  ForeignKey [FK_Meduslugi_Cases]    Script Date: 12/01/2011 07:38:36 ******/
ALTER TABLE [dbo].[t_Meduslugi]  WITH CHECK ADD  CONSTRAINT [FK_Meduslugi_Cases] FOREIGN KEY([rf_idCase])
REFERENCES [dbo].[t_Case] ([id])
GO
ALTER TABLE [dbo].[t_Meduslugi] CHECK CONSTRAINT [FK_Meduslugi_Cases]
GO
/****** Object:  ForeignKey [FK_MES_Cases]    Script Date: 12/01/2011 07:38:36 ******/
ALTER TABLE [dbo].[t_MES]  WITH CHECK ADD  CONSTRAINT [FK_MES_Cases] FOREIGN KEY([rf_idCase])
REFERENCES [dbo].[t_Case] ([id])
GO
ALTER TABLE [dbo].[t_MES] CHECK CONSTRAINT [FK_MES_Cases]
GO
/****** Object:  ForeignKey [FK_PatientBack_RecordCaseBack]    Script Date: 12/01/2011 07:38:36 ******/
ALTER TABLE [dbo].[t_PatientBack]  WITH CHECK ADD  CONSTRAINT [FK_PatientBack_RecordCaseBack] FOREIGN KEY([rf_idRecordCaseBack])
REFERENCES [dbo].[t_RecordCaseBack] ([id])
GO
ALTER TABLE [dbo].[t_PatientBack] CHECK CONSTRAINT [FK_PatientBack_RecordCaseBack]
GO
/****** Object:  ForeignKey [FK_PatientSMO_Patient]    Script Date: 12/01/2011 07:38:36 ******/
ALTER TABLE [dbo].[t_PatientSMO]  WITH CHECK ADD  CONSTRAINT [FK_PatientSMO_Patient] FOREIGN KEY([ref_idRecordCase])
REFERENCES [dbo].[t_RecordCase] ([id])
GO
ALTER TABLE [dbo].[t_PatientSMO] CHECK CONSTRAINT [FK_PatientSMO_Patient]
GO
/****** Object:  ForeignKey [FK_ReasonPaymentCanseled_Cases]    Script Date: 12/01/2011 07:38:36 ******/
ALTER TABLE [dbo].[t_ReasonPaymentCancelled]  WITH CHECK ADD  CONSTRAINT [FK_ReasonPaymentCanseled_Cases] FOREIGN KEY([rf_idCase])
REFERENCES [dbo].[t_Case] ([id])
GO
ALTER TABLE [dbo].[t_ReasonPaymentCancelled] CHECK CONSTRAINT [FK_ReasonPaymentCanseled_Cases]
GO
/****** Object:  ForeignKey [FK_RecordCase_RegistersCase]    Script Date: 12/01/2011 07:38:36 ******/
ALTER TABLE [dbo].[t_RecordCase]  WITH CHECK ADD  CONSTRAINT [FK_RecordCase_RegistersCase] FOREIGN KEY([rf_idRegistersCase])
REFERENCES [dbo].[t_RegistersCase] ([id])
GO
ALTER TABLE [dbo].[t_RecordCase] CHECK CONSTRAINT [FK_RecordCase_RegistersCase]
GO
/****** Object:  ForeignKey [FK_RecordCaseBack_RecordCase]    Script Date: 12/01/2011 07:38:36 ******/
ALTER TABLE [dbo].[t_RecordCaseBack]  WITH CHECK ADD  CONSTRAINT [FK_RecordCaseBack_RecordCase] FOREIGN KEY([rf_idRecordCase])
REFERENCES [dbo].[t_RecordCase] ([id])
GO
ALTER TABLE [dbo].[t_RecordCaseBack] CHECK CONSTRAINT [FK_RecordCaseBack_RecordCase]
GO
/****** Object:  ForeignKey [FK_RecordCaseBack_RegisterCaseBack]    Script Date: 12/01/2011 07:38:36 ******/
ALTER TABLE [dbo].[t_RecordCaseBack]  WITH CHECK ADD  CONSTRAINT [FK_RecordCaseBack_RegisterCaseBack] FOREIGN KEY([rf_idRegisterCaseBack])
REFERENCES [dbo].[t_RegisterCaseBack] ([id])
GO
ALTER TABLE [dbo].[t_RecordCaseBack] CHECK CONSTRAINT [FK_RecordCaseBack_RegisterCaseBack]
GO
/****** Object:  ForeignKey [FK_RegistersCasesBack_FilesBack]    Script Date: 12/01/2011 07:38:36 ******/
ALTER TABLE [dbo].[t_RegisterCaseBack]  WITH CHECK ADD  CONSTRAINT [FK_RegistersCasesBack_FilesBack] FOREIGN KEY([rf_idFilesBack])
REFERENCES [dbo].[t_FileBack] ([id])
GO
ALTER TABLE [dbo].[t_RegisterCaseBack] CHECK CONSTRAINT [FK_RegistersCasesBack_FilesBack]
GO
/****** Object:  ForeignKey [FK_RegisterPatient_Files]    Script Date: 12/01/2011 07:38:36 ******/
ALTER TABLE [dbo].[t_RegisterPatient]  WITH CHECK ADD  CONSTRAINT [FK_RegisterPatient_Files] FOREIGN KEY([rf_idFiles])
REFERENCES [dbo].[t_File] ([id])
GO
ALTER TABLE [dbo].[t_RegisterPatient] CHECK CONSTRAINT [FK_RegisterPatient_Files]
GO
/****** Object:  ForeignKey [FK_RegisterPatientAttendant_RegisterPatient]    Script Date: 12/01/2011 07:38:36 ******/
ALTER TABLE [dbo].[t_RegisterPatientAttendant]  WITH CHECK ADD  CONSTRAINT [FK_RegisterPatientAttendant_RegisterPatient] FOREIGN KEY([rf_idRegisterPatient])
REFERENCES [dbo].[t_RegisterPatient] ([id])
GO
ALTER TABLE [dbo].[t_RegisterPatientAttendant] CHECK CONSTRAINT [FK_RegisterPatientAttendant_RegisterPatient]
GO
/****** Object:  ForeignKey [FK_RegisterPatientDocument_RegisterPatient]    Script Date: 12/01/2011 07:38:36 ******/
ALTER TABLE [dbo].[t_RegisterPatientDocument]  WITH CHECK ADD  CONSTRAINT [FK_RegisterPatientDocument_RegisterPatient] FOREIGN KEY([rf_idRegisterPatient])
REFERENCES [dbo].[t_RegisterPatient] ([id])
GO
ALTER TABLE [dbo].[t_RegisterPatientDocument] CHECK CONSTRAINT [FK_RegisterPatientDocument_RegisterPatient]
GO
/****** Object:  ForeignKey [FK_RegistersCases_Files]    Script Date: 12/01/2011 07:38:36 ******/
ALTER TABLE [dbo].[t_RegistersCase]  WITH CHECK ADD  CONSTRAINT [FK_RegistersCases_Files] FOREIGN KEY([rf_idFiles])
REFERENCES [dbo].[t_File] ([id])
GO
ALTER TABLE [dbo].[t_RegistersCase] CHECK CONSTRAINT [FK_RegistersCases_Files]
GO
