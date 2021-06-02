use RegisterCases
go
if OBJECT_ID('getPID',N'FN') is not null
	drop function getPID
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