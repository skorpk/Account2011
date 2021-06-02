USE RegisterCases
GO
if(OBJECT_ID('usp_Test_NumHist',N'P')) is not null
	drop PROCEDURE dbo.usp_Test_NumHist
go
CREATE PROC dbo.usp_Test_NumHist
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

INSERT #tError
SELECT c.id,'004F.00.0750'
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20200320'					
where a.rf_idFiles=@idFile  AND c.NumberHistoryCase LIKE '%[*,!#¹"@`~''+=&?:;^%]%'
																	  

GO
GRANT EXECUTE ON usp_Test_NumHist TO db_RegisterCase