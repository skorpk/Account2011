USE RegisterCases
GO
if OBJECT_ID('usp_Test463',N'P') is not NULL
	DROP PROCEDURE usp_Test463
GO
CREATE PROC dbo.usp_Test463
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
INSERT #tError 
SELECT c.id,463
from t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
			AND a.ReportMonth=@month
			AND a.ReportYear=@year
				  inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
				  inner join t_Case c on
			r.id=c.rf_idRecordCase						
			AND c.DateEnd>='20190101'									
					INNER JOIN dbo.t_MES mm ON
			c.id=mm.rf_idCase               
where a.rf_idFiles=@idFile AND mm.Tariff<>c.AmountPayment  AND mm.IsCSGTag=1

INSERT #tError 
SELECT c.id,463
from t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
			AND a.ReportMonth=@month
			AND a.ReportYear=@year
				  inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
				  inner join t_Case c on
			r.id=c.rf_idRecordCase						
			AND c.DateEnd>='20190101'									
					INNER JOIN dbo.t_Meduslugi mm ON
			c.id=mm.rf_idCase               
where a.rf_idFiles=@idFile AND c.IsCompletedCase=0 
GROUP BY c.id, c.AmountPayment
HAVING c.AmountPayment<>SUM(mm.Quantity*mm.Price)

GO

GRANT EXECUTE ON usp_Test463 TO db_RegisterCase