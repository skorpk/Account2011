use RegisterCases
go
SET ANSI_PADDING ON
SET ANSI_DEFAULTS ON
select id,FileNameHR,CodeM,DateRegistration,CountSluch
from t_File
where DateRegistration>'20120113'
order by DateRegistration desc