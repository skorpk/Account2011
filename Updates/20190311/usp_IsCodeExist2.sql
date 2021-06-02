USE RegisterCases
GO
create PROCEDURE usp_IsCODEExists2
				@code int,
				@codeM char(6),
				@year smallint
as
select COUNT(*) 
from t_File f inner join t_RegistersCase a on
		f.id=a.rf_idFiles
where CodeM=@codeM and a.idRecord=@code AND a.ReportYear=@year

GO
GRANT EXECUTE ON dbo.usp_IsCODEExists2 TO db_RegisterCase