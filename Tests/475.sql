USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT,
	@month TINYINT=1,
	@year SMALLINT=2019

select @idFile=id, @month=ReportMonth, @year=ReportYear from vw_getIdFileNumber where CodeM='251003' and NumberRegister=212 and ReportYear=2019

select * from vw_getIdFileNumber where id=@idFile

SELECT DISTINCT ErrorNumber FROM dbo.t_ErrorProcessControl WHERE rf_idFile=@idFile

;WITH cte
AS(
	SELECT cc.id AS rf_idCompletedCase, c.id, c.rf_idV002
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
	where a.rf_idFiles=@idFile AND f.TypeFile='H' 
	
	)	
SELECT c1.id,475
FROM cte c1 INNER JOIN cte c2 ON
		c1.rf_idCompletedCase = c2.rf_idCompletedCase
		AND c1.id <> c2.id
WHERE c1.rf_idV002<>c2.rf_idV002