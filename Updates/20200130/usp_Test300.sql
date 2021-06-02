USE [RegisterCases]
GO
if(OBJECT_ID('usp_Test300',N'P')) is not null
	drop PROCEDURE dbo.usp_Test300
go
CREATE PROC dbo.usp_Test300
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

insert #tError
SELECT DISTINCT c.id,300
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20200101'							 			
where a.rf_idFiles=@idFile AND f.TypeFile='F' AND c.rf_idV009 IN (323, 324,325,334,335,336,349,350,351,355,356,373,374)
	AND NOT EXISTS(SELECT 1 FROM dbo.t_Prescriptions p WHERE p.rf_idCase=c.id AND p.NAZR IS NULL)--избыточно т.к. NAZ_R тег обязательный к заполнению

GO
GRANT EXECUTE ON usp_Test300 TO db_RegisterCase