USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT	

select @idFile=id from vw_getIdFileNumber where CodeM='165531' and NumberRegister=4747 and ReportYear=2019

SELECT  ErrorNumber,COUNT(rf_idCase) from dbo.t_ErrorProcessControl WHERE rf_idFile=@idFile GROUP BY ErrorNumber

select * from vw_getIdFileNumber where id=@idFile

declare @month tinyint,
		@year smallint,
		@codeLPU char(6)
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile
--устанавливаем дату начала и дату окончания отчетного периода
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))	

SELECT DISTINCT c.id,448, c.idRecordCase,'Error'
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

---------CONTENT
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
where a.rf_idFiles=@idFile AND f.TypeFile='H'  AND c.rf_idV006=3 AND c.rf_idV008 IN(1,11,12,13) AND len(c.Comments)>3 AND c.Comments<>':;'
		AND c.Comments NOT LIKE '[0-9]:;'
	 


SELECT id,448,Comments,* FROM #tmp WHERE Comments NOT LIKE ':[0-9],[a-zA-Z][0-9]%' 

IF EXISTS(SELECT * FROM #tmp WHERE Comments LIKE ':[0,9],[a-zA-Z][0-9]%')
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
		
		SELECT id,448,1 FROM #tContent WHERE X NOT IN(1,2,4,6,7)
	end
	ELSE
	BEGIN   
		SELECT id,448,2 FROM #tContent WHERE DS1 IS NOT NULL AND  NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.sprMKBDN WHERE DiagnosisCode=DS1)
		SELECT id,448,3 FROM #tContent WHERE NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.sprMKBDN WHERE DiagnosisCode=DS)
	END 
	DROP TABLE #tContent
END 
go
DROP TABLE #tmp
