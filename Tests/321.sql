USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

SELECT @idFile=f.id 
from vw_getIdFileNumber f WHERE CodeM='185905' AND ReportYear=2021 AND NumberRegister=60

SET STATISTICS TIME ON

SELECT ErrorNumber,COUNT(rf_idCase) AS CountCase FROM dbo.t_ErrorProcessControl WHERE rf_idFile=@idFile GROUP BY ErrorNumber ORDER BY countCase desc
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


SELECT l.CodeM,p.dateBeg,p.dateEnd,p.rf_MSConditionId AS USL_OK ,p.IDFRMMP AS FOR_POM
INTO #tMOPay
FROM dbo.vw_sprT001 l JOIN oms_nsi.dbo.tMOFederalPayment p ON
			 l.MOId=p.rf_MOId

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
		AND c.rf_idV014=p.FOR_POM
where a.rf_idFiles=@idFile AND f.TypeFile='H' 
go
DROP TABLE #tMOPay