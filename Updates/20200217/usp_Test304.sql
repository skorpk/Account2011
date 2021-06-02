USE [RegisterCases]
GO
if(OBJECT_ID('usp_Test304',N'P')) is not null
	drop PROCEDURE dbo.usp_Test304
go
CREATE PROC dbo.usp_Test304
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

insert #tError
SELECT DISTINCT c.id,304
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20200101'						
where a.rf_idFiles=@idFile AND c.rf_idV006<4 AND c.AmountPayment=0.0

GO
GRANT EXECUTE ON usp_Test304 TO db_RegisterCase