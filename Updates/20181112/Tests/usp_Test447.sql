USE [RegisterCases]
GO
if OBJECT_ID('usp_Test447',N'P') is not NULL
	DROP PROCEDURE usp_Test447
GO
CREATE PROC dbo.usp_Test447
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
;WITH doubleSL
AS(
SELECT ROW_NUMBER() OVER(PARTITION BY cc.GUID_ZSL, c.GUID_Case ORDER BY cc.id) AS idRow, c.id
from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
				and a.rf_idFiles=@idFile
						INNER JOIN dbo.t_CompletedCase cc ON
				r.id=cc.rf_idRecordCase                      
						inner join t_Case c on
				r.id=c.rf_idRecordCase							
)
insert #tError select d.id,447 FROM doubleSL d WHERE d.idRow>1
GO
GRANT EXECUTE ON usp_Test447 TO db_RegisterCase