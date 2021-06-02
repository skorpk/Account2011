USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

SELECT @idFile=f.id 
from vw_getIdFileNumber f WHERE CodeM='103001' AND ReportYear=2019 AND NumberRegister=476


--SELECT ErrorNumber,COUNT(rf_idCase) AS CountCase FROM dbo.t_ErrorProcessControl WHERE rf_idFile=@idFile GROUP BY ErrorNumber ORDER BY countCase desc
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

SELECT DISTINCT c.id,452,GUID_Case
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'				 
			  INNER JOIN dbo.t_ONK_USL ou ON
		c.id=ou.rf_idCase            
where a.rf_idFiles=@idFile AND f.TypeFile='H'  AND ou.rf_idN013 =4	AND NOT EXISTS(SELECT 1 FROM dbo.t_ONK_SL WHERE rf_idCase=c.id AND WEI IS NOT NULL)

SELECT DISTINCT c.id,452
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'				 
			  INNER JOIN dbo.t_ONK_USL ou ON
		c.id=ou.rf_idCase  				          
			INNER JOIN dbo.t_AdditionalCriterion ad ON
		c.id=ad.rf_idCase  
			INNER JOIN dbo.vw_sprV024Anthropometry v24 ON
		ad.rf_idAddCretiria=v24.IDDKK          
			INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase          
where a.rf_idFiles=@idFile AND f.TypeFile='H'  AND ou.rf_idN013 =2	AND ad.rf_idAddCretiria LIKE 'sh%'
		AND v24.isAnthropometry=1  AND sl.WEI IS NULL

SELECT DISTINCT c.id,452
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'				 
			  INNER JOIN dbo.t_ONK_USL ou ON
		c.id=ou.rf_idCase  				          
			INNER JOIN dbo.t_AdditionalCriterion ad ON
		c.id=ad.rf_idCase  
			INNER JOIN dbo.vw_sprV024Anthropometry v24 ON
		ad.rf_idAddCretiria=v24.IDDKK          
			INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase          
where a.rf_idFiles=@idFile AND f.TypeFile='H'  AND ou.rf_idN013 =2	AND ad.rf_idAddCretiria LIKE 'sh%'
		AND v24.isAnthropometry=2  AND ((sl.WEI IS null  AND sl.HEI IS NULL) OR  sl.BSA IS NULL)

SELECT DISTINCT c.id,452
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'				 
			  INNER JOIN dbo.t_ONK_USL ou ON
		c.id=ou.rf_idCase  				          
			INNER JOIN dbo.t_AdditionalCriterion ad ON
		c.id=ad.rf_idCase  
			INNER JOIN dbo.vw_sprV024Anthropometry v24 ON
		ad.rf_idAddCretiria=v24.IDDKK          
			INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase          
where a.rf_idFiles=@idFile AND f.TypeFile='H'  AND ou.rf_idN013 =2	AND ad.rf_idAddCretiria LIKE 'sh%'
		AND v24.isAnthropometry=3  AND 
		((sl.WEI IS null  AND sl.HEI IS NULL) OR  (sl.wei IS NULL AND sl.BSA IS NULL) OR (sl.HEI IS NULL AND sl.BSA IS null) )