USE RegisterCases
GO
if(OBJECT_ID('usp_Test_RSLT',N'P')) is not null
	drop PROCEDURE dbo.usp_Test_RSLT
go
CREATE PROC dbo.usp_Test_RSLT
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

INSERT #tError
SELECT c.id,'006F.00.1100'
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20200320'					
where a.rf_idFiles=@idFile AND c.rf_idV012=306 AND c.rf_idV009 NOT IN(301, 305, 308, 314, 315, 317, 318, 321, 322, 323, 324, 325,
																	  332, 333, 334, 335, 336, 343, 344, 347, 348, 349, 350, 351, 
																	  353, 355, 356, 357, 358, 361, 362, 363, 364, 365, 366, 367, 
																	  368, 369, 370, 371, 372, 373, 374)


GO
GRANT EXECUTE ON usp_Test_RSLT TO db_RegisterCase