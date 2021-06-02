USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT,
	@month TINYINT=1,
	@year SMALLINT=2019

select @idFile=id, @month=ReportMonth, @year=ReportYear from vw_getIdFileNumber where CodeM='106001' and NumberRegister=2 and ReportYear=2020

select * from vw_getIdFileNumber where id=@idFile

SELECT DISTINCT c.id,445
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
where a.rf_idFiles=@idFile AND f.TypeFile='H'  AND cc.HospitalizationPeriod IS null AND c.rf_idV006<3 AND c.rf_idV010<>4

;WITH cteKD
AS(
SELECT r.id,cc.HospitalizationPeriod, SUM(c.KD) AS KD
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
where a.rf_idFiles=@idFile AND f.TypeFile='H'  AND cc.HospitalizationPeriod IS NOT NULL AND c.rf_idV010<>4 
GROUP BY r.id,cc.HospitalizationPeriod
)
SELECT c.id,445,k.kd,k.HospitalizationPeriod
FROM cteKD k INNER JOIN dbo.t_Case c ON
		k.id=c.rf_idRecordCase
WHERE k.KD<>k.HospitalizationPeriod