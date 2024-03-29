USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test452]    Script Date: 10.10.2019 9:03:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test452]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
/*
Если ONK_USL/USL_TIP in (3,4), то WEI обязательно заполняется.
*/
INSERT #tError
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
where a.rf_idFiles=@idFile AND f.TypeFile='H'  AND ou.rf_idN013 =4	AND NOT EXISTS(SELECT 1 FROM dbo.t_ONK_SL WHERE rf_idCase=c.id AND WEI IS NOT NULL )
/*
Если ONK_USL/USL_TIP =2 и в одном из CRIT указана схема химиотерапии (CRIT like ‘sh%’), для которой в НСИ прописано «расчет по массе»(1) или «расчет по площади»(2) 
	или «расчет по массе и по площади»(3), то проверяется следующее:
если схема соответствует «расчет по массе», то WEI обязательно для заполнения;
если схема соответствует «расчет по площади», то обязательно заполнено WEI и HEI или BSA;
если схема соответствует «расчет по массе и по площади», то обязательно заполнено (WEI и HEI) или (BSA и HEI) или (WEI и BSA).
*/

INSERT #tError
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

INSERT #tError
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

INSERT #tError
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
GO