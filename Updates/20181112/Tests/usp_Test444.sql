USE [RegisterCases]
GO

if OBJECT_ID('usp_Test444',N'P') is not NULL
	DROP PROCEDURE usp_Test444
GO
create PROC dbo.usp_Test444
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

;WITH cteDate
AS(
	SELECT cc.id,r.id AS idPac,cc.DateBegin,cc.DateEnd, MIN(c.DateBegin) AS DateBegCase, MAX(c.DateEnd) AS DateEndCase
	from t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
			AND a.ReportMonth=@month
			AND a.ReportYear=@year
				  inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
				  inner join t_Case c on
			r.id=c.rf_idRecordCase						
			AND c.DateEnd>='20190101'	
				 INNER JOIN dbo.t_CompletedCase cc ON
			r.id=cc.rf_idRecordCase	 	  				     
	where a.rf_idFiles=@idFile 
	GROUP BY cc.id,r.id,cc.DateBegin,cc.DateEnd
)
INSERT #tError
SELECT DISTINCT cc.id,444
FROM cteDate c INNER JOIN dbo.t_Case cc ON
		c.idPac=cc.rf_idRecordCase
WHERE c.DateBegin<>c.DateBegCase OR c.DateEnd<>c.DateEndCase


GO
GRANT EXECUTE ON usp_Test444 TO db_RegisterCase

