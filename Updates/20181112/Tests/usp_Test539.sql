USE [RegisterCases]
GO

if OBJECT_ID('usp_Test539',N'P') is not NULL
	DROP PROCEDURE usp_Test539
GO
create PROC dbo.usp_Test539
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
DECLARE @idMax INT

SELECT @idMax=MAX(cc.idRecordCase)
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase			  
			 INNER JOIN dbo.t_CompletedCase cc ON
		r.id=cc.rf_idRecordCase	 	  				     
where a.rf_idFiles=@idFile 

;WITH idRow(id) AS
(
 SELECT 1
 UNION ALL
 SELECT id+1 FROM idRow WHERE id < @idMax
)
SELECT * INTO #idRow FROM idRow;

INSERT #tError
SELECT c.id, 539
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
where a.rf_idFiles=@idFile AND NOT EXISTS(SELECT * FROM #idRow WHERE id=cc.idRecordCase)
  --если повторяется значения в IDCASE
;WITH cteID
AS(
SELECT ROW_NUMBER() OVER(PARTITION BY cc.idRecordCase ORDER BY cc.id) AS idRow, cc.id,cc.rf_idRecordCase
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase		
			 INNER JOIN dbo.t_CompletedCase cc ON
		r.id=cc.rf_idRecordCase	 	  				     
where a.rf_idFiles=@idFile 
)
INSERT #tError
SELECT c.id,539
FROM cteID cc INNER JOIN dbo.t_Case c ON
		cc.rf_idRecordCase = c.rf_idRecordCase
WHERE cc.idRow>1

GO
GRANT EXECUTE ON usp_Test539 TO db_RegisterCase

