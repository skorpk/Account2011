USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

SELECT @idFile=f.id 
from vw_getIdFileNumber f WHERE CodeM='103001' AND ReportYear=2020 AND NumberRegister=933


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


SELECT DiagnosisCode INTO #tDIag FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'C%'
UNION ALL
SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'D00' AND 'D09'


SELECT DISTINCT c.id,451,c.GUID_Case
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
where a.rf_idFiles=@idFile AND f.TypeFile='H'  AND ou.rf_idN013 IN(3,4)	AND NOT EXISTS(SELECT 1 FROM dbo.t_ONK_SL WHERE rf_idCase=c.id AND K_FR>=0)

/*
Если в одном из значений CRIT представлено значение like 'fr%', то K_FR  обязательно для заполнения, причем K_FR>=0.
*/
/*
SELECT DISTINCT c.id,451
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'			
				INNER JOIN dbo.t_Diagnosis d ON
        c.id=d.rf_idCase
				INNER JOIN #tDIag dd ON
        dd.DiagnosisCode = d.DiagnosisCode	 
			  INNER JOIN dbo.t_AdditionalCriterion ad ON
		c.id=ad.rf_idCase            
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND ad.rf_idAddCretiria LIKE 'fr%' AND NOT EXISTS(SELECT 1 FROM dbo.t_ONK_SL WHERE rf_idCase=c.id AND K_FR>=0)
*/
SELECT DISTINCT c.id,451
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'				 
			  INNER JOIN dbo.t_AdditionalCriterion ad ON
		c.id=ad.rf_idCase            
			 INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase           
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND ad.rf_idAddCretiria LIKE 'fr%' AND sl.K_FR>0 AND NOT EXISTS(SELECT 1 FROM vw_sprV024_Fraction WHERE IDDKK=ad.rf_idAddCretiria AND sl.K_FR >=MinValue AND sl.K_FR<=MaxValue )


GO
DROP TABLE #tDIag