USE RegisterCases
GO
if(OBJECT_ID('usp_Test321',N'P')) is not null
	drop PROCEDURE dbo.usp_Test321
go
CREATE PROC dbo.usp_Test321
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

SELECT l.CodeM,p.dateBeg,p.dateEnd,p.rf_MSConditionId AS USL_OK ,p.IDFRMMP AS FOR_POM
INTO #tMOPay
FROM dbo.vw_sprT001 l JOIN oms_nsi.dbo.tMOFederalPayment p ON
			 l.MOId=p.rf_MOId

INSERT #tError
SELECT DISTINCT c.id,321
from t_File f JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  join t_RecordCase r on
		a.id=r.rf_idRegistersCase			  
			  join t_Case c on
		r.id=c.rf_idRecordCase					  		
		AND c.DateEnd>='20210101'			
			JOIN dbo.t_CompletedCase cc on
		r.id=cc.rf_idRecordCase					  		
			JOIN #tMOPay p ON
		c.rf_idMO=p.CodeM
		AND c.rf_idV006=p.USL_OK
		AND cc.DateEnd BETWEEN p.dateBeg AND p.dateEnd	  			
where a.rf_idFiles=@idFile AND f.TypeFile='H'

DROP TABLE #tMOPay
GO
GRANT EXECUTE ON usp_Test321 TO db_RegisterCase