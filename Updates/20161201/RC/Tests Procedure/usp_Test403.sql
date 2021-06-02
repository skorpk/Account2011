
USE RegisterCases
go
CREATE PROC [dbo].[usp_Test403]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
insert #tError
select DISTINCT c.id,403
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase												
where a.rf_idFiles=@idFile AND NOT EXISTS(SELECT * FROM dbo.vw_sprV002 WHERE id=c.rf_idV002)
GO
GRANT EXECUTE ON usp_Test403 TO db_RegisterCase