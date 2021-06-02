USE [RegisterCases]
GO

if OBJECT_ID('usp_Test443',N'P') is not NULL
	DROP PROCEDURE usp_Test443
GO
create PROC dbo.usp_Test443
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
insert #tError
SELECT DISTINCT c.id,443
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
where a.rf_idFiles=@idFile AND f.TypeFile='H'  AND cc.VB_P=1 AND (c.rf_idV006<>1 OR c.rf_idV008<>31 OR c.rf_idV010<>33)

insert #tError
SELECT DISTINCT c.id,443
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
where a.rf_idFiles=@idFile AND f.TypeFile='H'  AND ISNULL(cc.VB_P,1)<>1 


;WITH cte
AS(
SELECT cc.id,r.id AS idPac
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
where a.rf_idFiles=@idFile AND f.TypeFile='H'  AND cc.VB_P=1 
GROUP BY cc.id,r.id 
HAVING COUNT(*)<>2
)
insert #tError
SELECT c.id,443
FROM cte cc INNER JOIN dbo.t_Case c ON
		cc.idPac=c.rf_idRecordCase

insert #tError
SELECT c.id,443
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
where a.rf_idFiles=@idFile AND f.TypeFile='H'  AND cc.VB_P IS NULL
GROUP BY c.id
HAVING COUNT(*)>1
GO
GRANT EXECUTE ON usp_Test443 TO db_RegisterCase

