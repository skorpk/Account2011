
USE RegisterCases
go
CREATE PROC [dbo].[usp_Test401]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
insert #tError
select DISTINCT c.id,401
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase	
			  INNER JOIN dbo.t_Meduslugi m ON
		c.id=m.rf_idCase											
where a.rf_idFiles=@idFile AND m.IsNeedUsl IS NULL

insert #tError
select DISTINCT c.id,401
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase	
			  INNER JOIN dbo.t_Meduslugi m ON
		c.id=m.rf_idCase											
where a.rf_idFiles=@idFile AND m.IsNeedUsl IS NOT NULL AND m.IsNeedUsl NOT IN (0,1,2)
GO
GRANT EXECUTE ON usp_Test401 TO db_RegisterCase