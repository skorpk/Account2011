USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

SELECT @idFile=f.id 
from vw_getIdFileNumber f WHERE CodeM='103001' AND ReportYear=2019 AND NumberRegister=652

SELECT * from vw_getIdFileNumber f WHERE id=@idFile

SELECT ErrorNumber,COUNT(rf_idCase) AS CountCase FROM dbo.t_ErrorProcessControl WHERE rf_idFile=@idFile GROUP BY ErrorNumber ORDER BY countCase DESC

declare @month tinyint,
		@year smallint,
		@codeLPU char(6),
		@dateReg DATE,
		@mcod CHAR(6),
		@typeFile char(1)
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear,@dateReg=CAST(f.DateRegistration AS DATE),@mcod =rc.rf_idMO, @typeFile=UPPER(f.TypeFile)
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile

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
SELECT c.id,443
FROM cte cc INNER JOIN dbo.t_Case c ON
		cc.idPac=c.rf_idRecordCase

;WITH cte
AS(
SELECT cc.id,cc.rf_idRecordCase
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
GROUP BY cc.id,cc.rf_idRecordCase
HAVING COUNT(*)>1
)
SELECT c.id,443
FROM cte cc INNER JOIN dbo.t_Case c ON
		cc.rf_idRecordCase=c.rf_idRecordCase