use RegisterCases
go
IF OBJECT_ID (N'dbo.fn_FullYear', N'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_FullYear;
GO
create function dbo.fn_FullYear (@DateBeg date,@DateEnd date)
RETURNS int
as
begin
	declare @FullYear int
	select @FullYear=DATEDIFF(YEAR,@DateBeg,@DateEnd)-CASE WHEN 100*MONTH(@DateBeg)+DAY(@DateBeg)>100*MONTH(@DateEnd)+DAY(@DateEnd) THEN 1 ELSE 0 END;
	return (@FullYear)
end
GO
-------------------------------------------------------------------------------------------------------------
if OBJECT_ID('inlist',N'FN') is not null
	drop function inlist
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
go
-------------------------------------------------------------------------------------------------------------