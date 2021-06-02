USE [RegisterCases]
GO
if OBJECT_ID('usp_Test448',N'P') is not NULL
	DROP PROCEDURE usp_Test448
GO
CREATE PROC dbo.usp_Test448
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
INSERT #tError
SELECT DISTINCT c.id,448
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'				 
where a.rf_idFiles=@idFile AND f.TypeFile='H'  AND c.rf_idV006=3 AND c.rf_idV008 IN(1,11,12,13) AND c.Comments IS NULL

INSERT #tError
SELECT DISTINCT c.id,448
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'				 
where a.rf_idFiles=@idFile AND f.TypeFile='H'  AND c.rf_idV006=3 AND c.rf_idV008 IN(1,11,12,13) AND c.Comments IS NOT NULL AND DATALENGTH(c.Comments)<2

DECLARE @tN AS TABLE(ColumnN CHAR(3))

INSERT @tN( ColumnN ) VALUES  ( '3:;'),( '4:;'),( '5:;'),( '6:;')

INSERT #tError
SELECT DISTINCT c.id,448
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'				 
where a.rf_idFiles=@idFile AND f.TypeFile='H'  AND c.rf_idV006=3 AND c.rf_idV008 IN(1,11,12,13) AND DATALENGTH(c.Comments)=3 AND NOT EXISTS(SELECT * FROM @tN t WHERE t.ColumnN=c.Comments)

---------CONTENT 2
SELECT c.id,c.Comments,(CONVERT([xml],replace(('<Root><Num num="'+REPLACE(REPLACE(REPLACE(c.Comments,':',''),';',''),'/',':') )+'" /></Root>',':','" /><Num num="'),0)) AS XMLNum
INTO #tmp
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'				 
where a.rf_idFiles=@idFile AND f.TypeFile='H'  AND c.rf_idV006=3 AND c.rf_idV008 IN(1,11,12,13) AND DATALENGTH(c.Comments)>5 AND c.Comments<>':;'AND c.Comments NOT LIKE '[0-9]:;' 


INSERT #tError SELECT id,448 FROM #tmp WHERE Comments NOT LIKE ':[0,9],[a-zA-Z][0-9]%'

IF EXISTS(SELECT * FROM #tmp  WHERE Comments LIKE ':[0,9],[a-zA-Z][0-9]%')
BEGIN
	;WITH cte
	AS(
	SELECT s.id,m.c.value('@num[1]','varchar(30)') AS Comment
	FROM #tmp s CROSS APPLY s.XMLNum.nodes('/Root/Num') AS m(c)
	 WHERE Comments LIKE ':[0,9],[a-zA-Z][0-9]%'
	)			
	SELECT id,LEFT(comment,1) AS X
			,CASE WHEN DATALENGTH(comment)>1 then SUBSTRING(comment,3,CHARINDEX(',', comment, CHARINDEX(',', comment)+1)-3) ELSE NULL END AS DS
			,CASE WHEN DATALENGTH(comment)>1 then SUBSTRING(comment, CHARINDEX(',', comment, CHARINDEX(',', comment)+1)+1, CHARINDEX(',', comment, CHARINDEX(',', comment,CHARINDEX(',', comment)+1)+1)-CHARINDEX(',', comment, CHARINDEX(',', comment)+1)-1) ELSE NULL END  AS DS1
			,CASE WHEN DATALENGTH(comment)>1 then CAST(REPLACE(REVERSE(substring(REVERSE(comment),0,CHARINDEX(',',REVERSE(comment),0))),'-','') AS DATE) ELSE NULL END AS Date1  		
	INTO #tContent
	FROM cte

	IF EXISTS(SELECT 1 FROM #tContent WHERE X IS NOT NULL)
	begin  		
		INSERT #tError SELECT id,448 FROM #tContent WHERE X NOT IN(1,2,4,6,7)
	end
	ELSE
	BEGIN   
		INSERT #tError SELECT id,448 FROM #tContent WHERE DS1 IS NOT NULL AND  NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.sprMKBDN WHERE DiagnosisCode=DS1)
		INSERT #tError SELECT id,448 FROM #tContent WHERE NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.sprMKBDN WHERE DiagnosisCode=DS)
	END 
	DROP TABLE #tContent
END 
DROP TABLE #tmp
GO
GRANT EXECUTE ON usp_Test448 TO db_RegisterCase